# Chapter 14 — Multi-agent patterns: supervisor/worker, debate, routing

## Purpose
Show how to decompose responsibility without chaos.

## Reader takeaway
Multi-agent systems help when roles have clear contracts and contexts are controlled; otherwise you just multiply confusion.

## Key points
- Why multiple agents: specialization, parallelism, separation of concerns
- Architectures: supervisor→workers→aggregator; router→specialists; bounded debate
- Coordination challenges: context explosion, conflicting objectives, debugging difficulty

## Draft

### The brief that required a committee

The request seemed reasonable: produce a competitive analysis of three vendors for an enterprise software purchase. The analysis needed to be thorough (deep research on each vendor), accurate (verified claims with sources), balanced (fair treatment, no cherry-picking), and actionable (clear recommendation with rationale).

A single agent tried first. It searched, gathered sources, and produced a draft. The result was coherent but problematic: the agent had clearly "picked a favorite" by page two. It led with strengths for one vendor and weaknesses for the others. The citations were valid, but selectively chosen. The conclusion felt predetermined.

The problem wasn't capability—it was conflicting objectives. The same agent was asked to be both researcher (find everything) and advocate (make a recommendation). When tension arose between completeness and narrative clarity, the agent resolved it by favoring narrative. It told a good story, but not a balanced one.

The fix was to separate the roles. One agent researched each vendor (three parallel researchers). A synthesis agent combined findings without knowing which vendor each researcher "preferred." A critic agent reviewed the combined analysis for balance, flagging sections that showed bias. A final editor agent incorporated the critique and produced the deliverable.

The result took longer. It cost more tokens. But the analysis was balanced, the recommendation was defensible, and the stakeholders trusted it.

This is the promise—and the cost—of multi-agent systems: **separation of concerns enables capabilities that single agents can't achieve, but coordination introduces new failure modes.**

### When one agent isn't enough

Chapter 13 established that single agents can improve through ReAct, Reflexion, and tree search. These patterns help when the task is coherent—when a single perspective can execute all steps.

But some tasks resist single-agent solutions:

#### Conflicting objectives

The competitive analysis example illustrates the core problem. Some objectives are in tension:
- **Thoroughness vs. efficiency**: Find everything, but don't waste time
- **Creativity vs. accuracy**: Generate novel insights, but verify every claim
- **Advocacy vs. neutrality**: Make a recommendation, but present fairly

A single agent resolves these tensions implicitly, often in ways you can't predict or control. Multiple agents with explicit roles resolve them through structure.

#### Context window pressure

Complex tasks accumulate context: source documents, intermediate outputs, conversation history, tool results. A single agent must carry all of this, even when most of it isn't relevant to the current step.

Multiple agents can maintain **local context**: each agent sees only what it needs. The researcher doesn't need to see the final draft. The editor doesn't need to see raw search results. This is the **least-context principle**: give each role the minimum context required for its task.

#### Specialization requirements

Some tasks benefit from specialized prompts, tool access, or even different models:
- A researcher agent might have access to premium search APIs
- A writer agent might use a model tuned for fluency
- A verifier agent might use a model tuned for factual accuracy
- A policy-compliance agent might have access to internal policy documents

Single agents can switch contexts, but multiple agents can be optimized for their specific role.

#### Checks and balances

When an agent produces output and verifies its own output, it has the same biases in both roles. Chapter 12 established that verification should happen outside the model's reasoning process.

Multi-agent systems implement this literally: one agent produces, another agent verifies. They don't share biases because they don't share context.

### The supervisor/worker pattern

The most common multi-agent architecture is **supervisor/worker**: a coordinating agent delegates tasks to specialized workers, then aggregates their results.

#### How it works

```yaml
architecture:
  type: "supervisor_worker"
  
  supervisor:
    role: "coordinator"
    responsibilities:
      - interpret user request
      - decompose into subtasks
      - assign to appropriate workers
      - collect and aggregate results
      - enforce constraints (budget, policy, quality)
      - deliver final output
    
  workers:
    - role: "researcher"
      capabilities: [search, fetch, extract]
      context: "topic + search constraints"
      output: "annotated source list + quotes"
      
    - role: "writer"
      capabilities: [draft, structure]
      context: "sources + outline + style guide"
      output: "draft sections"
      
    - role: "verifier"
      capabilities: [cite_check, fact_check]
      context: "draft + sources"
      output: "verification report"
      
    - role: "editor"
      capabilities: [revise, polish]
      context: "draft + verification report"
      output: "final deliverable"
```

