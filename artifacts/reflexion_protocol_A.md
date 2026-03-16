# Reflexion Protocol: Research+Write (Case Study A)

## Purpose
Improve the quality of the policy brief draft by explicitly analyzing failures and revising based on feedback.

## Configuration
| Parameter | Value |
| :--- | :--- |
| **Max Attempts** | 3 |
| **Required Improvement** | True (Weighted score must increase) |
| **Escalation Trigger** | 2 consecutive failed attempts |

## Step 1: Evaluate
Score the initial draft against the **Verification Rubric A**.
- **Metrics:** Coverage, Citation Accuracy, Redaction, Tone.

## Step 2: Reflect
If the score is below threshold (e.g., < 0.85), generate a reflection:
- **What went wrong:** (e.g., "The draft missed the impact on third-party vendors.")
- **What to fix:** (e.g., "Explicitly retrieve the Vendor SOP and add a section on third-party data handling.")

## Step 3: Revise
Generate a new draft using the original plan + the reflection notes.

## Step 4: Re-Evaluate
Repeat Step 1. If improvement is not met or max attempts reached, **ESCALATE** to human review.
