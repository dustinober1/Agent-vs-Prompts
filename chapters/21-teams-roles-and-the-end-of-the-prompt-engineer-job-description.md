# Chapter 21 — Teams, roles, and the end of the "prompt engineer" job description

## Purpose
Translate the technical shift into an organizational one.

## Reader takeaway
Agentic systems require ownership of tools, evals, reliability, and policy—prompting becomes one part of a broader engineering discipline.

## Key points
- Roles: agent/product engineer, evaluator, reliability/LLMOps, domain experts (policy/compliance)
- Workflow: artifact-based collaboration; version everything (prompts, tools, policies, datasets)
- Career transition: from prompt tricks to systems, APIs, and measurement

## Draft

### The job posting that started an argument

The hiring manager stared at the feedback from the interview panel. Two engineers had scored the candidate "strong hire." Two had scored them "no hire." The disagreement wasn't about skills—it was about the role itself.

"She's a fantastic prompt engineer," one supporter wrote. "She optimized our summarization prompts and improved ROUGE scores by 15%."

"We don't need better prompts," countered a detractor. "We need someone who can build the orchestration layer, design evals, and debug production failures. She doesn't have that."

The candidate had spent two years as a "Prompt Engineer," a title that had commanded premium salaries in 2023. But the team was shipping agentic systems now, and the requirements had shifted. The question wasn't whether she was talented—she clearly was. The question was whether the job she'd mastered still existed.

This chapter isn't about whether prompt engineers should find new careers. It's about how the work of making LLM systems reliable has expanded, specialized, and matured—and how teams need to reorganize to match.

### The end of the generalist prompt role

The "prompt engineer" title emerged during a specific moment: when the primary interface to LLM capability was the prompt itself. If you could write better instructions, you could unlock better outputs. This was true, and still is—for narrow tasks.

But Part I of this book documented why prompting alone doesn't scale. Part III showed what you need instead: tools, retrieval, planning, state, and verification. Parts IV and V covered the patterns and operational practices that make agents reliable. Each of these requires different skills.

**What changed:**

```yaml
prompt_engineering_era:
  primary_artifact: "The prompt"
  success_metric: "Output quality on test cases"
  debugging_method: "Read output, tweak prompt, retry"
  collaboration: "Prompt author works alone or with domain expert"
  time_horizon: "Single inference"
  
agentic_systems_era:
  primary_artifacts:
    - agent_spec: "Goal, constraints, stopping conditions"
    - tool_contracts: "Inputs, outputs, permissions"
    - eval_suites: "Golden sets, adversarial tests, rubrics"
    - observability_config: "Traces, metrics, alerts"
    - prompt_templates: "One component among many"
    
  success_metric: "End-to-end reliability, cost, latency, safety"
  debugging_method: "Read traces, isolate failure, test hypotheses"
  collaboration: "Cross-functional: product, eng, domain, compliance"
  time_horizon: "Workflow (minutes to hours), deployment (weeks)"
```

The shift isn't that prompting stopped mattering. It's that prompting became one skill among several, and the other skills are now load-bearing.

### The new role map

Agentic systems require specialized ownership. Here's a map of the roles that have emerged:

#### Role 1: Agent/Product Engineer

**Owns:** System design, tool orchestration, API contracts, UX flows

**What they do:**
- Design the agent's goal structure and stopping conditions
- Build tool integrations with proper error handling and retries
- Implement the orchestration layer (state machines, queues, workflows)
- Own the user experience: streaming, progressive disclosure, confirmation gates
- Debug production issues end-to-end

**Background:** Typically software engineering or product engineering. They understand distributed systems, API design, and user experience.

**Not their job:** Optimizing prompts in isolation, writing evals from scratch, defining compliance policy.

```yaml
agent_engineer_outputs:
  spec: "Agent goal, constraints, tools, budget, stopping conditions"
  code: "Orchestration logic, tool implementations, error handling"
  config: "Model routing, caching, timeouts, rate limits"
  review: "End-to-end integration tests, production readiness"
```

#### Role 2: Evaluation Engineer

**Owns:** Eval suites, datasets, quality metrics, regression detection

**What they do:**
- Build golden sets that represent real user scenarios
- Design rubrics for subjective quality (tone, accuracy, helpfulness)
- Implement adversarial tests (prompt injection, edge cases)
- Create regression detection pipelines
- Maintain eval infrastructure (data versioning, run tracking)

