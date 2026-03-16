# Verification Rubric: Research+Write (Case Study A)

## Verification Stack

| Check Name | Layer | Type | Stop-Ship? | Failure Response |
| :--- | :--- | :--- | :---: | :--- |
| **Markdown Valid** | 1 | Structural | No | **RETRY** draft generation |
| **Sections Present** | 1 | Structural | No | **RETRY** draft generation |
| **Citations Resolve** | 4 | Tool | **YES** | **RE-RETRIEVE** or **MARK** `[NEEDS SOURCE]` |
| **Quotes Match** | 4 | Tool | **YES** | **RE-FETCH** and **RE-EXTRACT** |
| **Policy Current** | 4 | Tool | **YES** | **BLOCK**; Escalate to Policy Owner |
| **Redaction Check** | 2 | Deterministic | **YES** | **BLOCK**; Hard stop on confidential leak |
| **Claim Mapping** | 3 | Cross-validation | **YES** | **RE-DRAFT** unsupported sections |

## Stop-Ship Criteria
1.  **Redaction Failure:** Any match for confidential patterns.
2.  **Citation Failure:** Any key claim without a resolving Tier 1 citation.
3.  **Freshness Failure:** Any referenced policy is superseded.

## Verification Report Schema (JSON)
```json
{
  "artifact_id": "string",
  "status": "passed|failed|warning",
  "checks": [
    {
      "name": "string",
      "status": "passed|failed",
      "details": "string|object"
    }
  ],
  "decision": "deliver|revise|block",
  "next_action": "string"
}
```
