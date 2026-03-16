# Phase 03 Research: Core Building Blocks

## Case Study A: Research+Write (Functional Components)
- **Tools (Ch 8):** `internal_search`, `fetch_doc`, `extract_quotes`, `cite_resolve`, `redaction_check`.
- **Retrieval (Ch 9):** Query expansion, reranking, source-to-snippet map.
- **Planning (Ch 10):** "Researcher Plan" vs. "Writer Plan".
- **State (Ch 11):** Evidence set storage, citation-ready snippets.
- **Verification (Ch 12):** Citation resolution rubric, Redaction rule set.

## Case Study B: Instructional Design (Functional Components)
- **Tools (Ch 8):** `policy_lookup`, `alignment_check`, `accessibility_check`, `export_prep`.
- **Retrieval (Ch 9):** Policy corpus indexing, template library fetch.
- **Planning (Ch 10):** "Course Outline" as a planning artifact.
- **State (Ch 11):** Objectives-to-items mapping state.
- **Verification (Ch 12):** Alignment rubric, Accessibility checklist (automated).

## Standardizing Building Blocks
- **Tool Schema:** Use JSON Schema for tool definitions (OpenAI/Anthropic compatible).
- **State Model:** Define what persists across steps (Plan, Evidence, Artifacts, Trace).
- **Verification:** Establish "Gate" logic (Pass/Fail + Reason).