**Background:** ML engineering, data science, or QA with ML experience. They understand metrics, sampling, and experimental design.

**Not their job:** Building the agent itself, defining business requirements, responding to production incidents.

```yaml
evaluation_engineer_outputs:
  datasets:
    - golden_set: "500 representative queries with expected outputs"
    - adversarial_set: "100 prompt injection and edge case scenarios"
    - regression_baseline: "Versioned outputs from last stable release"
    
  metrics:
    - factuality: "claim_accuracy on verified facts"
    - format: "schema_compliance_rate"
    - safety: "refusal_rate on policy violations"
    - quality: "rubric_score from LLM-as-judge"
    
  pipelines:
    - "nightly_regression_run"
    - "pre_deploy_eval_gate"
    - "weekly_adversarial_audit"
```

#### Role 3: Reliability/LLMOps Engineer

**Owns:** Observability, incident response, SLAs, infrastructure

**What they do:**
- Instrument tracing across the agent workflow
- Build dashboards for cost, latency, error rates
- Respond to production incidents (what broke, why, how to fix)
- Manage model deployments, canaries, and rollbacks
- Implement guardrails: budget limits, rate limits, kill switches

**Background:** Platform engineering, SRE, or DevOps with LLM-specific experience. They understand distributed tracing, alerting, and incident management.

**Not their job:** Designing the agent's business logic, writing evals, or negotiating with compliance.

```yaml
llmops_engineer_outputs:
  observability:
    - traces: "Per-step spans with tool calls and model responses"
    - dashboards: "Cost by feature, latency p99, error breakdown"
    - alerts: "Cost spike, latency degradation, failure rate increase"
    
  reliability:
    - runbooks: "Agent stuck in loop, model timeout, quota exceeded"
    - rollback_plan: "Revert to last known good config in < 5 minutes"
    - budget_guards: "Hard limits by user tier, feature, and request"
    
  infrastructure:
    - deployment: "Canary → 10% → 50% → 100% with eval gates"
    - scaling: "Auto-scale based on queue depth and latency"
```

#### Role 4: Domain Expert / Policy Owner

**Owns:** Business rules, compliance requirements, approval authority

**What they do:**
- Define which outputs are acceptable (accuracy, tone, legal risk)
- Review high-stakes agent decisions before they execute
- Maintain policy documentation that agents reference
- Sign off on agent capabilities that touch regulated domains

**Background:** Legal, compliance, HR, subject matter expertise, or senior business leadership. They don't need to code—but they need to understand what agents can and can't do.

**Not their job:** Building agents, debugging code, or responding to technical incidents.

```yaml
domain_expert_outputs:
  policies:
    - "Approved sources list (with freshness requirements)"
    - "Redaction rules for PII and confidential information"
    - "Escalation criteria for human review"
    
  approvals:
    - "New tool capability requiring production data access"
    - "Agent expansion into regulated domain (HR, finance, legal)"
    - "Prompt or policy changes affecting compliance"
    
  review_gates:
    - "Monthly audit of agent outputs in high-risk areas"
    - "Quarterly compliance review of tool permissions"
```

### The RACI matrix for agent ownership

With multiple roles, ownership must be explicit. Here's a RACI (Responsible, Accountable, Consulted, Informed) matrix for common agent lifecycle activities:

```yaml
agent_raci_matrix:
  activities:
    
    design_agent_spec:
      responsible: "Agent Engineer"
      accountable: "Product Lead"
      consulted: ["Domain Expert", "Eval Engineer"]
      informed: ["LLMOps"]
      
    implement_tool_integration:
      responsible: "Agent Engineer"
      accountable: "Agent Engineer"
      consulted: ["LLMOps", "Security"]
      informed: ["Eval Engineer"]
      
    create_eval_suite:
      responsible: "Eval Engineer"
      accountable: "Eval Engineer"
      consulted: ["Domain Expert", "Agent Engineer"]
      informed: ["Product Lead"]
      
    instrument_observability:
      responsible: "LLMOps Engineer"
      accountable: "LLMOps Engineer"
      consulted: ["Agent Engineer"]
      informed: ["Product Lead", "Eval Engineer"]
      
    approve_policy_change:
      responsible: "Domain Expert"
      accountable: "Compliance Lead"
      consulted: ["Agent Engineer", "Legal"]
      informed: ["LLMOps", "Eval Engineer"]
      
    respond_to_incident:
      responsible: "LLMOps Engineer"
      accountable: "On-Call Engineer"
      consulted: ["Agent Engineer"]
      informed: ["Product Lead", "Domain Expert"]
      
    deploy_to_production:
      responsible: "LLMOps Engineer"
      accountable: "Agent Engineer"
      consulted: ["Eval Engineer"]
      informed: ["Product Lead", "Domain Expert"]
```

