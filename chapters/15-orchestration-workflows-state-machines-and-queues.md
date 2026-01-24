# Chapter 15 — Orchestration: workflows, state machines, and queues

## Purpose
Translate agent behavior into reliable software.

## Reader takeaway
Lock steps when you need guarantees; allow autonomy when you need flexibility. Orchestration is the layer that makes the difference between a demo and a production system.

## Key points
- Workflow vs agent: when to lock steps, when to allow autonomy
- Orchestration primitives: state machines, event-driven triggers, queues, concurrency limits, timeouts
- Artifact management: drafts, revisions, citations—deterministic storage for reproducibility
- Durable execution: checkpoints, failure recovery, and resumable workflows

## Draft

### The agent that forgot where it was

The first version of the policy brief agent was impressive in demos. It searched for sources, extracted quotes, drafted sections, and produced polished briefs. Stakeholders loved it. Then it hit production.

A user requested a competitive analysis requiring research across three vendor documentation sites. The agent started well—found sources for the first vendor, began extracting quotes. Forty-five seconds in, the third-party search API timed out. The agent's context was lost. When the user retried, it started from scratch, re-searching the first vendor as if nothing had happened.

The fix seemed simple: catch the exception and retry the API call. But the problem ran deeper. Even when the API call succeeded, the agent had no memory of *where it was in the task*. It tracked conversation history—what messages were exchanged—but not task state: which vendors had been researched, which sources had been approved, which draft sections existed.

The agent needed orchestration: a system layer that manages task state, handles failures gracefully, and can resume from where it left off.

This is the gap between "agent that can do the task" and "system that reliably completes the task." Chapter 14 showed how to decompose responsibility across multiple agents. This chapter shows how to make those agents—single or multi—run reliably in production.

### The orchestration spectrum

Not every task needs the same level of control. Some tasks benefit from tight constraints; others need flexibility. The key is knowing when to lock steps and when to allow autonomy.

#### Locked workflows: when predictability matters

**Locked workflows** define the exact sequence of steps. The system—not the LLM—decides what happens next. The LLM executes individual steps but doesn't choose which step to execute.

```yaml
locked_workflow:
  name: "policy_brief_v1"
  
  steps:
    - step: "research"
      action: "search_and_extract"
      inputs: [topic, constraints]
      outputs: [sources, quotes]
      
    - step: "outline"
      action: "generate_outline"
      inputs: [sources, quotes, template]
      outputs: [outline]
      
    - step: "draft"
      action: "write_sections"
      inputs: [outline, sources, style_guide]
      outputs: [draft]
      
    - step: "verify"
      action: "check_citations"
      inputs: [draft, sources]
      outputs: [verification_report]
      
    - step: "finalize"
      action: "apply_feedback"
      inputs: [draft, verification_report]
      outputs: [final_brief]
```

With locked workflows:
- Each step has defined inputs and outputs
- Transitions are explicit and deterministic
- The system knows exactly where it is at all times
- Failures can be retried without re-executing earlier steps

#### Autonomous agents: when flexibility matters

**Autonomous agents** decide their own next actions. The LLM observes the current state and chooses what to do. This is the ReAct pattern from Chapter 13, extended to full task control.

```yaml
autonomous_agent:
  name: "policy_brief_agent"
  
  tools: [search, fetch, extract, draft, verify]
  
  loop:
    - observe: "current state of the brief"
    - reason: "what should I do next?"
    - act: "call appropriate tool"
    - update: "record results"
    - check: "is the brief complete?"
```

With autonomous agents:
- The agent handles novel situations adaptively
- Execution paths can vary by request
- Less upfront specification required
- Harder to predict, debug, and verify

#### The decision framework

| Factor | Locked workflow | Autonomous agent |
|--------|-----------------|------------------|
| Task predictability | High (known steps) | Low (variable paths) |
| Failure recovery needs | Critical | Best-effort acceptable |
| Auditability requirements | High (compliance, legal) | Lower |
| Development velocity | Slower (specify all paths) | Faster (emergent behavior) |
| Debugging difficulty | Easier (deterministic) | Harder (non-deterministic) |
| Novel situation handling | Poor (not in workflow) | Good (can adapt) |