#### The supervisor's responsibilities

The supervisor is the control plane. It:

1. **Interprets intent**: Translates user request into structured task specification
2. **Plans execution**: Decides which workers, in what order, with what inputs
3. **Enforces constraints**: Stops execution if budget exceeded, escalates if stuck
4. **Manages handoffs**: Routes worker outputs to appropriate next workers
5. **Aggregates results**: Combines worker outputs into coherent deliverable
6. **Handles failures**: Retries, reassigns, or escalates when workers fail

The supervisor doesn't do the work—it coordinates the work.

#### Worker contracts

Each worker has a contract: explicit inputs, outputs, and constraints.

```yaml
worker_contract:
  role: "researcher"
  
  inputs:
    required:
      - name: "topic"
        type: "string"
      - name: "search_constraints"
        type: "object"
        properties:
          max_sources: "integer"
          source_types: ["web", "internal", "academic"]
          freshness: "date range"
    optional:
      - name: "prior_research"
        type: "source_list"
        
  outputs:
    - name: "sources"
      type: "source_list"
      schema: 
        - url: "string"
        - title: "string"
        - relevance_score: "float"
        - key_quotes: "string[]"
    - name: "research_summary"
      type: "string"
      max_length: 500
      
  constraints:
    - max_tool_calls: 20
    - max_tokens_output: 2000
    - must_cite_all_quotes: true
```

Clear contracts enable:
- **Substitutability**: Replace a worker with a different implementation (different model, different approach)
- **Testing**: Verify worker behavior in isolation
- **Debugging**: Identify which worker failed and why
- **Parallelism**: Run independent workers concurrently

#### Least-context principle

Give each worker only the context it needs:

| Worker | Sees | Doesn't see |
|--------|------|-------------|
| Researcher | Topic, constraints, prior research | Final draft, other sections |
| Writer | Sources, outline, style guide | Raw search logs, other drafts |
| Verifier | Draft, cited sources | Research notes, editing history |
| Editor | Draft, verification feedback | Raw sources, original topic |

Less context means:
- Fewer tokens per worker call
- Less opportunity for context to "pollute" the task
- Clearer attribution when something goes wrong

### The router/specialist pattern

When tasks can be categorized, **routing** sends each request to a specialized agent.

#### How it works

```yaml
architecture:
  type: "router_specialist"
  
  router:
    role: "classifier"
    responsibilities:
      - classify incoming request
      - route to appropriate specialist
      - handle ambiguous cases (ask for clarification or use default)
    classification_scheme:
      - category: "research_request"
        signals: ["find", "search", "what is", "summarize"]
        routes_to: "research_specialist"
      - category: "writing_request"
        signals: ["write", "draft", "compose", "create"]
        routes_to: "writing_specialist"
      - category: "analysis_request"
        signals: ["analyze", "compare", "evaluate", "assess"]
        routes_to: "analysis_specialist"
      - category: "ambiguous"
        action: "ask_for_clarification"
        
  specialists:
    research_specialist:
      focus: "information gathering"
      tools: [search, fetch, extract, cite]
      model: "high-context model"
      
    writing_specialist:
      focus: "content generation"
      tools: [outline, draft, style_check]
      model: "fluent model"
      
    analysis_specialist:
      focus: "structured reasoning"
      tools: [compare, score, visualize]
      model: "reasoning model"
```

#### When routing beats general-purpose

Routing is valuable when:
- **Specialists are significantly better** at their domain than generalists
- **Cost differs** between specialists (route simple requests to cheaper models)
- **Tool access differs** (some specialists have premium API access)
- **Context is expensive** and specialists don't need each other's history

The classic example is **model routing**: route easy questions to a fast, cheap model; route hard questions to a slow, expensive model. RouteLLM and similar approaches can reduce costs by 2-4x while maintaining quality.

#### Routing failures

Routing introduces new failure modes:

| Failure | Symptom | Mitigation |
|---------|---------|------------|
| Misclassification | Request goes to wrong specialist | Confidence thresholds; fallback to general |
| Category gaps | Request doesn't fit any category | "Catch-all" specialist or escalation |
| Cascading errors | Early misroute corrupts downstream | Validation at specialist entry |

Always include a fallback path for ambiguous cases.

### The debate pattern

When accuracy matters more than speed, **debate** pits agents against each other to surface errors.

#### How it works

