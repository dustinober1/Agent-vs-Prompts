# MVA Decision Record Template

```yaml
feature:
  name: "Feature name"
  user_job: "The specific problem the user is solving"
  primary_artifact: "The main output produced"

acceptance_criteria:
  required_sections: []
  grounding:
    citations_required: true
    allowed_sources: []
    freshness_cutoff: "e.g., 30 days"
  safety_constraints: []

agency_choice:
  rung: 1-7 (from Chapter 6)
  autonomy: "low|medium|high"
  authority: "read-only|write-with-approval|write-autonomous"
  rationale: "Why this rung?"

tools:
  allowlist: []
  write_tools_require_approval: []

gates:
  - name: "Gate name"
    type: "schema|rubric|tool-check|human-approval"
    fail_response: "retry|revise|ask|escalate|block"

budgets:
  max_tool_calls: 0
  max_retries_per_gate: 0
  max_latency_seconds: 0
  max_cost_usd: 0

stopping_conditions: ["success", "budget exceeded", "needs approval"]
```
