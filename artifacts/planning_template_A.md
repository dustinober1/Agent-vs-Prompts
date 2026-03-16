# Planning Template: Research+Write (Case Study A)

## Goal
Draft a policy change brief grounded in verified internal sources.

## Task Graph

```yaml
plan:
  id: "policy_brief_A"
  steps:
    - id: 1
      name: "Intake & Clarify"
      action: "parse_request"
      produces: ["requirements_artifact"]
      checkpoint: "all_required_inputs_present"
      on_fail: "ask_user"

    - id: 2
      name: "Research & Inventory"
      action: "internal_search"
      produces: ["source_inventory"]
      checkpoint: "at_least_one_current_source"
      on_fail: "expand_search"

    - id: 3
      name: "Retrieve & Verify"
      action: "fetch_doc"
      inputs: ["source_inventory"]
      produces: ["retrieved_docs"]
      checkpoint: "primary_source_verified_current"
      on_fail: "backtrack_to_step_2"

    - id: 4
      name: "Extract Evidence"
      action: "extract_quotes"
      inputs: ["retrieved_docs"]
      produces: ["evidence_set"]
      checkpoint: "claim_coverage_gt_80pct"
      on_fail: "targeted_search"

    - id: 5
      name: "Draft & Cite"
      action: "generate_brief"
      inputs: ["evidence_set", "template"]
      produces: ["draft_brief"]
      checkpoint: "all_citations_present"
      on_fail: "revise_draft"

    - id: 6
      name: "Final Verification"
      action: "run_qa_suite"
      inputs: ["draft_brief"]
      produces: ["validation_report"]
      checkpoint: "all_verifications_pass"
      on_fail: "remediate_or_escalate"
```

## Checkpoint Details

| Checkpoint | What is checked | Failure Response |
| :--- | :--- | :--- |
| **Inputs Present** | audience, scope, policy_id | **ASK** user clarifying questions |
| **Current Source** | `doc.status == 'current'` | **REJECT** archived docs; retry search |
| **Claim Coverage** | ratio of claims to excerpts | **MARK** `[NEEDS SOURCE]` on gaps |
| **QA Suite** | `cite_resolve`, `redaction_check` | **BLOCK** release on redaction fail |