```yaml
architecture:
  type: "debate"
  
  agents:
    - role: "proposer"
      task: "generate initial answer with reasoning"
      
    - role: "critic"
      task: "find flaws, counterarguments, missing considerations"
      
    - role: "judge"
      task: "evaluate arguments, determine winner, synthesize final answer"
      
  process:
    rounds: 2  # bounded!
    round_1:
      - proposer: submits initial answer
      - critic: identifies weaknesses
      - proposer: responds to critique
    round_2:
      - critic: final challenge
      - proposer: final defense
    resolution:
      - judge: evaluates exchange, produces final answer
```

#### Debate improves factuality

Research shows debate can improve factual accuracy (Du et al., 2023). The mechanism: critics are more likely to catch errors than self-review because they're *looking* for problems rather than confirming correctness.

Key finding: models are better at finding flaws in others' work than in their own. Debate exploits this asymmetry.

#### Bounded rounds are essential

Unbounded debate is dangerous:
- Agents can argue indefinitely
- Later rounds often produce diminishing returns
- Costs accumulate linearly with rounds

Always cap rounds. Two to three rounds typically capture most of the benefit. More rounds should require explicit justification.

```yaml
debate_config:
  max_rounds: 3
  early_termination:
    - condition: "consensus_reached"
    - condition: "no_new_arguments"
  budget_limit: 10000 tokens total for debate
```

#### When debate helps vs. hurts

| Scenario | Debate helps? | Why |
|----------|---------------|-----|
| Factual verification | Yes | Critics catch errors |
| Complex reasoning | Yes | Multiple perspectives surface flaws |
| Creative generation | Sometimes | Can kill good ideas through overly critical review |
| Simple classification | No | Overkill; single-pass is sufficient |
| Time-sensitive | No | Adds latency |

Debate is expensive. Reserve it for high-stakes decisions where accuracy matters more than speed.

### Coordination challenges

Multi-agent systems introduce coordination overhead. The challenges are real and often underestimated.

#### Challenge 1: Context explosion

Even with least-context principles, handoffs between agents accumulate information:
- Supervisor passes context to worker
- Worker returns results to supervisor
- Supervisor passes accumulated context to next worker
- Context grows with each hop

**Mitigation**: Summarization at handoff points. Workers return structured outputs, not raw transcripts. Supervisors maintain summary state, not full history.

```yaml
handoff:
  from: "researcher"
  to: "writer"
  
  # Don't pass this:
  raw_context:
    - full search logs (2000 tokens)
    - all retrieved documents (15000 tokens)
    - reasoning traces (3000 tokens)
    
  # Pass this instead:
  summarized_context:
    - source_list: 10 sources, 50 tokens each (500 tokens)
    - key_quotes: 20 quotes, 100 tokens each (2000 tokens)
    - research_summary: 500 tokens
    # Total: 3000 tokens vs 20000
```

#### Challenge 2: Conflicting objectives

Different workers may optimize for different things:
- Researcher wants thoroughness
- Writer wants clarity
- Editor wants brevity

When conflicts arise, who wins?

**Mitigation**: Explicit priority hierarchy defined by supervisor.

```yaml
conflict_resolution:
  hierarchy:
    1: "accuracy"  # Never sacrifice factual correctness
    2: "completeness"  # Cover required topics
    3: "clarity"  # Then optimize for readability
    4: "brevity"  # Then minimize length
    
  when_conflict:
    - log the conflict
    - apply hierarchy
    - surface to human if hierarchy doesn't resolve
```

#### Challenge 3: Blame assignment

When the final output is wrong, which agent failed?

In single-agent systems, the answer is obvious. In multi-agent systems, errors can arise from:
- Bad input from an earlier agent
- Misinterpretation during handoff
- Correct individual outputs combined incorrectly
- Supervisor coordination failure

**Mitigation**: Artifact logging at every handoff. Each agent produces a versioned artifact. Debugging traces artifacts backward to find the source of error.

```yaml
artifact_chain:
  - artifact_id: "research_v1"
    agent: "researcher"
    timestamp: "..."
    inputs: [topic, constraints]
    outputs: [source_list, summary]
    
  - artifact_id: "draft_v1"
    agent: "writer"
    timestamp: "..."
    inputs: [research_v1]
    outputs: [draft]
    
  - artifact_id: "verification_v1"
    agent: "verifier"
    timestamp: "..."
    inputs: [draft_v1, research_v1.source_list]
    outputs: [verification_report]
    
  # When final output has error:
  # Trace: final → draft_v1 → research_v1
  # Identify: research_v1 missed key source
```

#### Challenge 4: Debugging difficulty