The pattern: Agent Engineers own the system. Eval Engineers own quality assurance. LLMOps owns production health. Domain Experts own policy sign-off. Product Leads are accountable for outcomes.

### Artifact-based collaboration

Traditional collaboration models break down with agentic systems. You can't review a "prompt" in a PR if the prompt is one of twenty components that affect behavior. You can't QA an agent by clicking through it manually—the space of behaviors is too large.

**What works: artifacts as the unit of collaboration.**

```yaml
collaboration_artifacts:
  agent_spec:
    what: "Formal definition of goal, constraints, tools, budget"
    version_controlled: true
    reviewed_by: ["Agent Engineer", "Product Lead", "Domain Expert"]
    change_requires: "PR with linked eval results"
    
  tool_contract:
    what: "Schema, permissions, error codes, rate limits"
    version_controlled: true
    reviewed_by: ["Agent Engineer", "Security", "LLMOps"]
    change_requires: "PR with integration test results"
    
  prompt_template:
    what: "System prompt, few-shot examples, output format"
    version_controlled: true
    reviewed_by: ["Agent Engineer", "Eval Engineer"]
    change_requires: "PR with regression eval results"
    
  eval_dataset:
    what: "Golden inputs, expected outputs, rubric criteria"
    version_controlled: true
    reviewed_by: ["Eval Engineer", "Domain Expert"]
    change_requires: "PR with dataset diff and justification"
    
  policy_config:
    what: "Approved sources, redaction rules, escalation criteria"
    version_controlled: true
    reviewed_by: ["Domain Expert", "Compliance", "Legal"]
    change_requires: "Formal approval workflow"
```

**The change request pattern:**

Every change to an agentic system should be a coherent bundle: prompt + tools + evals + config, reviewed and tested together.

```yaml
agent_change_request:
  template:
    title: "Short description of change"
    motivation: "Why this change is needed"
    
    changes:
      prompts: "[list of prompt file changes]"
      tools: "[list of tool code changes]"
      configs: "[list of config changes]"
      evals: "[list of eval changes]"
      policies: "[list of policy changes]"
      
    evaluation:
      regression_results: "[link to eval run]"
      new_test_results: "[link to new test results]"
      adversarial_results: "[link to adversarial run]"
      
    rollback_plan: "How to revert if issues found"
    
    approvals_required:
      - "Eval Engineer (if eval changes)"
      - "LLMOps (if deployment config changes)"
      - "Domain Expert (if policy changes)"
      
  example:
    title: "Update citation format for policy briefs"
    motivation: "Users requested inline citations instead of footnotes"
    
    changes:
      prompts: ["brief_generator_v3.yaml"]
      tools: []
      configs: []
      evals: ["citation_format_test_v2.json"]
      policies: []
      
    evaluation:
      regression_results: "Run #4582: 98.3% pass (baseline: 98.1%)"
      new_test_results: "Run #4583: 45/45 inline citation tests pass"
      adversarial_results: "Run #4584: No new failures"
      
    rollback_plan: "Revert brief_generator_v3.yaml to v2"
    
    approvals_required: ["Eval Engineer"]
```

### The career transition

For people currently in "prompt engineering" roles, the path forward isn't abandonment—it's expansion.

**Skills to add:**

```yaml
career_expansion_paths:
  toward_agent_engineering:
    existing_strength: "Understanding LLM behavior and capabilities"
    skills_to_add:
      - "Distributed systems basics (state, queues, retries)"
      - "API design and integration"
      - "Orchestration frameworks (LangGraph, Temporal, custom)"
      - "Production debugging (traces, logs, metrics)"
    learning_path:
      - "Build a multi-step agent with tool calls"
      - "Implement retry logic and error handling"
      - "Add observability and debug a production issue"
      
  toward_evaluation_engineering:
    existing_strength: "Judging LLM output quality"
    skills_to_add:
      - "Dataset design and sampling"
      - "Metrics and measurement"
      - "Automated testing infrastructure"
      - "Statistical significance and A/B testing"
    learning_path:
      - "Build a golden set from production logs"
      - "Implement an LLM-as-judge rubric"
      - "Create a regression detection pipeline"
      
  toward_llmops:
    existing_strength: "Understanding model behavior under different conditions"
    skills_to_add:
      - "Observability (OpenTelemetry, tracing)"
      - "Incident response and runbooks"
      - "Cost and latency optimization"
      - "Deployment automation (CI/CD for ML)"
    learning_path:
      - "Instrument an agent with traces"
      - "Build a cost attribution dashboard"
      - "Write a runbook for a common failure mode"
```

