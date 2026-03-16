# Agent Loop: Research+Write (Case Study A)

## Loop Diagram (States)

```text
intake → [clarify?] → plan → [retrieve → extract → draft] → verify → [revise?] → deliver
```

## Step Table

| Step | Actions / Tools | Artifact | Gate (Pass/Fail) | Stop Behavior |
| :--- | :--- | :--- | :--- | :--- |
| **1. Intake** | parse_request | Clarified Req | All required inputs present | **ASK** user |
| **2. Plan** | generate_plan | Step Plan | Plan matches tools | **RETRY** |
| **3. Retrieve** | internal_search, fetch_doc | Evidence Set | Source IDs resolve | **RETRY** / **FAIL** |
| **4. Extract** | extract_quotes | Claim-Source Map | Quote-claim mapping complete | **RETRY** |
| **5. Draft** | generate_brief | Draft Brief | Template structure match | **REGENERATE** |
| **6. Verify** | cite_resolve, redaction_check | QA Report | Citations resolve; Redaction passes | **BLOCK** / **FIX** |
| **7. Deliver** | format_output | Final Brief | All gates GREEN | **DELIVER** |

## Loop Budgets

| Budget | Value | Notes |
| :--- | :--- | :--- |
| Max tool calls | 12 | Prevents search loops |
| Max retries | 2 | Per gate failure |
| Max latency | 90s | End-to-end |
| Authority | Read-Only | No automated publishing |
