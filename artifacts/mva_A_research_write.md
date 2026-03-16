# MVA Decision Record: Research+Write (Case Study A)

```yaml
feature:
  name: "Policy Change Brief Draft"
  user_job: "Summarize policy changes so stakeholders can understand the impact."
  primary_artifact: "Policy Change Brief (Markdown)"

acceptance_criteria:
  required_sections: ["Background", "What Changed", "Impact", "Required Actions"]
  grounding:
    citations_required: true
    allowed_sources: ["internal_policy_wiki"]
    freshness_cutoff: "none (use latest available)"
  safety_constraints: ["No internal-only details if audience is External"]

agency_choice:
  rung: 6 (Plan-and-execute)
  autonomy: "high"
  authority: "read-only"
  rationale: "Requires multi-step planning (search -> fetch -> extract -> draft) and verification that claims are grounded in specific sources."

tools:
  allowlist: ["internal_search", "fetch_doc", "cite_resolve", "redaction_check"]
  write_tools_require_approval: []

gates:
  - name: "Citation Resolution"
    type: "tool-check"
    fail_response: "retry"
  - name: "Redaction Check"
    type: "tool-check"
    fail_response: "block"
  - name: "Claim Coverage"
    type: "rubric-check"
    fail_response: "ask"

budgets:
  max_tool_calls: 12
  max_retries_per_gate: 2
  max_latency_seconds: 90
  max_cost_usd: 0.50

stopping_conditions: ["all gates pass", "max tool calls exceeded", "redaction failure"]
```