**Start with workflows, add autonomy where needed.**

Most production systems land in the middle: a workflow shell that calls agents for specific steps. The workflow handles orchestration (what happens when, what to do on failure); the agent handles execution (how to accomplish each step).

### State machines for agent control

A **state machine** is a model where the system exists in one of a finite number of states, transitions between states based on events, and each state defines allowed actions.

State machines provide the backbone for orchestration.

#### Anatomy of an agent state machine

```yaml
state_machine:
  name: "brief_workflow"
  initial: "pending"
  
  states:
    pending:
      on_enter: "log workflow started"
      transitions:
        - event: "start"
          target: "researching"
          guard: "has_valid_topic"
          
    researching:
      on_enter: "invoke research agent"
      transitions:
        - event: "research_complete"
          target: "outlining"
        - event: "research_failed"
          target: "research_error"
        - event: "timeout"
          target: "research_timeout"
          
    research_error:
      on_enter: "notify user of failure"
      transitions:
        - event: "retry"
          target: "researching"
          guard: "retry_count < 3"
        - event: "escalate"
          target: "human_review"
          
    outlining:
      on_enter: "invoke outline agent"
      transitions:
        - event: "outline_complete"
          target: "drafting"
        - event: "needs_more_research"
          target: "researching"
          
    # ... remaining states
    
    completed:
      on_enter: "deliver final artifact"
      type: "final"
```

#### Key properties

1. **Explicit states**: The system is always in exactly one state. No ambiguity about "where we are."

2. **Defined transitions**: Every possible event has a defined handler. Unexpected events can be caught and logged.

3. **Guards**: Conditions that must be true for a transition to fire. Guards prevent invalid state changes.

4. **Entry/exit actions**: Code that runs when entering or leaving a state. Useful for logging, notifications, and cleanup.

5. **Hierarchy**: States can contain substates for complex flows without explosion of top-level states.

#### State machine benefits for agents

| Benefit | How it helps |
|---------|--------------|
| Debuggability | Inspect current state at any time |
| Resumability | Save state and resume later |
| Error isolation | Failures are contained to states |
| Auditability | State transitions form an audit log |
| Testing | Test each state and transition in isolation |

### Event-driven triggers

Agents don't always run synchronously. Some tasks take minutes or hours. Some require human input. Some depend on external systems. **Event-driven orchestration** decouples "start the work" from "respond to the result."

#### Common trigger patterns

**Webhook triggers**: External systems notify when something happens.

```yaml
trigger:
  type: "webhook"
  source: "document_management_system"
  event: "new_policy_published"
  
action:
  workflow: "policy_brief_update"
  input_mapping:
    policy_id: "{{ event.policy_id }}"
    change_type: "{{ event.change_type }}"
```

**Scheduled triggers**: Time-based execution.

```yaml
trigger:
  type: "schedule"
  cron: "0 8 * * MON"  # Every Monday at 8am
  
action:
  workflow: "weekly_compliance_check"
```

**Human approval triggers**: Resume on user action.

```yaml
trigger:
  type: "human_approval"
  waiting_for: "manager_sign_off"
  timeout: "48h"
  
on_approve:
  target_state: "publishing"
  
on_reject:
  target_state: "revision_requested"
  
on_timeout:
  target_state: "escalated"
```

**Completion triggers**: Chain workflows together.

```yaml
trigger:
  type: "workflow_complete"
  workflow: "research_phase"
  status: "success"
  
action:
  workflow: "drafting_phase"
  input_mapping:
    sources: "{{ previous.outputs.sources }}"
```

#### The event-driven mental model

Think of your agent system as an event processor:
- Events arrive from various sources (users, APIs, schedules, other agents)
- Events trigger state transitions
- State transitions trigger actions
- Actions produce new events

This model naturally handles long-running tasks, human-in-the-loop flows, and multi-system integrations.

### Queues and background jobs

When agent tasks take longer than a request-response cycle, you need **background jobs** and **queues**.

