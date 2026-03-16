# Agent Spec Template (YAML Schema)

```yaml
agent:
  name: "Canonical name of the agent"
  goal: "The high-level intent the agent fulfills"
  owner: "Responsible team or role"
  version: "1.0.0"

inputs:
  required:
    - name: "input_name"
      description: "what this input provides"
  optional:
    - name: "optional_name"
      description: "contextual booster"

artifacts:
  - name: "artifact_name"
    format: "markdown|json|table"
    template: "path/to/template.md"
    storage: "path/to/storage/"

tools:
  allowed:
    - name: "tool_name"
      purpose: "why the agent needs this"
  authority: "read-only|write-with-approval|write-autonomous"

policies_and_constraints:
  - "Must use only allowed sources."
  - "Must cite all claims."

invariants_and_gates:
  - invariant: "All citations resolve"
    gate: "tool-check"
    fail_response: "retry|ask"

budgets:
  max_tool_calls: 10
  max_retries: 2
  max_latency_seconds: 60
```
