---
phase: 03
slug: core-building-blocks
status: draft
wave: 0
depends_on: [02]
---

# Phase 03 Plan: Core Building Blocks

The goal of this phase is to refine Chapters 8-12 and define the functional components (tools, retrieval, planning, state, and verification) that bring the agent loop to life.

## Tasks

<tasks>
  <task id="03-01-01" wave="0">
    <description>Initialize Phase 3 infrastructure and validation.</description>
    <action>Create `scripts/validate-phase-3.sh` to track artifact creation and chapter refinement.</action>
  </task>

  <task id="03-02-01" wave="1">
    <description>Refine Chapter 8 and define Tool Interfaces.</description>
    <action>Update `chapters/08-*.md`. Create `artifacts/tool_schemas_A.json` and `artifacts/tool_schemas_B.json` based on the Research map.</action>
  </task>

  <task id="03-02-02" wave="2">
    <description>Refine Chapter 9 and define Retrieval & Grounding logic.</description>
    <action>Update `chapters/09-*.md`. Create `artifacts/retrieval_map_A.md` and `artifacts/retrieval_map_B.md` for source-to-snippet management.</action>
  </task>

  <task id="03-02-03" wave="3">
    <description>Refine Chapter 10 and define Planning & Task Decomposition.</description>
    <action>Update `chapters/10-*.md`. Create `artifacts/planning_template_A.md` and `artifacts/planning_template_B.md` for structured multi-step plans.</action>
  </task>

  <task id="03-02-04" wave="4">
    <description>Refine Chapter 11 and define State & Memory management.</description>
    <action>Update `chapters/11-*.md`. Create `artifacts/state_model_A.yaml` and `artifacts/state_model_B.yaml` for persistent trace/artifact storage.</action>
  </task>

  <task id="03-02-05" wave="5">
    <description>Refine Chapter 12 and define Verification rubrics & Gates.</description>
    <action>Update `chapters/12-*.md`. Create `artifacts/verification_rubric_A.md` and `artifacts/verification_rubric_B.md` for pass/fail gates.</action>
  </task>

  <task id="03-03-01" wave="6">
    <description>Finalize Phase 3 Cross-References and Validation.</description>
    <action>Ensure Chapters 8-12 are fully cross-referenced to artifacts. Run the `scripts/validate-phase-3.sh` suite.</action>
  </task>
</tasks>

## Verification Criteria

### Automated Tests
- [x] `scripts/validate-phase-3.sh` returns exit code 0.
- [x] `grep` confirms "Tool Schema" in `chapters/08-*.md`.
- [x] `grep` confirms "Retrieval Map" in `chapters/09-*.md`.
- [x] `grep` confirms "Planning Template" in `chapters/10-*.md`.
- [x] `grep` confirms "State Model" in `chapters/11-*.md`.
- [x] `grep` confirms "Verification Rubric" in `chapters/12-*.md`.
- [x] Artifact count for Phase 3 = 10 (2 schemas, 2 maps, 2 plans, 2 state models, 2 rubrics).

### Manual Quality Gates
- [x] **Functional Alignment**: Verify that the tool schemas, retrieval logic, and verification rubrics are consistent with the Agent Specs and MVAs from Phase 2.
- [x] **Technical Detail**: Review JSON schemas and YAML models for correct formatting and practical utility.
