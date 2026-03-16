# Workflow State Machine: Instructional Design (Case Study B)

## Architecture: Parallel Supervisor/Worker Workflow with HITL Gates

### States and Transitions

| Current State | Event | Target State | Guard / Action |
| :--- | :--- | :--- | :--- |
| **Intake** | `confirm_req` | **Design_Obj** | All constraints present |
| **Design_Obj** | `obj_ready` | **Awaiting_Approve** | Objectives measurable |
| **Awaiting_Approve** | `approved` | **Gen_Content** | SME sign-off captured |
| **Awaiting_Approve** | `rejected` | **Design_Obj** | Feedback attached |
| **Gen_Content** | `items_ready` | **QA_Check** | Scenario + Assessment count met |
| **QA_Check** | `pass` | **Awaiting_Final** | Alignment 100% AND Access AA |
| **QA_Check** | `fail` | **Gen_Content** | Remediate specific items |
| **Awaiting_Final** | `signed_off` | **Exporting** | Compliance team sign-off |
| **Exporting** | `success` | **Completed** | LMS package created |

## Parallel Execution (in Gen_Content)
- **Worker 1:** Scenario Designer.
- **Worker 2:** Assessment Designer.
- **Join Condition:** Both complete -> Trigger `items_ready`.

## Checkpoints
- **C0:** Approved Objectives.
- **C1:** Full Module Artifact (pre-QA).
- **C2:** QA Report.
- **C3:** Final Approved Package.

## Queue Config
- **Design Requests:** Priority based on deadline.
- **Accessibility Reviews:** Throttled to 20/hour.
