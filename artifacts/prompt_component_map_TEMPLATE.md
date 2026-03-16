# Prompt-Component Map Template

Use this template to document and modularize "prompt debt" by breaking a mega-prompt into focused components.

| Component | Purpose | Inputs (required) | Outputs | Invariants (validated) | Failure Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Router** | Determine intent and plan steps | User request; Available tools | Structured Plan (JSON) | Plan matches tool capabilities | **ASK** for clarification |
| **Researcher** | Analyze sources and extract quotes | Source docs; Research goals | Annotated Quotes (Markdown) | Every quote has a valid Source ID | **RETRY** retrieval |
| **Writer** | Draft content based on research | Annotated quotes; Template | Draft (Markdown) | Matches template structure | **REGENERATE** section |
| **Verifier** | Check for specific failure modes | Draft; Sources; Rubric | Pass/Fail + Reason (JSON) | Citation/Alignment/Safety check | **BLOCK** release; Flag for fix |