#### Why queues matter

1. **Decoupling**: The user doesn't wait for the agent to finish. They submit a request and get notified later.

2. **Load management**: Queues absorb bursts. If 100 users submit briefs at once, the system processes them at sustainable rate.

3. **Retry semantics**: If a job fails, the queue can hold it for retry without re-submitting.

4. **Priority handling**: Urgent requests can jump the queue.

#### Queue architecture for agents

```yaml
queue_system:
  queues:
    - name: "brief_requests"
      priority_enabled: true
      visibility_timeout: "5m"  # Time to process before requeue
      max_retries: 3
      dead_letter_queue: "brief_failures"
      
    - name: "bulk_research"
      concurrency_limit: 5  # Max parallel workers
      rate_limit: "10/minute"  # Throttle external API calls
      
  workers:
    - name: "brief_worker"
      queue: "brief_requests"
      handler: "execute_brief_workflow"
      timeout: "10m"
```

#### Job lifecycle

```
1. Submit: User submits brief request
   → Job enters queue with ID "job-123"
   → User receives "job-123" for tracking

2. Dequeue: Worker picks up job
   → Job becomes "in-progress"
   → Visibility timeout starts

3. Execute: Worker runs workflow
   → State machine progresses through states
   → Checkpoints saved at each step

4. Complete or fail:
   → Success: Job marked complete, user notified
   → Failure: Job returned to queue (if retries left)
   → Exhausted: Job moved to dead-letter queue
```

### Concurrency limits and rate limiting

Multiple agents running in parallel create coordination challenges. Concurrency limits and rate limits prevent overload.

#### Concurrency limits

Limit how many instances of a workflow can run simultaneously.

```yaml
concurrency:
  workflow: "research_phase"
  limit: 10
  
  # When limit reached:
  behavior: "queue"  # or "reject"
```

Why concurrency limits matter:
- **External API quotas**: Search APIs have rate limits. Too many parallel researches exhausts quota.
- **Resource contention**: Running too many LLM calls can exhaust token budgets.
- **Database pressure**: Heavy concurrent writes can overwhelm storage.

#### Rate limiting

Limit how frequently operations can occur.

```yaml
rate_limits:
  - scope: "user"
    resource: "brief_creation"
    limit: "10/hour"
    
  - scope: "global"
    resource: "search_api_calls"
    limit: "100/minute"
    
  - scope: "workflow"
    resource: "llm_tokens"
    limit: "1000000/day"
```

Rate limit strategies:
- **Sliding window**: Track operations over rolling time period
- **Token bucket**: Allow bursts up to bucket size, refill over time
- **Leaky bucket**: Smooth out traffic to constant rate

### Cancellation and timeouts

Long-running tasks need graceful cancellation. Stuck tasks need timeouts.

#### Implementing cancellation

```yaml
cancellation:
  workflow: "policy_brief"
  
  on_cancel:
    - save_partial_work: true
    - notify_user: "Your brief was cancelled. Partial work saved."
    - cleanup:
        - release_locks
        - mark_artifacts_as_incomplete
        
  propagation:
    - cancel_child_workflows: true
    - wait_for_cleanup: "30s"
```

Cancellation is harder than it sounds:
- Child workflows must be cancelled too
- In-progress tool calls may not be interruptible
- Partial work may need cleanup or preservation

#### Implementing timeouts

```yaml
timeouts:
  workflow_total: "30m"
  step_default: "5m"
  
  step_overrides:
    research: "10m"  # Research can take longer
    human_approval: "48h"  # Humans are slow
    
  on_timeout:
    behavior: "fail_gracefully"
    actions:
      - save_state
      - notify_user: "Your request timed out. You can resume from where it stopped."
      - log_for_investigation
```

Timeout hierarchy:
1. **Tool call timeout**: Individual API calls (seconds)
2. **Step timeout**: Single workflow step (minutes)
3. **Workflow timeout**: Entire workflow (minutes to hours)
4. **Session timeout**: User session if interactive (hours)

### Artifact management

