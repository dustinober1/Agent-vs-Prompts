#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys
from dataclasses import dataclass
from typing import List, Optional


@dataclass(frozen=True)
class Change:
    action: str  # add|update|delete|rename|copy
    paths: List[str]  # 1 path for most, 2 for rename/copy
    xy: str


def _run(cmd: List[str], *, capture: bool = False) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=False, text=True, capture_output=capture)


def _must_run(cmd: List[str], *, capture: bool = False) -> subprocess.CompletedProcess:
    proc = _run(cmd, capture=capture)
    if proc.returncode != 0:
        if capture:
            sys.stderr.write(proc.stderr)
        raise SystemExit(proc.returncode)
    return proc


def _git(args: List[str], *, capture: bool = False) -> subprocess.CompletedProcess:
    return _run(["git", *args], capture=capture)


def _must_git(args: List[str], *, capture: bool = False) -> subprocess.CompletedProcess:
    proc = _git(args, capture=capture)
    if proc.returncode != 0:
        if capture:
            sys.stderr.write(proc.stderr)
        raise SystemExit(proc.returncode)
    return proc


def _ensure_in_repo() -> None:
    proc = _must_git(["rev-parse", "--is-inside-work-tree"], capture=True)
    if proc.stdout.strip() != "true":
        raise SystemExit("Not inside a git work tree.")


def _ensure_no_staged_changes() -> None:
    proc = _must_git(["diff", "--cached", "--name-only", "-z"], capture=True)
    if proc.stdout:
        raise SystemExit(
            "Staged changes detected (index not empty). Unstage/commit them first to avoid mixing commits."
        )


def _parse_porcelain_z(output: bytes) -> List[Change]:
    records = output.split(b"\0")
    if records and records[-1] == b"":
        records = records[:-1]

    changes: List[Change] = []
    i = 0
    while i < len(records):
        rec = records[i]
        if len(rec) < 4:
            i += 1
            continue

        xy = rec[:2].decode("utf-8", errors="replace")
        # Format: XY<space>path
        path1 = rec[3:].decode("utf-8", errors="surrogateescape")

        if xy == "!!":
            i += 1
            continue

        if "U" in xy:
            raise SystemExit(
                f"Unmerged/conflict state detected for {path1!r} (status {xy}). Resolve conflicts first."
            )

        if "R" in xy or "C" in xy:
            if i + 1 >= len(records):
                raise SystemExit(f"Malformed rename/copy entry for {path1!r} (status {xy}).")
            path2 = records[i + 1].decode("utf-8", errors="surrogateescape")
            action = "rename" if "R" in xy else "copy"
            changes.append(Change(action=action, paths=[path1, path2], xy=xy))
            i += 2
            continue

        if xy == "??" or "A" in xy:
            action = "add"
        elif "D" in xy:
            action = "delete"
        else:
            action = "update"

        changes.append(Change(action=action, paths=[path1], xy=xy))
        i += 1

    changes.sort(key=lambda c: c.paths[0])
    return changes


def _list_untracked_files_under(path: str) -> List[str]:
    proc = subprocess.run(
        ["git", "ls-files", "--others", "--exclude-standard", "-z", "--", path],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if proc.returncode != 0:
        sys.stderr.buffer.write(proc.stderr)
        raise SystemExit(proc.returncode)
    files = proc.stdout.split(b"\0")
    if files and files[-1] == b"":
        files = files[:-1]
    return [f.decode("utf-8", errors="surrogateescape") for f in files]


def _detect_changes() -> List[Change]:
    proc = subprocess.run(
        ["git", "status", "--porcelain=v1", "-z"],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if proc.returncode != 0:
        sys.stderr.buffer.write(proc.stderr)
        raise SystemExit(proc.returncode)
    changes = _parse_porcelain_z(proc.stdout)

    expanded: List[Change] = []
    for change in changes:
        # Untracked directories appear as "?? dir/" in porcelain; expand to per-file adds.
        if change.action == "add" and len(change.paths) == 1 and change.paths[0].endswith("/"):
            untracked_files = _list_untracked_files_under(change.paths[0])
            expanded.extend([Change(action="add", paths=[p], xy=change.xy) for p in untracked_files])
            continue
        expanded.append(change)

    expanded.sort(key=lambda c: c.paths[0])
    return expanded


def _commit_message(change: Change, prefix: str) -> str:
    if change.action == "rename":
        msg = f"Rename {change.paths[0]} to {change.paths[1]}"
    elif change.action == "copy":
        msg = f"Copy {change.paths[0]} to {change.paths[1]}"
    elif change.action == "add":
        msg = f"Add {change.paths[0]}"
    elif change.action == "delete":
        msg = f"Delete {change.paths[0]}"
    else:
        msg = f"Update {change.paths[0]}"

    return f"{prefix}{msg}" if prefix else msg


def _stage_paths(paths: List[str], *, dry_run: bool) -> None:
    for path in paths:
        cmd = ["git", "add", "-A", "--", path]
        if dry_run:
            print("+", " ".join(cmd))
            continue
        proc = _run(cmd, capture=True)
        if proc.returncode != 0:
            sys.stderr.write(proc.stderr)
            raise SystemExit(proc.returncode)


def _commit(msg: str, *, dry_run: bool, no_verify: bool) -> None:
    cmd = ["git", "commit", "-m", msg]
    if no_verify:
        cmd.insert(2, "--no-verify")
    if dry_run:
        print("+", " ".join(cmd))
        return
    proc = _run(cmd, capture=True)
    if proc.returncode != 0:
        sys.stderr.write(proc.stderr)
        raise SystemExit(proc.returncode)


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Commit each changed file separately (one commit per file) with simple messages."
    )
    parser.add_argument("--dry-run", action="store_true", help="Print actions without modifying git state.")
    parser.add_argument(
        "--message-prefix",
        default="",
        help='Optional prefix for commit messages (e.g., "docs: ").',
    )
    parser.add_argument(
        "--no-verify",
        action="store_true",
        help="Pass --no-verify to git commit.",
    )
    args = parser.parse_args(argv)

    _ensure_in_repo()
    _ensure_no_staged_changes()

    changes = _detect_changes()
    if not changes:
        print("No changes to commit.")
        return 0

    for change in changes:
        msg = _commit_message(change, args.message_prefix)
        _stage_paths(change.paths, dry_run=args.dry_run)
        _commit(msg, dry_run=args.dry_run, no_verify=args.no_verify)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
