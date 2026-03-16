# Phase 01: Foundation and The Prompting Plateau - Context

**Gathered:** 2026-03-15
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase delivers the foundational first part of the book (Chapters 1-4) and defines the baseline failure modes and prompt debt for the two running case studies (Research+Write and Instructional Design). It establishes the "prompting plateau" concept and sets the stage for the transition to agentic systems.

</domain>

<decisions>
## Implementation Decisions

### Artifact Location and Format
- **Standalone Artifacts**: All production artifacts (checklists, budgets, maps, eval sets) will be stored in a dedicated `/artifacts/` directory.
- **Embedded Context**: Copies of these artifacts will be embedded directly within the relevant chapter Markdown files to provide reading context for the audience.
- **Artifacts to Produce (Phase 1)**:
  - Chapter 1: Baseline prompts (Full Context), plateau symptom checklist, system-required needs list.
  - Chapter 2: Failure budget for both case studies.
  - Chapter 3: Prompt-Component Map, Prompt Change Log Convention, Minimal Eval Set Outline.
  - Chapter 4: Prompt surface area budget, "prompt vs system" checklist, "small prompts" per agent.

### Case Study Detail
- **Full Context**: The "intentionally naive" baseline prompts and failure mode definitions will be fully documented with full context and examples, rather than just simple summaries. This ensures they are diagnostic and usable for testing the "agentic" improvements later in the book.

### Claude's Discretion
- **Draft Refinement**: Claude has discretion to refine the existing chapter drafts to ensure consistency with the book's thesis and the newly defined artifacts.
- **Artifact Templates**: Claude can design the specific Markdown structure for the checklists and budgets in `/artifacts/`.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `chapters/_chapter_TEMPLATE.md`: Standard structure for all book chapters.
- `case_studies/*_TEMPLATE.md`: Core templates for the case study deliverables.

### Established Patterns
- **Case Study Integration**: The project uses a "Case Study Thread" section in each chapter to tie the theoretical concepts to the two running examples.
- **Markdown Format**: All content is authored in Markdown.

### Integration Points
- `chapters/`: All book content.
- `case_studies/`: Base templates for agents.
- `artifacts/`: (New) Standalone production deliverables.

</code_context>

<specifics>
## Specific Ideas
- The "intentionally naive" prompts should reflect common "tweak-and-pray" behaviors described in Chapter 1.
- Chapter 2 failure modes should map directly to the "Seven Failure Modes" taxonomy.

</specifics>

<deferred>
## Deferred Ideas
- None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-foundation-the-prompting-plateau*
*Context gathered: 2026-03-15*
