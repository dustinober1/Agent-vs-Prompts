# Project Concerns and Potential Debt

This document identifies areas where the "Agent-vs-Prompts" project currently faces challenges, missing content, or structural debt that should be addressed to ensure a high-quality, consistent reader experience.

## 1. Content Gaps & Missing Appendices
The project is remarkably complete in its core chapters (01–22), but several supporting components mentioned in the `BOOK_OUTLINE.md` are missing:
- **Missing Appendix A (Glossary):** Mentioned in the Table of Contents but has no corresponding section or file.
- **Missing Appendix C (Templates):** Mentioned in the TOC but has no corresponding section or file.
- **Partial Appendix D (Case Study Build Logs):** While Appendix D is outlined in `BOOK_OUTLINE.md`, the actual "build logs" and "anchor artifacts" (completed examples of the agents' outputs) are not present in the repository.
- **Appendix B (Checklists):** Only exists as an outline within the `BOOK_OUTLINE.md` file, rather than a standalone, usable artifact for readers.

## 2. Case Study Implementation Debt
The case studies are the backbone of the book's practical advice, but their implementation in the repository is currently limited:
- **Templates Only:** The `case_studies/` directory contains only templates (`MODULE_TEMPLATE.md` and `TEMPLATE.md`). It lacks the "Anchor Artifacts" (completed example outputs) that would demonstrate the "Success criteria" described in the chapters.
- **Missing Build Logs:** The `BOOK_OUTLINE.md` refers to build logs that adapt the case studies, but these are not yet written.
- **Exercise Solutions:** Most chapters include a "Chapter Exercise," but there are no sample solutions or "golden answers" provided for readers to verify their understanding.

## 3. Structural and Formatting Inconsistencies
While the chapters are high-quality, there are minor inconsistencies that could lead to "formatting debt" as the project grows:
- **Heading Casing:** Some chapters use Title Case for second-level headers (e.g., `## Reader Takeaway` in Chapter 01) while others use sentence case (e.g., `## Reader takeaway` in Chapter 17).
- **Subheading Inconsistency:** Case study thread subheadings vary slightly in their naming and casing across chapters (e.g., `Research+Write (Policy change brief)` vs `Research+Write (Policy Change Brief)`).
- **Template Remnants:** The `chapters/_chapter_TEMPLATE.md` file contains numerous "TODO" placeholders. While useful for development, it should be isolated or cleared once the chapters are finalized.

## 4. Technical and Operational Debt
The book provides concrete technical examples (Python, YAML, JSON Schema), but the repository lacks the infrastructure to support them:
- **No Executable Code:** There are no Python scripts, `requirements.txt`, or `package.json` files to allow readers to run the examples locally. The examples exist only as Markdown code blocks.
- **Model Volatility:** The chapters use specific model versions (e.g., `gpt-4o-2024-08-06`). These will date quickly and will require a strategy for regular updates or more generalized naming.
- **Lack of Integration Tests:** There is no mechanism to verify that the JSON schemas or code snippets provided in the chapters are actually valid and functional.

## 5. Project Documentation and Navigability
- **Missing Root README:** There is no `README.md` at the project root to orient new contributors or readers. `BOOK_OUTLINE.md` serves as the primary source of truth but lacks "how to contribute" or "repository structure" details.
- **Minimal Directory Documentation:** The `README.md` files in `chapters/` and `case_studies/` are extremely sparse and provide little value beyond stating the obvious.
- **Hidden Planning Directory:** The `.planning/` directory exists but is underutilized and its purpose is not documented within the repo.

## 6. Maintenance Concerns
- **Case Study Thread Redundancy:** The "Case study thread" in every chapter is a powerful teaching tool but also a maintenance risk. Updating a case study's core logic might require surgical edits across 22 files.
- **Cross-Reference Brittle-ness:** As chapters are edited, internal references to other chapters (e.g., "as we saw in Chapter 16") may become incorrect if chapters are reordered or split.
