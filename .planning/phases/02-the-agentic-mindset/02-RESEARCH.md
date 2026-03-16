# Phase 02 Research: The Agentic Mindset

## Objectives
- [ ] Review Chapters 5-7 for structural consistency with the "systems engineering" argument.
- [ ] Identify precise "Invariants" and "Gates" for Case Study A (Research+Write).
- [ ] Identify precise "Invariants" and "Gates" for Case Study B (Instructional Design).
- [ ] Standardize the YAML schema for the "Agent Spec".

## Case Study A: Research+Write (Refinement)
- **Model Role:** Drafting, summarizing, clarifying, extracting claims.
- **Tool Role:** Retrieval (Search/Fetch), Citation Resolution, Redaction Check.
- **Invariants:** 
  - Citation resolution success = 100%.
  - Claim-to-source coverage > 90%.
  - Redaction hit count = 0.

## Case Study B: Instructional Design (Refinement)
- **Model Role:** Objectives drafting, scenario generation, assessment writing.
- **Tool Role:** Policy lookup, Template fetch, Alignment check, Accessibility check.
- **Invariants:**
  - Alignment gap count = 0 (Objective <-> Practice <-> Assessment).
  - Accessibility checklist score = 100%.
  - Policy freshness < 30 days.

## Agent Spec YAML Schema (Draft)
```yaml
agent:
  name: string
  version: semver
  goal: string
inputs:
  required: [{name, type, desc}]
  optional: [{name, type, desc}]
artifacts:
  - name: string
    template_path: string
    validation: [schema|rubric|tool]
tools:
  allowlist: [string]
  authority: read|write-gated|autonomous
invariants:
  - condition: string
    gate: string
    on_fail: retry|ask|block
budgets:
  max_tool_calls: int
  max_retries: int
  max_latency: int
```