Multi-agent systems are harder to debug than single-agent systems:
- More components to inspect
- Interactions between components
- Non-deterministic behavior multiplied

**Mitigation**: 
1. Test each agent in isolation before integration
2. Log all inter-agent communication
3. Build replay capabilities (rerun from logged state)
4. Use structured outputs for easier parsing

### The agent selection decision

When should you use multiple agents vs. a single agent?

| Factor | Single agent | Multiple agents |
|--------|--------------|-----------------|
| Task coherence | High (one perspective works) | Low (conflicting objectives) |
| Context requirements | Manageable | Exceeds context window |
| Specialization benefit | Low | High |
| Latency tolerance | Low (need fast response) | High (quality over speed) |
| Debugging resources | Limited | Adequate for distributed debugging |
| Cost sensitivity | High | Lower (willing to pay for quality) |

**Start single, go multi when you hit a wall.**

The default should be single-agent with patterns from Chapter 13. Multi-agent adds complexity. Add that complexity only when single-agent patterns can't solve the problem.

## Case study thread

### Research+Write (Policy change brief)

The policy brief uses a supervisor/worker architecture with four specialized roles.

#### Role specifications

```yaml
roles:
  supervisor:
    name: "brief_coordinator"
    responsibilities:
      - interpret brief request
      - decompose into research topics
      - assign researchers
      - route research to writer
      - route draft to auditor
      - route audited draft to editor
      - enforce citation and confidentiality policies
      - deliver final brief
    policies:
      - all claims must have citations
      - no internal-only content in external briefs
      - budget: 50000 tokens total
      
  workers:
    - name: "researcher"
      inputs:
        - topic: string
        - source_constraints: {internal: bool, web: bool, freshness: date}
      outputs:
        - sources: source_list
        - quotes: quote_list
        - summary: string (max 500 tokens)
      constraints:
        - max 15 sources per topic
        - must extract quotes, not paraphrase
        
    - name: "writer"
      inputs:
        - sources: source_list
        - quotes: quote_list
        - brief_template: template
        - style_guide: document
      outputs:
        - draft: markdown document
        - citation_map: {claim_id: source_id}
      constraints:
        - every factual claim must map to a source
        - follow template structure
        
    - name: "citation_auditor"
      inputs:
        - draft: markdown document
        - citation_map: {claim_id: source_id}
        - sources: source_list
      outputs:
        - audit_report: {valid: claim_id[], invalid: claim_id[], missing: claim_id[]}
        - recommendations: string[]
      constraints:
        - verify each citation resolves
        - verify quote appears in source
        - flag claims without citations
        
    - name: "editor"
      inputs:
        - draft: markdown document
        - audit_report: object
      outputs:
        - final_brief: markdown document
        - change_log: string[]
      constraints:
        - address all audit findings
        - preserve citation integrity
        - do not add unsupported claims
```

#### Execution flow

```
User Request
    ↓
[Supervisor: interpret + plan]
    ↓
[Researcher] → sources + quotes
    ↓
[Supervisor: route to writer]
    ↓
[Writer] → draft + citation_map
    ↓
[Supervisor: route to auditor]
    ↓
[Citation Auditor] → audit_report
    ↓
[Supervisor: check audit status]
    ↓
  ┌─ If audit fails → [Writer: revise] → re-audit (max 2 times)
  └─ If audit passes → [Editor] → final_brief
    ↓
[Supervisor: deliver or escalate]
```

### Instructional Design (Annual compliance training)

The training module uses a more complex pipeline with five specialized roles and explicit alignment checkpoints.

#### Role specifications