**What stays valuable:**

The core skill of prompt engineering—understanding how to communicate intent to LLMs—remains essential. It's not deprecated; it's contextualized. Prompts still matter for:

- Tool selection guidance
- Output formatting
- Voice and tone
- Guardrail instructions

But these prompts exist within a system, not as the system. The prompt engineer who can also build that system becomes an agent engineer. The one who can also measure that system becomes an evaluator. The one who can also run that system becomes LLMOps.

### Organizational patterns for AI teams

Different organizations structure AI teams differently. Here are three patterns we've seen work:

#### Pattern 1: Embedded specialists

AI roles are distributed across product teams, with a central platform providing infrastructure.

```yaml
embedded_pattern:
  product_team_composition:
    - "Product Manager"
    - "2 Backend Engineers"
    - "1 Agent Engineer (embedded)"
    - "0.5 Eval Engineer (shared across 2 teams)"
    
  central_platform_provides:
    - "Observability infrastructure"
    - "Eval pipeline infrastructure"
    - "Model gateway and routing"
    - "Security review process"
    
  pros:
    - "Deep product context"
    - "Fast iteration"
    - "Clear ownership"
    
  cons:
    - "Inconsistent practices across teams"
    - "Duplicated effort"
    - "Harder to share learnings"
```

#### Pattern 2: Centralized AI team

A dedicated AI team builds and maintains all agentic features.

```yaml
centralized_pattern:
  ai_team_composition:
    - "AI Team Lead"
    - "3 Agent Engineers"
    - "2 Eval Engineers"
    - "1 LLMOps Engineer"
    - "Domain experts consulted per project"
    
  relationship_to_product:
    - "Product teams submit feature requests"
    - "AI team prioritizes and builds"
    - "Product teams own UX and integration"
    
  pros:
    - "Consistent practices"
    - "Efficient resource use"
    - "Concentrated expertise"
    
  cons:
    - "Bottleneck risk"
    - "Slower feedback loops"
    - "Less product context"
```

#### Pattern 3: Hub-and-spoke

A central AI platform team sets standards and provides infrastructure, while product teams have embedded AI engineers who follow those standards.

```yaml
hub_and_spoke_pattern:
  central_hub:
    - "Platform team: infrastructure, standards, review"
    - "Sets architectural patterns"
    - "Runs security and compliance reviews"
    - "Maintains shared eval and observability tools"
    
  spokes:
    - "Embedded Agent Engineers in product teams"
    - "Follow platform standards"
    - "Build product-specific agents"
    - "Submit to platform review for production"
    
  coordination:
    - "Weekly AI guild meeting (learnings, patterns)"
    - "Shared prompt and tool libraries"
    - "Rotation program between hub and spokes"
    
  pros:
    - "Best of both worlds"
    - "Scales with organization"
    - "Maintains consistency"
    
  cons:
    - "Requires coordination overhead"
    - "Potential for friction between hub and spokes"
```

### Definition of done for agent features

The final organizational shift: agreeing on what "done" means for an agent feature.

```yaml
agent_definition_of_done:
  design_complete:
    - "Agent spec reviewed and approved by Product + Domain Expert"
    - "Tool contracts reviewed by Security"
    - "Eval plan reviewed by Eval Engineer"
    
  implementation_complete:
    - "All tools implemented with error handling"
    - "Orchestration logic tested"
    - "Prompts versioned and reviewed"
    
  evaluation_complete:
    - "Golden set: >= 95% pass rate"
    - "Adversarial set: >= 90% pass rate"
    - "Regression baseline established"
    
  observability_complete:
    - "Traces instrumented for all steps"
    - "Dashboard created with key metrics"
    - "Alerts configured for anomalies"
    
  production_ready:
    - "Rollback plan documented"
    - "Runbook created for common failures"
    - "Budget guards configured"
    - "Canary deployment plan approved"
    
  sign_off:
    - "Agent Engineer: implementation complete"
    - "Eval Engineer: quality gates pass"
    - "LLMOps: production readiness verified"
    - "Domain Expert: policy compliance verified"
    - "Product Lead: ready for users"
```

