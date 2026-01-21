---
name: git-commit-per-file
description: Stage and commit changes in a git repository with one commit per changed file (add/update/delete/rename). Use when the user asks to commit changes, wants per-file commits at the end of a run, or requests an “auto-commit” workflow; does not push unless explicitly requested.
---

# Git Commit Per File

## Overview

Create clean, reviewable git history by committing each changed file separately with simple, consistent commit messages.

## Quick start (recommended)

1. Ensure you’re in the target repo and have no staged changes:
   - `git diff --cached --name-only`
2. Run the script (dry-run first if unsure):
   - `python3 "$CODEX_HOME/skills/git-commit-per-file/scripts/commit_per_file.py" --dry-run`
   - `python3 "$CODEX_HOME/skills/git-commit-per-file/scripts/commit_per_file.py"`

If `$CODEX_HOME` isn’t set, the default is usually `~/.codex`:
- `python3 ~/.codex/skills/git-commit-per-file/scripts/commit_per_file.py`

## Workflow (do this at the end of a run)

1. Check for staged changes
   - If `git diff --cached --name-only` outputs anything, stop and ask what to do (the script refuses to run to avoid mixing commits).

2. Commit each changed file
   - Prefer the script for correctness across add/update/delete/rename.
   - Default commit messages:
     - `Add <path>`
     - `Update <path>`
     - `Delete <path>`
     - `Rename <old> to <new>`

3. Do not push unless explicitly requested
   - This skill only commits locally. If the user asks to push, do it as a separate, explicit step.

## Manual fallback (no script)

If you can’t access the script, use this loop:
1. List changes: `git status --porcelain`
2. For each changed path:
   - `git add -A -- <path>`
   - `git commit -m "Update <path>"`

Handle renames as one commit for both paths (old+new).

## Resources (optional)

### scripts/
Use `scripts/commit_per_file.py` to commit one file at a time with safe defaults and a `--dry-run` mode.