Agents produce artifacts: drafts, outlines, source lists, verification reports. Artifact management ensures these are stored, versioned, and retrievable.

#### Artifact properties

```yaml
artifact:
  id: "brief-2025-01-23-001"
  type: "policy_brief_draft"
  version: 3
  
  metadata:
    workflow_id: "wf-xyz"
    created_at: "2025-01-23T15:00:00Z"
    created_by: "drafting_agent"
    parent_artifact: "brief-2025-01-23-001-v2"
    
  content:
    format: "markdown"
    storage: "s3://briefs/2025/01/23/..."
    checksum: "sha256:abc123..."
    
  lineage:
    - input_artifacts: ["sources-001", "outline-001"]
    - producing_step: "drafting"
    - evaluation_score: 0.87
```

#### Why versioning matters

1. **Rollback**: If the latest draft is worse, revert to previous version.

2. **Comparison**: Diff versions to see what changed between edits.

3. **Audit trail**: Reproduce how any artifact was created.

4. **Debugging**: When something goes wrong, trace the artifact chain backward.

#### Storage patterns

| Pattern | Use case | Trade-off |
|---------|----------|-----------|
| Database rows | Small artifacts, quick access | Size limits |
| Object storage (S3) | Large documents, media | Higher latency |
| Git repositories | Code, configs, versionable text | Merge complexity |
| Hybrid | Metadata in DB, content in object storage | More moving parts |

### Durable execution: checkpoints and recovery

**Durable execution** ensures workflows survive failures. The key mechanism: **checkpoints**.

#### How checkpoints work

```yaml
checkpoint:
  workflow_id: "wf-abc"
  timestamp: "2025-01-23T15:30:00Z"
  
  state:
    current_step: "drafting"
    completed_steps: ["research", "outline"]
    step_outputs:
      research:
        sources: [...]
        quotes: [...]
      outline:
        sections: [...]
    
  context:
    user_id: "user-123"
    request_params: {...}
    
  recoverable: true
```

