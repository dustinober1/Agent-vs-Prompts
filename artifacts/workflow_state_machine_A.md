# Workflow State Machine: Research+Write (Case Study A)

## Architecture: Sequential Workflow with ReAct/Reflexion

### States and Transitions

| Current State | Event | Target State | Guard / Action |
| :--- | :--- | :--- | :--- |
| **Idle** | `start_request` | **Researching** | Topic valid; Checkpoint created |
| **Researching** | `sources_found` | **Drafting** | `cite_resolve` pass; Min sources met |
| **Researching** | `no_sources` | **Idle** | Notify user; Ask for clarification |
| **Researching** | `timeout` | **Researching** | Retry search (max 3) |
| **Drafting** | `draft_complete` | **Verifying** | All sections present |
| **Verifying** | `pass` | **Completed** | `redaction_check` AND `cite_resolve` GREEN |
| **Verifying** | `fail_recoverable`| **Drafting** | Reflexion protocol; Retry (max 2) |
| **Verifying** | `fail_blocking` | **Idle** | Escalate to Human; Store draft |
| **Completed** | `deliver` | **Idle** | Final artifact stored |

## Checkpoints
- **W0:** After Search (Source Inventory).
- **W1:** After Extraction (Evidence Set).
- **W2:** After Draft (Draft Brief v1).
- **W3:** After Verification (QA Report).

## Error Recovery
- **Transient (API Fail):** Exponential backoff retry.
- **Content (QA Fail):** Reflexion revision loop.
- **Policy (Redaction):** Hard stop; notify security.