```yaml
roles:
  supervisor:
    name: "curriculum_coordinator"
    responsibilities:
      - interpret training request
      - gather constraints (audience, time, policies)
      - orchestrate role pipeline
      - enforce alignment at each checkpoint
      - manage approvals
      - deliver final package
    policies:
      - alignment rubric must pass before proceeding
      - accessibility checks required
      - SME approval before final delivery
      
  workers:
    - name: "objectives_mapper"
      inputs:
        - job_role: string
        - policies: document_list
        - constraints: {time: duration, modality: string}
      outputs:
        - objectives: objective_list  # observable, measurable
        - policy_mapping: {objective_id: policy_section}
      constraints:
        - objectives must be performance-based
        - each objective must map to policy requirement
        
    - name: "assessment_designer"
      inputs:
        - objectives: objective_list
        - constraints: {question_types: string[], passing_score: float}
      outputs:
        - assessments: {objective_id: assessment_item[]}
        - rubrics: {assessment_id: rubric}
      constraints:
        - every objective must have at least one assessment
        - rubrics must define passing criteria
        
    - name: "activity_designer"
      inputs:
        - objectives: objective_list
        - assessments: assessment_list
        - constraints: {time_per_objective: duration, modalities: string[]}
      outputs:
        - activities: {objective_id: activity[]}
        - scenarios: scenario_list
      constraints:
        - activities must prepare learners for assessments
        - scenarios must be job-relevant
        
    - name: "accessibility_reviewer"
      inputs:
        - activities: activity_list
        - scenarios: scenario_list
        - assessments: assessment_list
      outputs:
        - accessibility_report: {passed: bool, issues: issue_list}
        - remediation_suggestions: string[]
      constraints:
        - check WCAG compliance
        - flag cognitive overload
        - ensure multiple modalities available
        
    - name: "alignment_qa"
      inputs:
        - objectives: objective_list
        - activities: activity_list
        - assessments: assessment_list
      outputs:
        - alignment_matrix: {objective_id: {has_activity: bool, has_assessment: bool}}
        - gaps: gap_list
        - recommendations: string[]
      constraints:
        - every objective must have practice AND assessment
        - flag any orphan content
```

#### Execution flow with checkpoints

```
User Request
    ↓
[Supervisor: gather constraints]
    ↓
[Objectives Mapper] → objectives + policy_mapping
    ↓
[Supervisor: checkpoint 1 - objectives review]
    ↓
[Assessment Designer] → assessments + rubrics
    ↓
[Activity Designer] → activities + scenarios (parallel with assessments)
    ↓
[Alignment QA] → alignment_matrix + gaps
    ↓
[Supervisor: checkpoint 2 - alignment gate]
    ↓
  ┌─ If gaps → [Assessment/Activity Designer: fill gaps] → re-check
  └─ If aligned → proceed
    ↓
[Accessibility Reviewer] → accessibility_report
    ↓
[Supervisor: checkpoint 3 - accessibility gate]
    ↓
  ┌─ If issues → [Activity Designer: remediate] → re-check
  └─ If passed → proceed
    ↓
[Supervisor: SME approval request]
    ↓
[Supervisor: deliver package or incorporate feedback]
```

## Artifacts to produce

- **Role specifications** for each case study (inputs, outputs, constraints)
- **Supervisor policies** (what the coordinator enforces)
- **Handoff schemas** (what passes between agents)
- **Checkpoint definitions** (where human approval is required)

## Chapter exercise

Design roles for both case studies and define each role's input/output contract.

### Part 1: Define your roles

For each case study, identify:

1. What specialized roles are needed?
2. What is each role's primary responsibility?
3. What tools/capabilities does each role need?

### Part 2: Define role contracts

For each role:

1. What are the required inputs? (types, constraints)
2. What are the outputs? (types, schemas)
3. What constraints govern the role's behavior?
4. What policies must the role follow?

### Part 3: Define the supervisor

1. What does the supervisor enforce?
2. When does the supervisor intervene?
3. What are the escalation conditions?
4. What handoff points exist?

### Part 4: Map failure modes

For your multi-agent system:

1. What can go wrong between agents?
2. How will you detect each failure?
3. How will you recover or escalate?
4. How will you debug after the fact?

## Notes / references

- AutoGen (multi-agent conversation): Wu et al., "AutoGen: Enabling Next-Gen LLM Applications via Multi-Agent Conversation" (2023) — https://arxiv.org/abs/2308.08155
- CAMEL (role-playing agents): Li et al., "CAMEL: Communicative Agents for 'Mind' Exploration of Large Language Model Society" (2023) — https://arxiv.org/abs/2303.17760
- Society of Mind agents: Zhuge et al., "Mindstorms in Natural Language-Based Societies of Mind" (2023) — https://arxiv.org/abs/2305.17066
- Multi-agent debate: Du et al., "Improving Factuality and Reasoning in Language Models through Multiagent Debate" (2023) — https://arxiv.org/abs/2305.14325
- RouteLLM (model routing): Ong et al., "RouteLLM: Learning to Route LLMs with Preference Data" (2024) — https://arxiv.org/abs/2406.18665
- AgentCoder (multi-agent coding): Huang et al., "AgentCoder: Multi-Agent-based Code Generation with Iterative Testing and Optimisation" (2024) — https://arxiv.org/abs/2312.13010
- LangGraph: https://langchain-ai.github.io/langgraph/
- CrewAI: https://www.crewai.com/