## Case study thread

### Research+Write (Policy change brief)

The brief agent requires clear ownership boundaries.

#### Ownership map

```yaml
brief_ownership:
  sources_and_retrieval:
    owner: "Agent Engineer"
    approver: "Information Security"
    responsibilities:
      - "Which sources are searchable"
      - "How documents are fetched and cached"
      - "Access control enforcement"
      
  citation_policy:
    owner: "Domain Expert (Communications/Legal)"
    approver: "Legal"
    responsibilities:
      - "Required citation format"
      - "Minimum source requirements"
      - "Prohibited source types"
      
  redaction_rules:
    owner: "Information Security"
    approver: "Compliance"
    responsibilities:
      - "PII detection and redaction"
      - "Confidentiality classification"
      - "Data loss prevention"
      
  publication_approval:
    owner: "Domain Expert (Content Owner)"
    approver: "Communications Lead"
    responsibilities:
      - "Final review before external publication"
      - "Tone and accuracy sign-off"
      - "Distribution channel selection"
      
  quality_and_evals:
    owner: "Eval Engineer"
    approver: "Agent Engineer"
    responsibilities:
      - "Citation verification tests"
      - "Factuality spot checks"
      - "Format compliance tests"
      
  production_operations:
    owner: "LLMOps Engineer"
    approver: "Engineering Lead"
    responsibilities:
      - "Uptime and latency SLAs"
      - "Cost monitoring and alerts"
      - "Incident response"
```

### Instructional Design (Annual compliance training)

The training agent spans multiple organizational domains.

#### Ownership map

```yaml
training_ownership:
  learning_design:
    owner: "L&D Instructional Designer"
    approver: "L&D Lead"
    responsibilities:
      - "Learning objectives and outcomes"
      - "Activity and assessment design"
      - "Pedagogical approach"
      
  policy_content:
    owner: "Policy Subject Matter Expert (Security, HR, Legal)"
    approver: "Compliance Lead"
    responsibilities:
      - "Policy accuracy and currency"
      - "Regulatory alignment"
      - "Annual review and updates"
      
  accessibility:
    owner: "Accessibility Specialist (or L&D)"
    approver: "HR/Compliance"
    responsibilities:
      - "WCAG compliance"
      - "Screen reader compatibility"
      - "Captioning and transcripts"
      
  lms_export_and_operations:
    owner: "LMS Administrator / LLMOps"
    approver: "IT Lead"
    responsibilities:
      - "SCORM/xAPI packaging"
      - "LMS integration testing"
      - "Completion tracking and reporting"
      
  audit_and_compliance:
    owner: "Compliance Team"
    approver: "Chief Compliance Officer"
    responsibilities:
      - "Audit readiness"
      - "Completion rate monitoring"
      - "Regulatory reporting"
      
  quality_and_evals:
    owner: "Eval Engineer"
    approver: "L&D Lead"
    responsibilities:
      - "Alignment rubric (objectives ↔ assessments)"
      - "Reading level verification"
      - "Accessibility checks"
```

## Artifacts to produce
- A RACI matrix for each agent and a "definition of done" checklist

## Chapter exercise
Map your org's responsibilities to roles and identify missing ownership:

1. List every artifact your agent produces or consumes (prompts, tools, configs, policies, evals)
2. For each artifact, identify: Who creates it? Who reviews it? Who approves changes?
3. Create a RACI matrix with the four roles (Agent Engineer, Eval Engineer, LLMOps, Domain Expert)
4. Identify gaps:
   - Artifacts with no owner
   - Artifacts with no reviewer
   - Roles that no one currently fills
   - Approvals that happen informally (or not at all)
5. Propose a "definition of done" checklist for your agent, covering design, implementation, evaluation, and production readiness

## Notes / references
- The shift from "prompt engineer" to "AI engineer" mirrors earlier industry transitions (e.g., "webmaster" → specialized frontend/backend/DevOps roles)
- RACI matrices are standard project management tools; the challenge with AI is identifying the right activities to map
- Artifact-based collaboration is inspired by infrastructure-as-code practices; treat prompts, tools, and evals as code artifacts
- The hub-and-spoke pattern is common in organizations scaling platform teams; see Spotify's "squad" model for analogous structures
- "Definition of done" checklists reduce ambiguity and prevent shipping incomplete features; they're especially important for probabilistic systems where "it works on my examples" is insufficient
