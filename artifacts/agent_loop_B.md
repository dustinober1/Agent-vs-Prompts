# Agent Loop: Instructional Design (Case Study B)

## Loop Diagram (States)

```text
intake → [clarify?] → gather → [draft_obj → draft_obj_practice → draft_obj_assessment] → validate → [approve?] → export
```

## Step Table

| Step | Actions / Tools | Artifact | Gate (Pass/Fail) | Stop Behavior |
| :--- | :--- | :--- | :--- | :--- |
| **1. Intake** | parse_constraints | Constraints Spec | Learner profile present | **ASK** user |
| **2. Gather** | policy_lookup | Policy Map | Policies fresh (<30d) | **FORCE** refresh |
| **3. Obj** | draft_objectives | Objectives List | Performance-based verbs | **REVISE** |
| **4. Practice** | draft_scenarios | Scenario Bank | Scenario-policy mapping | **REGENERATE** |
| **5. Assess** | draft_assessments | Item Bank | Item-objective mapping | **REGENERATE** |
| **6. Validate** | alignment_check, accessibility_check | QA Report | Alignment = 100%; Access AA | **BLOCK** / **REVISE** |
| **7. Approve** | request_approval | Approval Log | SME / Security sign-off | **BLOCK** |
| **8. Export** | export_prep | LMS Package | Export prep successful | **DELIVER** |

## Loop Budgets

| Budget | Value | Notes |
| :--- | :--- | :--- |
| Max tool calls | 14 | Multi-stage generation |
| Max retries | 2 | Per gate failure |
| Max latency | 120s | Iterative feedback loop |
| Authority | Gated | Write requires sign-off |
