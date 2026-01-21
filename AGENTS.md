# Repository Guidelines

## Project Structure
This repository is a writing project (no application code).

- `BOOK_OUTLINE.md`: Canonical table of contents, chapter goals, and case study thread.
- `chapters/`: Per-chapter working drafts/stubs (e.g., `chapters/01-...md` through `chapters/22-...md`).
- `chapters/_chapter_TEMPLATE.md`: Starting point for new chapters or rewrites.
- `case_studies/`: Reusable templates and artifacts referenced across chapters.

If you add assets later, use `assets/` (images/diagrams) and reference them from chapter Markdown.

## Writing & Local Preview
There is no build/test pipeline yet. Use your editor’s Markdown preview or GitHub rendering.

Helpful commands:
- `git status -sb`: See what changed.
- `git diff`: Review edits before committing.
- `grep -R "TODO" -n chapters case_studies`: Find unfinished sections.

## Style & Naming Conventions
- Markdown only; keep structure consistent with `BOOK_OUTLINE.md`.
- Use descriptive headings and short bullet lists; avoid long, unbroken paragraphs.
- File naming:
  - Chapters: `chapters/NN-short-title.md` (two-digit order, kebab-case).
  - Templates: `*_TEMPLATE.md` in `case_studies/`.
- When adding claims, prefer grounding (links, doc IDs, quotes). Avoid “confident but uncited” assertions.

## “Testing” / Consistency Checks
Instead of tests, validate consistency:
- Chapter number/title matches the outline.
- Case study references point to the correct templates in `case_studies/`.
- No broken internal links; remove stale TODOs when completing sections.

## Commits & Pull Requests
Commit messages should be short, imperative, and specific (e.g., “Add chapter 03 first draft”, “Refine case study templates”).

For PRs:
- Summarize what changed and why.
- List touched chapters (paths) and any outline updates.
- Keep changes scoped; avoid reorganizing filenames/structure without a clear reason.

