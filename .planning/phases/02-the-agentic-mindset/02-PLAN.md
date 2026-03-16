---
phase: 02
slug: the-agentic-mindset
status: draft
wave: 0
depends_on: [01]
---

# Phase 02 Plan: The Agentic Mindset

The goal of this phase is to refine Chapters 5-7 and establish the system architecture for the running case studies. This includes defining the system boundaries, degrees of agency, and the canonical agent loop for both Case Study A and B.

## Tasks

<tasks>
  <task id="02-01-01" wave="0">
    <description>Initialize Phase 2 infrastructure and validation.</description>
    <action>Create `scripts/validate-phase-2.sh` to track artifact creation and chapter refinement.</action>
  </task>

  <task id="02-02-01" wave="1">
    <description>Refine Chapter 5 and establish Agent Specs.</description>
    <action>Update `chapters/05-*.md` to include the systems boundary mental model. Create `artifacts/agent_spec_A_research_write.yaml` and `artifacts/agent_spec_B_instructional_design.yaml` based on the YAML schema.</action>
  </task>

  <task id="02-02-02" wave="2">
    <description>Refine Chapter 6 and establish MVA Decision Records.</description>
    <action>Update `chapters/06-*.md`. Create `artifacts/mva_A_research_write.md` and `artifacts/mva_B_instructional_design.md` to document the rung choice, autonomy, and authority for each agent.</action>
  </task>

  <task id="02-02-03" wave="3">
    <description>Refine Chapter 7 and establish Agent Loops.</description>
    <action>Update `chapters/07-*.md`. Create `artifacts/agent_loop_A.md` and `artifacts/agent_loop_B.md` to define the Plan-Act-Observe-Reflect states, stopping conditions, and budgets.</action>
  </task>

  <task id="02-03-01" wave="4">
    <description>Finalize Phase 2 Cross-References and Validation.</description>
    <action>Ensure Chapters 5-7 are fully cross-referenced to artifacts. Run the `scripts/validate-phase-2.sh` suite.</action>
  </task>
</tasks>

## Verification Criteria

### Automated Tests
- [x] `scripts/validate-phase-2.sh` returns exit code 0.
- [x] `grep` confirms "Agent Spec" in `chapters/05-*.md`.
- [x] `grep` confirms "MVA Decision Record" in `chapters/06-*.md`.
- [x] `grep` confirms "Agent Loop" in `chapters/07-*.md`.
- [x] Artifact count for Phase 2 = 6 (2 specs, 2 MVAs, 2 loops).

### Manual Quality Gates
- [x] **Systemic Logic**: Verify that the "Inside/Outside Model" boundaries are logically consistent across Chapters 5 and 6.
- [x] **Operational Feasibility**: Review the budgets and stop conditions in Chapter 7 artifacts for real-world practicality.
