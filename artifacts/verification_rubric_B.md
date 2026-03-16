# Verification Rubric: Instructional Design (Case Study B)

## Verification Stack

| Check Name | Layer | Type | Stop-Ship? | Failure Response |
| :--- | :--- | :--- | :---: | :--- |
| **Module Valid** | 1 | Structural | No | **RETRY** draft generation |
| **Objectives Measurable** | 2 | Deterministic | No | **WARN**; Request SME review |
| **Alignment Check** | 4 | Tool | **YES** | **REGENERATE** missing items |
| **Policy Accuracy** | 4 | Tool | **YES** | **RE-FETCH**; Block if version mismatch |
| **Accessibility Check** | 4 | Tool | **YES** | **REMEDIATE** content |
| **Approvals Obtained** | 6 | Human | **YES** | **BLOCK**; Escalate to sign-off queue |

## Stop-Ship Criteria
1.  **Alignment Gap:** Any objective without practice or assessment coverage.
2.  **Stale Policy:** Referenced policy date is > 30 days old.
3.  **Accessibility Failure:** Any fail on WCAG 2.1 AA checklist.
4.  **Missing Approval:** Security or Legal sign-off missing.

## Verification Flow Decision Logic
- **Pass:** All stop-ship criteria met -> **READY TO PUBLISH**.
- **Fail (Recoverable):** Alignment gap or accessibility fail -> **RE-RUN GENERATION**.
- **Fail (Blocking):** Stale policy or missing approval -> **ESCALATE TO HUMAN**.