When a failure occurs:
1. Load the latest checkpoint
2. Identify the current step
3. Resume from that step (don't re-execute completed steps)
4. Continue to completion

#### Checkpoint strategies

**Checkpoint after every step** (safest, most expensive):
```yaml
checkpoint_policy:
  frequency: "after_each_step"
  storage: "database"
  retention: "7 days"
```

**Checkpoint at boundaries** (balanced):
```yaml
checkpoint_policy:
  frequency: "at_boundaries"
  boundaries: ["research_complete", "outline_approved", "draft_complete"]
```

**Checkpoint on schedule** (for long-running agents):
```yaml
checkpoint_policy:
  frequency: "every_5_minutes"
  during_states: ["researching", "drafting"]
```

#### Recovery modes

| Mode | When to use | Behavior |
|------|-------------|----------|
| Resume | Transient failure (API timeout) | Retry current step, continue |
| Rollback | Bad output detected | Revert to earlier checkpoint, re-execute |
| Escalate | Repeated failures | Halt workflow, notify human |
| Abandon | Irrecoverable issue | Mark failed, cleanup, notify |

### Putting it together: the orchestration stack

Production agent systems layer multiple orchestration primitives:

```
┌─────────────────────────────────────────────────────────────┐
│                        User Interface                        │
│         (Submit requests, track progress, receive results)   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       API / Gateway                          │
│              (Authentication, rate limiting, routing)        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Queue / Scheduler                       │
│          (Job queuing, priority, concurrency limits)         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Workflow Orchestrator                      │
│       (State machine, checkpoints, timeout enforcement)      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Agent Layer                           │
│    (LLM calls, tool execution, multi-agent coordination)    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Artifact Storage                         │
│        (Versioned outputs, checkpoints, audit logs)          │
└─────────────────────────────────────────────────────────────┘
```

Each layer handles specific concerns:
- **User interface**: How users interact
- **API / Gateway**: Access control and traffic shaping
- **Queue / Scheduler**: Workload management
- **Workflow Orchestrator**: Task state and transitions
- **Agent Layer**: Intelligent execution
- **Artifact Storage**: Persistent outputs

### Tools for orchestration

Several production-grade tools implement these patterns:

#### LangGraph
Purpose-built for LLM agent workflows. Implements cyclic graphs with state persistence. Good for complex agent reasoning where control flow emerges dynamically.

Key features:
- Built-in checkpointing ("checkpointers")
- Durable execution modes
- Human-in-the-loop primitives
- Tight integration with LangChain ecosystem

#### Temporal
General-purpose durable execution platform. Guarantees workflow completion despite failures. Good for mission-critical, long-running workflows that happen to include LLM steps.

Key features:
- Automatic failure recovery
- Built-in retry with backoff
- Full event history and replay
- Language-agnostic (SDKs for multiple languages)

#### Comparison

| Aspect | LangGraph | Temporal |
|--------|-----------|----------|
| Primary focus | LLM agent graphs | General durable workflows |
| Learning curve | Lower for LLM work | Steeper, more concepts |
| Flexibility | High for agent patterns | High for any workflow |
| Ecosystem | LangChain | Standalone |
| Observability | Growing | Mature |
| Production scale | Medium | Enterprise |

**LangGraph** when: Your core complexity is agent reasoning and tool use.

**Temporal** when: Your core complexity is reliability, scale, and enterprise integration.

Both can work together: Temporal orchestrating the overall workflow, LangGraph handling the agent steps.

## Case study thread

### Research+Write (Policy change brief)

The brief workflow becomes a four-state machine with checkpoints at each boundary.

#### State machine specification

```yaml
brief_state_machine:
  initial: "requested"
  
  states:
    requested:
      on_enter: "validate request, create job"
      checkpoint: true
      transitions:
        - event: "validated"
          target: "researching"
        - event: "invalid"
          target: "rejected"
          
    researching:
      on_enter: "invoke research agent (supervisor/worker)"
      checkpoint_frequency: "every_5_sources"
      timeout: "10m"
      transitions:
        - event: "sources_gathered"
          target: "drafting"
        - event: "insufficient_sources"
          target: "human_input_needed"
        - event: "timeout"
          target: "research_timeout"
          
    drafting:
      on_enter: "invoke drafting agent with sources"
      checkpoint_frequency: "per_section"
      transitions:
        - event: "draft_complete"
          target: "verifying"
        - event: "needs_more_research"
          target: "researching"
          
    verifying:
      on_enter: "run citation audit + policy compliance check"
      checkpoint: false  # Fast step, no need
      transitions:
        - event: "passed"
          target: "completed"
        - event: "citations_failed"
          target: "drafting"
          guard: "revision_count < 3"
        - event: "citations_failed"
          target: "human_review"
          guard: "revision_count >= 3"
          
    completed:
      on_enter: "store final artifact, notify user"
      type: "final"
      artifact_output: "versioned_brief"
```

#### Artifact chain

```
request-001
    │
    └──▶ sources-001 (research output)
            │
            └──▶ outline-001 (outline output)
                    │
                    └──▶ draft-001-v1 (first draft)
                            │
                            └──▶ verification-001 (audit report)
                                    │
                                    └──▶ draft-001-v2 (revised draft)
                                            │
                                            └──▶ brief-001-final
```

Each artifact is:
- Versioned (v1, v2, ...)
- Linked to parent artifacts
- Associated with the producing workflow step
- Stored with content + metadata

### Instructional Design (Annual compliance training)

The training module workflow has more checkpoints because it requires human approval at multiple stages.

#### State machine specification

```yaml
training_state_machine:
  initial: "intake"
  
  states:
    intake:
      on_enter: "gather constraints from user"
      transitions:
        - event: "constraints_confirmed"
          target: "designing_objectives"
          
    designing_objectives:
      on_enter: "invoke objectives mapper agent"
      checkpoint: true
      timeout: "5m"
      transitions:
        - event: "objectives_ready"
          target: "awaiting_objectives_approval"
          
    awaiting_objectives_approval:
      type: "human_gate"
      on_enter: "send objectives for SME review"
      timeout: "48h"
      transitions:
        - event: "approved"
          target: "designing_assessments"
        - event: "rejected"
          target: "designing_objectives"
        - event: "timeout"
          target: "escalated"
          
    designing_assessments:
      on_enter: "invoke assessment designer and activity designer (parallel)"
      checkpoint: true
      transitions:
        - event: "design_complete"
          target: "alignment_check"
          
    alignment_check:
      on_enter: "invoke alignment QA agent"
      transitions:
        - event: "aligned"
          target: "accessibility_check"
        - event: "gaps_found"
          target: "designing_assessments"
          
    accessibility_check:
      on_enter: "invoke accessibility reviewer agent"
      transitions:
        - event: "passed"
          target: "awaiting_final_approval"
        - event: "issues_found"
          target: "designing_assessments"
          
    awaiting_final_approval:
      type: "human_gate"
      on_enter: "send complete package for compliance sign-off"
      timeout: "72h"
      transitions:
        - event: "approved"
          target: "exporting"
        - event: "rejected"
          target: "designing_objectives"  # Major revision
        - event: "minor_changes"
          target: "designing_assessments"
          
    exporting:
      on_enter: "generate LMS package"
      checkpoint: true
      transitions:
        - event: "exported"
          target: "completed"
          
    completed:
      on_enter: "store package, notify stakeholders"
      type: "final"
```

#### Queue configuration

```yaml
training_queues:
  - name: "training_design_requests"
    priority_levels:
      - urgent: "compliance deadline < 30 days"
      - normal: "standard requests"
      - batch: "bulk updates"
    concurrency: 3  # Only 3 parallel designs
    
  - name: "accessibility_reviews"
    rate_limit: "20/hour"  # External accessibility checker API limit
    
  - name: "lms_exports"
    singleton: true  # Only one export at a time to avoid conflicts
```

### From infrastructure to experience

Orchestration provides the reliability foundation—state machines track progress, checkpoints enable recovery, queues manage load, and artifacts preserve work. But reliable infrastructure isn't enough. Users need to *trust* these systems, understand what's happening, and maintain control when things go wrong.

The human approval gates scattered throughout this chapter's examples hint at the next challenge: designing the interface between humans and agents. How do you show users what the agent is doing? When should you ask for confirmation? How do you make long-running workflows feel responsive? These are questions of **agent UX**—the subject of Chapter 16.

## Artifacts to produce

- **State machine diagram** for your agent workflow (states, transitions, failure paths)
- **Checkpoint specification** (when to checkpoint, what to store)
- **Queue configuration** (queues, limits, retry policies)
- **Artifact schema** (what artifacts exist, their relationships)

## Chapter exercise

Draw an orchestration diagram for an agent feature (states, transitions, failure paths).

### Part 1: Define your states

For either case study (or your own agent):
1. List all possible states the workflow can be in
2. Identify which states are "happy path" and which are "error/edge"
3. Mark which states require human input

### Part 2: Define transitions

For each state:
1. What events can occur in this state?
2. What is the target state for each event?
3. What guards (conditions) must be true for the transition?

### Part 3: Add orchestration primitives

Annotate your diagram with:
1. Checkpoints: Where does state get saved?
2. Timeouts: What happens if a state takes too long?
3. Retries: Which transitions can be retried, and how many times?
4. Escalation: When does the system give up and ask for help?

### Part 4: Draw the artifact chain

For a successful run of your workflow:
1. What artifacts are produced at each step?
2. How do artifacts link to each other?
3. What metadata accompanies each artifact?

## Notes / references

- LangGraph documentation: https://langchain-ai.github.io/langgraph/
- LangGraph concepts (state, checkpoints, persistence): https://langchain-ai.github.io/langgraph/concepts/
- Temporal documentation: https://docs.temporal.io/
- "Durable Execution" concept: Temporal blog — https://temporal.io/blog/durable-execution
- Finite State Machines for AI: https://en.wikipedia.org/wiki/Finite-state_machine
- Event-driven architecture patterns: https://martinfowler.com/articles/201701-event-driven.html
- Workflow vs Agent distinction: "Building Effective Agents" — Anthropic (2024)

