# HITL Protocol: Instructional Design (Case Study B)

## Purpose
Ensure that high-stakes training content is aligned with policy and pedagogical standards through explicit human approval gates.

## Approval Gates

| Gate ID | Stage | Approver Role | Context Provided | Failure Action |
| :--- | :--- | :--- | :--- | :--- |
| **G0** | Objectives | SME (Subject Matter Expert) | Policy-to-Objective Map | **REVISE** Objectives |
| **G1** | Assessment | Instructional Designer | Obj-to-Assessment Alignment | **REGENERATE** Items |
| **G2** | Final Export | Compliance Team | Full QA Report + Accessibility Score | **BLOCK** Export |

## Transparency Signals (What the user sees)
- **"Drafting Objectives..."** (Progress bar: 2/5 topics mapped)
- **"Alignment Check in progress..."** (Matrix view of Obj <-> Assessment)
- **"Accessibility Scan complete."** (Score: 92/100; List of remediation items)

## Confidence Calibration
- **High:** "This objective is directly required by Policy SEC-001."
- **Medium:** "Based on the learner profile, this scenario is highly relevant."
- **Low:** "I've drafted a placeholder for the Privacy section; please provide the latest SOP."

## Fallback / Escalate
- **If timeout (48h):** Notify L&D Manager.
- **If rejection:** Supervisor parses feedback and re-routes to Worker.
- **If "Needs Help":** Agent pauses and asks specific clarifying question.
