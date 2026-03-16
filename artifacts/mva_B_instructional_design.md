# MVA Decision Record: Instructional Design (Case Study B)

```yaml
feature:
  name: "Annual Compliance Training"
  user_job: "Design a training module that ensures learners are compliant with latest company policies."
  primary_artifact: "Training Module (Markdown + LMS export)"

acceptance_criteria:
  required_sections: ["Learning Objectives", "Instructional Content", "Practice Activities", "Assessment"]
  grounding:
    citations_required: true
    allowed_sources: ["current_SOPs", "training_templates"]
    freshness_cutoff: "30 days"
  safety_constraints: ["Meets accessibility AA standards"]

agency_choice:
  rung: 6 (Fixed workflow with strong validators)
  autonomy: "medium"
  authority: "write-with-approval"
  rationale: "Requires a fixed sequence (Objectives -> Practice -> Assessment) and strong validators for alignment and accessibility."

tools:
  allowlist: ["policy_lookup", "alignment_check", "accessibility_check", "export_prep"]
  write_tools_require_approval: ["export_prep"]

gates:
  - name: "Alignment Rubric"
    type: "rubric-check"
    fail_response: "retry"
  - name: "Accessibility Checklist"
    type: "tool-check"
    fail_response: "block"
  - name: "Approval Log"
    type: "human-approval"
    fail_response: "ask"

budgets:
  max_tool_calls: 14
  max_retries_per_gate: 2
  max_latency_seconds: 120
  max_cost_usd: 1.00

stopping_conditions: ["all gates pass", "approval denied", "max retries exceeded"]
```
