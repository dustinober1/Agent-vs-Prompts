# Project Conventions

This document outlines the naming and formatting conventions used in the "Stop Prompt Engineering" project.

## File Naming Conventions

### Chapters
- **Format:** `XX-kebab-case-title.md`
- **Example:** `01-the-uncomfortable-truth-about-better-prompts.md`
- **Numbering:** Two-digit prefix (`01`, `02`, ..., `22`) followed by a kebab-case version of the chapter title.

### Templates
- **Format:** `prefix_UPPERCASE_TEMPLATE.md` or `_chapter_TEMPLATE.md`
- **Examples:** 
  - `_chapter_TEMPLATE.md` (in `chapters/`)
  - `instructional_design_compliance_training_MODULE_TEMPLATE.md` (in `case_studies/`)
  - `research_write_policy_change_brief_TEMPLATE.md` (in `case_studies/`)

## Formatting Standards (Markdown)

### Chapter Structure
All chapters should follow the structure defined in `chapters/_chapter_TEMPLATE.md`:

1.  **Title (H1):** `# Chapter X — <Title>`
2.  **Purpose (H2):** High-level goal of the chapter.
3.  **Reader Takeaway (H2):** The primary lesson for the reader.
4.  **Key Points (H2):** Bulleted list of core concepts.
5.  **Draft (H2):** The main content of the chapter, using H3 for sub-sections.
6.  **Case study thread (H2):** (Optional/Template) Integration of the two core case studies.
7.  **Artifacts to produce (H2):** (Optional/Template) Expected outputs.
8.  **Chapter exercise (H2):** (Optional/Template) Practical application for the reader.
9.  **Notes / references (H2):** (Optional/Template) Supporting links and citations.

### Visual Elements
- **Lists:** Use hyphens (`-`) for bulleted lists.
- **Code Blocks:** Use triple backticks (`` ` ``) for code snippets or text-based diagrams.
- **Emphasis:** Use standard Markdown for *italics* and **bold**.

## Language and Tone
- **Tone:** Professional, senior-level engineering perspective, direct, and pedagogical.
- **Terminology:** Consistent use of terms defined in `BOOK_OUTLINE.md` (e.g., "agentic system," "prompting plateau," "agent loop").
