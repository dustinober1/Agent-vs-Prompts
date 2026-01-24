# Chapter 17 — Reliability engineering for agents

## Purpose
Turn probabilistic models into dependable features.

## Reader takeaway
Reliability comes from retries, idempotency, fallbacks, budgets, and recoverable partial progress—not from hoping the model "tries harder."

## Key points
- Failure handling: retries/backoff, idempotent tool calls, fallbacks, partial recovery
- Guardrails: budgets, safe defaults, constraint enforcement outside the model
- Determinism where it matters: structured outputs, stable tools, caching

## Draft

### The agent that crushed the budget

The policy brief agent launched on Monday. By Wednesday, the CFO was on a call with engineering.

The agent worked exactly as designed. Users loved it—especially the ability to request "thorough research" on complex topics. One user requested a competitive analysis requiring research across twelve vendor documentation sites. The agent dutifully searched, fetched, extracted, and compared. When the first search returned sparse results, it tried again with modified queries. When extraction failed on a malformed PDF, it retried three times. When the draft didn't meet its own quality threshold, it regenerated.

Each retry was reasonable in isolation. Together, they burned through 2.3 million tokens in forty-five minutes. At current API pricing, one brief cost the company $47.

The postmortem revealed a cascade of reasonable behaviors with unreasonable consequences:

- The search tool returned 429 (rate limited) errors, triggering retries without backoff
- Failed PDF extractions triggered immediate retries instead of graceful degradation
- The self-critique loop had no iteration limit—it kept regenerating until "satisfied"
- No token budget existed to cap runaway inference

The agent wasn't buggy. It was *unreliable*. It did what it was told in the happy path, but the production environment is never a happy path for long.

This is the gap between "works in demos" and "works in production." Demos succeed in controlled conditions. Production faces rate limits, timeouts, malformed inputs, API outages, and edge cases nobody anticipated. Reliability engineering bridges this gap—through failure handling, guardrails, and determinism where it matters.

### Why models need reliability engineering

LLMs are fundamentally probabilistic. The same prompt can produce different outputs. Temperature settings, model updates, and token sampling all introduce variance. This isn't a bug—it's the nature of the technology.

Traditional software reliability assumes determinism: if the inputs are the same, the outputs are the same. A function that adds two numbers always returns the same result. A database query returns the same rows (assuming no concurrent writes). Testing verifies behavior once, and that behavior holds.

LLMs break this assumption. A prompt that works today might fail after a model update. An output that parses correctly 99% of the time will break 1% of the time—and in production, 1% adds up fast.

Reliability engineering for agents addresses three interlocking concerns:

1. **Failure handling**: What happens when things go wrong? (And things *will* go wrong.)
2. **Guardrails**: What prevents runaway behavior? Budgets, limits, and constraints.
3. **Determinism**: Where can we reduce variance? Structured outputs, caching, and stable tools.

### Failure handling: retries, backoff, and graceful degradation

#### Retries with jitter and backoff

When an API call fails, the first instinct is to retry. Immediate retries are almost always wrong.

**Why immediate retries fail:**

- If the failure is a rate limit (429), immediate retry will hit the same limit
- If the failure is a timeout, immediate retry adds load to an already stressed system
- If many clients retry simultaneously, they create a "thundering herd" that worsens the outage

**Exponential backoff with jitter** solves this:

```yaml
retry_policy:
  max_attempts: 3
  initial_delay_ms: 1000
  max_delay_ms: 30000
  backoff_multiplier: 2
  jitter_factor: 0.3  # Add 0-30% random variance
  
  retryable_errors:
    - http_status: [429, 500, 502, 503, 504]
    - error_type: ["timeout", "connection_error"]
    
  non_retryable_errors:
    - http_status: [400, 401, 403, 404]
    - error_type: ["validation_error", "authentication_error"]
```

With this policy:
- First retry: ~1 second delay (with jitter: 700ms–1300ms)
- Second retry: ~2 seconds delay (with jitter: 1400ms–2600ms)
- Third retry: ~4 seconds delay (with jitter: 2800ms–5200ms)

The jitter is critical. Without it, all clients that failed at the same time will retry at the same time, recreating the load spike. Jitter spreads retries across time.

#### Idempotent tool calls

A tool call is **idempotent** if calling it multiple times with the same parameters produces the same result as calling it once. Idempotency makes retries safe.

**Non-idempotent (dangerous to retry):**
- `send_email(to, subject, body)` — retrying sends duplicate emails
- `create_payment(amount, recipient)` — retrying creates duplicate charges
- `publish_document(doc_id)` — retrying might overwrite concurrent edits

**Idempotent (safe to retry):**
- `get_document(doc_id)` — reading returns the same document
- `search(query)` — searching returns matching results
- `set_status(doc_id, status)` — setting the same status is a no-op

**Making non-idempotent tools safe:**

Use **idempotency keys**. Each request includes a unique key. The service remembers which keys it has processed and returns the same result for duplicates.

```yaml
idempotent_tool_call:
  tool: "create_payment"
  idempotency_key: "task-123-payment-001"
  parameters:
    amount: 1000
    recipient: "vendor@example.com"
    
# If the network fails after the payment is created but before
# the response reaches the client, a retry with the same key
# returns the original result instead of creating a duplicate.
```

Stripe popularized this pattern. Their API documentation states: "Idempotency keys are sent in the `Idempotency-Key` header. If you don't receive a response, you can safely retry the request with the same key."

For agent systems, generate idempotency keys at the task level:

```yaml
idempotency_key_strategy:
  format: "{workflow_id}-{step_id}-{attempt_number}"
  examples:
    - "wf-abc-research-1"
    - "wf-abc-draft-2"  # Second attempt at drafting
```

#### Fallback strategies

When retries are exhausted, you need a fallback. Fallbacks trade capability for availability.

**Fallback hierarchy:**

```yaml
fallback_chain:
  primary:
    model: "gpt-4o"
    timeout: "30s"
    
  fallback_1:
    condition: "primary_failed OR primary_timeout"
    model: "gpt-4o-mini"
    timeout: "20s"
    note: "Faster, cheaper, slightly less capable"
    
  fallback_2:
    condition: "fallback_1_failed"
    action: "cached_response"
    note: "Return cached answer for common queries"
    
  fallback_3:
    condition: "fallback_2_miss"
    action: "graceful_degradation"
    response: "I'm unable to complete this request right now. Here's what I found before the issue: {partial_results}"
```

**Model cascade pattern:**

Research on model cascades suggests that routing between models based on query complexity can significantly reduce costs—often by 40% or more—while maintaining quality. Simple queries go to smaller, faster, cheaper models. Complex queries escalate to larger models.

```yaml
model_cascade:
  router:
    type: "complexity_classifier"
    rules:
      - condition: "query_length < 100 AND no_tools_required"
        model: "gpt-4o-mini"
      - condition: "requires_code_generation"
        model: "claude-sonnet"
      - default:
        model: "gpt-4o"
        
  deferral_rule:
    on_low_confidence: "escalate_to_larger_model"
    confidence_threshold: 0.7
```

This isn't just a fallback—it's an optimization. But when the larger model fails, the cascade becomes a fallback path.

**Graceful degradation:**

When all models fail, provide partial functionality rather than complete failure:

- **Cached responses**: For common queries, return a cached answer with a disclaimer
- **Simplified operation**: Disable complex features, maintain basic functionality
- **Partial results**: Return what succeeded before the failure
- **Human escalation**: Route to a human operator

```yaml
graceful_degradation:
  scenario: "research_tool_unavailable"
  
  degraded_behavior:
    - disable: "web_search"
    - continue_with: "internal_docs_only"
    - notify_user: "External research is temporarily unavailable. Results are limited to internal documents."
    
  scenario: "all_models_unavailable"
  
  degraded_behavior:
    - action: "queue_for_later"
    - notify_user: "Your request has been queued and will complete when service is restored."
    - sla: "4 hours"
```

#### Partial progress recovery

Long-running agent tasks should save progress incrementally. When a failure occurs mid-task, recovery shouldn't require starting from scratch.

**Checkpoint pattern (from Chapter 15, applied to reliability):**

```yaml
checkpoint_policy:
  brief_workflow:
    checkpoints:
      - after: "research_complete"
        saves: ["sources", "quotes", "search_queries"]
        
      - after: "outline_approved"
        saves: ["outline", "section_assignments"]
        
      - after: "each_section_drafted"
        saves: ["section_{n}_content", "section_{n}_citations"]
        
    on_failure:
      resume_from: "last_checkpoint"
      preserve: "all_saved_artifacts"
      discard: "incomplete_step_outputs"
```

This matters for cost and user experience. If an agent spends 10 minutes researching before failing during drafting, recovery should skip the research—those results are already saved.

### Guardrails: budgets, limits, and safe defaults

Guardrails prevent runaway behavior. They're the constraints that keep agents within acceptable bounds when things go wrong—or when the model decides to be "helpful" in expensive ways.

#### Token budgets

Every agent task should have a token budget. Exceeding the budget triggers a stop, not infinite spending.

```yaml
token_budget:
  task: "policy_brief"
  
  limits:
    input_tokens: 50000
    output_tokens: 10000
    total_tokens: 60000
    
  enforcement:
    on_80_percent:
      action: "warn"
      log: "Approaching token budget limit"
      
    on_100_percent:
      action: "stop"
      save: "partial_results"
      notify: "Task exceeded token budget. Partial results available."
      
  per_step_limits:
    research: 30000
    drafting: 25000
    verification: 5000
```

Token budgets should be enforced *outside* the model. Don't ask the model to track its own token usage—it can't do this reliably. Orchestration layers count tokens and enforce limits.

#### Time budgets

Time limits prevent stuck tasks from running indefinitely.

```yaml
time_budget:
  task: "policy_brief"
  
  limits:
    total_duration: "15m"
    per_step:
      research: "5m"
      outline: "2m"
      drafting: "5m"
      verification: "3m"
      
  enforcement:
    on_timeout:
      action: "save_and_stop"
      partial_results: true
      
    human_gate_exception:
      # Time waiting for human approval doesn't count
      excluded_states: ["awaiting_approval"]
```

#### Tool call limits

Agents that call tools in a loop can spiral. Limit the number of tool calls per task and per step.

```yaml
tool_call_limits:
  task: "policy_brief"
  
  limits:
    total_tool_calls: 50
    per_step:
      research: 20  # searches + fetches
      drafting: 10
      verification: 10
      
    consecutive_same_tool: 5  # Prevent loops like search → search → search
    
  enforcement:
    on_limit:
      action: "force_progress"
      behavior: "move_to_next_step_with_available_results"
```

The "consecutive same tool" limit is particularly important. An agent stuck in a search loop—refining queries endlessly—needs external intervention to move forward.

#### Iteration limits for self-improvement loops

Self-critique and revision loops (Reflexion-style) are powerful but dangerous. Without limits, the agent might revise forever, never satisfied with its own output.

```yaml
iteration_limits:
  self_critique_loop:
    max_iterations: 3
    
    continue_condition: "score < threshold"
    force_exit_condition: "iterations >= max OR improvement_delta < 0.05"
    
    on_force_exit:
      behavior: "return_best_so_far"
      log: "Self-critique loop exited at iteration {n} with score {score}"
```

#### Safe defaults

When configuration is missing or ambiguous, safe defaults prevent runaway behavior.

```yaml
safe_defaults:
  # If no budget specified, use conservative limits
  token_budget_default: 30000
  time_budget_default: "10m"
  tool_call_limit_default: 30
  
  # If no temperature specified, use low temperature for consistency
  temperature_default: 0.3
  
  # If no retry policy specified, use conservative retries
  retry_attempts_default: 2
  
  # For new tasks, start with low autonomy
  autonomy_level_default: "locked_workflow"
  
  # Default to draft mode, not publish
  output_mode_default: "draft"
```

The last point is critical: agents should default to creating drafts, not final outputs. A mistaken draft is fixable. A mistaken publication is a production incident (as we saw in Chapter 16).

### Determinism where it matters

Not everything can be deterministic. LLMs are inherently probabilistic. But the *boundaries* around probabilistic behavior can be deterministic, making the overall system more predictable.

#### Structured outputs enforce schema compliance

Structured outputs constrain LLM responses to match a JSON schema. This eliminates format variance—one of the most common failure modes in production.

**Without structured outputs:**
```
Sometimes the model returns:
{"result": "approved", "reason": "Meets criteria"}

Sometimes:
{"status": "approved", "explanation": "The document meets all criteria."}

Sometimes:
{"approved": true}

Sometimes just: "Approved."
```

**With structured outputs (strict mode):**
```yaml
response_schema:
  type: "object"
  properties:
    status:
      type: "string"
      enum: ["approved", "rejected", "needs_review"]
    reason:
      type: "string"
    confidence:
      type: "number"
      minimum: 0
      maximum: 1
  required: ["status", "reason", "confidence"]
  additionalProperties: false
```

OpenAI's GPT-4o with structured outputs achieves 100% schema compliance in evaluations, compared to under 40% for earlier models with free-form JSON. This isn't marginal improvement—it's the difference between "works sometimes" and "works reliably."

**Implementation:**

```python
from openai import OpenAI

client = OpenAI()

response = client.chat.completions.create(
    model="gpt-4o-2024-08-06",
    messages=[...],
    response_format={
        "type": "json_schema",
        "json_schema": {
            "name": "approval_decision",
            "strict": True,
            "schema": {
                "type": "object",
                "properties": {
                    "status": {"type": "string", "enum": ["approved", "rejected", "needs_review"]},
                    "reason": {"type": "string"},
                    "confidence": {"type": "number"}
                },
                "required": ["status", "reason", "confidence"],
                "additionalProperties": False
            }
        }
    }
)
```

The `strict: True` flag is essential. Without it, the model attempts schema compliance but doesn't guarantee it.

#### Stable tool responses

Tools should return deterministic results for deterministic inputs. When they can't, the non-determinism should be explicit.

**Deterministic tools:**
- `fetch_document(doc_id, version)` — returns specific version, always the same
- `calculate_checksum(content)` — pure computation, deterministic
- `validate_schema(data, schema)` — deterministic validation result

**Non-deterministic tools (explicit about it):**
- `search(query)` — results may change as index updates; return `as_of` timestamp
- `get_current_price(stock)` — time-dependent; return timestamp with value
- `fetch_document(doc_id)` without version — might return newer version

```yaml
tool_response:
  tool: "search_documents"
  query: "expense policy threshold"
  
  results: [...]
  
  metadata:
    as_of: "2025-01-23T10:00:00Z"
    index_version: "v2025-01-23"
    deterministic: false
    ttl: "1h"  # Results considered stable for 1 hour
```

When caching tool responses, the `ttl` and `as_of` metadata determine cache validity.

#### Caching and memoization

Caching reduces variance by reusing previous results instead of recomputing.

**What to cache:**

| Data type | Cache duration | Invalidation |
|-----------|----------------|--------------|
| Document fetches | Hours to days | On document update |
| Search results | Minutes to hours | On index update |
| LLM responses (same prompt) | Task lifetime | Don't cache across tasks |
| Parsed/extracted data | Same as source | On source update |

**Why not cache LLM responses across tasks:**

LLM responses depend on context that varies per task—conversation history, user preferences, current date. A cached response from one task might be inappropriate for another.

Within a task, caching prevents redundant inference:

```yaml
inference_cache:
  scope: "task"
  
  cache_key:
    components:
      - model
      - temperature
      - messages_hash
      - tools_hash
      
  behavior:
    on_hit: "return_cached"
    on_miss: "call_model_and_cache"
    
  ttl: "task_lifetime"  # Cleared when task completes
```

#### Seed values for reproducibility

Some LLM providers support seed values for reproducible sampling. With the same seed, the same prompt produces the same output (mostly—provider implementations vary).

```yaml
reproducibility:
  mode: "evaluation"  # For testing and debugging
  
  settings:
    seed: 42
    temperature: 0  # Use with seed for maximum reproducibility
    
  note: "Reproducibility is best-effort. Provider updates may change outputs."
```

This is useful for:
- Debugging: reproduce the exact output that caused an issue
- Evaluation: compare model versions on identical inputs
- Testing: create deterministic test fixtures

But don't rely on it for production guarantees. Providers can change model implementations, and even small changes can alter outputs.

### The reliability stack

Reliability patterns layer together:

```
┌──────────────────────────────────────────────────────────────────┐
│                        User Request                               │
└──────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                      Input Validation                             │
│           (Schema validation, sanitization, limits)               │
└──────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                        Budget Guards                              │
│        (Token limits, time limits, tool call limits)              │
└──────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                     Task Orchestrator                             │
│     (State machine, checkpoints, progress tracking)               │
└──────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                        Agent Layer                                │
│  (Model calls with retries, fallbacks, structured outputs)        │
└──────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                        Tool Layer                                 │
│  (Idempotent calls, caching, deterministic responses)             │
└──────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                     Output Validation                             │
│         (Schema checks, safety filters, quality gates)            │
└──────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                       Artifact Storage                            │
│          (Versioned outputs, audit logs, recovery points)         │
└──────────────────────────────────────────────────────────────────┘
```

Each layer adds reliability:
- **Input validation** catches malformed requests before they waste resources
- **Budget guards** prevent runaway costs
- **Orchestrator** ensures progress is saved and resumable
- **Agent layer** handles model-specific failures (retries, fallbacks)
- **Tool layer** provides stable interfaces to external systems
- **Output validation** catches schema violations and quality issues
- **Artifact storage** enables recovery and audit

### Incident response: the runbook

When reliability engineering works, incidents are rare. When they occur, a runbook guides response.

#### Common incident classes

| Incident | Symptoms | Likely causes |
|----------|----------|---------------|
| Stuck in loop | Same tool called repeatedly; no progress | Missing iteration limit; broken exit condition |
| Budget exceeded | Task stopped mid-execution; cost spike | Complex query; retry storm; self-critique loop |
| Timeout | Task incomplete after time limit | External API slow; model overloaded |
| Output validation failure | Schema mismatch; empty output | Model update; edge case input |
| Tool failure cascade | One tool fails, triggers fallbacks | External service outage |

#### Runbook: agent stuck in a loop

**Detection:**
- Same tool called >5 times consecutively
- No state change for >2 minutes
- Token usage growing without output progress

**Immediate response:**
1. Pause the workflow (don't terminate—preserve state)
2. Log current state: tool call history, agent reasoning, checkpoint data
3. Notify user: "Your request is paused for review."

**Investigation:**
1. Review last 5 tool calls: Are results identical? Are they errors?
2. Check exit condition: What should have ended the loop?
3. Check model reasoning: Is it making progress toward the goal?

**Resolution paths:**

*Path A: Tool returning unhelpful results*
- Adjust tool parameters
- Try alternative tool
- Manually provide the needed data

*Path B: Exit condition never satisfied*
- Lower threshold (e.g., quality score 0.9 → 0.7)
- Add iteration limit
- Force exit with best available result

*Path C: Model confused about goal*
- Clarify instructions
- Provide intermediate guidance
- Escalate to human completion

**Recovery:**
1. Resume from last checkpoint with fix applied
2. Monitor for recurrence
3. If successful, add the fix to permanent configuration

**Post-incident:**
1. Add the pattern to loop detection rules
2. Update iteration limits if needed
3. Document in incident log

## Case study thread

### Research+Write (Policy change brief)

The brief agent implements reliability at every layer.

#### Retry and fallback configuration

```yaml
brief_reliability:
  research_step:
    search_tool:
      retry_policy:
        max_attempts: 3
        backoff: "exponential_with_jitter"
        initial_delay: "1s"
        
      fallback:
        on_all_retries_exhausted:
          - try: "alternative_search_provider"
          - then: "return_cached_results_if_fresh"
          - finally: "proceed_with_partial_results"
          
    fetch_tool:
      retry_policy:
        max_attempts: 2
        retryable: ["timeout", "5xx"]
        non_retryable: ["404", "403"]
        
      fallback:
        on_404: "skip_source_with_note"
        on_403: "request_access_from_user"
        on_persistent_failure: "mark_source_unavailable"
        
  drafting_step:
    model:
      primary: "gpt-4o"
      fallback: "gpt-4o-mini"
      
    self_revision:
      max_iterations: 3
      exit_on: "score >= 0.8 OR improvement < 0.05"
      
  verification_step:
    citation_check:
      retry_policy:
        max_attempts: 2
        
      on_failure:
        single_citation: "mark_unverified_in_output"
        majority_citations: "fail_verification_step"
```

#### Budget enforcement

```yaml
brief_budgets:
  token_budget:
    research: 30000
    drafting: 20000
    verification: 5000
    total: 55000
    
  time_budget:
    research: "5m"
    drafting: "4m"
    verification: "2m"
    total: "12m"
    
  tool_call_budget:
    search: 10
    fetch: 20
    total: 50
```

#### Partial progress recovery

When a brief fails mid-drafting, recovery uses the existing research:

```yaml
brief_recovery:
  on_drafting_failure:
    preserved:
      - sources (from research checkpoint)
      - outline (if approved)
      - completed_sections (if any)
      
    recovered_state:
      step: "drafting"
      resume_from: "section_{n}"  # First incomplete section
      
    user_option:
      - "Resume with current sources"
      - "Add more research first"
      - "Start fresh"
```

### Instructional Design (Annual compliance training)

The training module agent has stricter reliability requirements—exports to the LMS must be atomic and reversible.

#### Idempotent exports

```yaml
lms_export_idempotency:
  idempotency_key: "{workflow_id}-{export_version}"
  
  behavior:
    on_first_call:
      action: "perform_export"
      store: "idempotency_record"
      
    on_duplicate_key:
      action: "return_previous_result"
      note: "Export already completed; returning original confirmation"
      
  atomicity:
    all_or_nothing: true
    on_partial_failure:
      action: "rollback_all"
      state: "export_failed"
```

#### Rollback and versioning

```yaml
lms_versioning:
  on_export:
    - capture: "pre_export_state"
    - create: "rollback_checkpoint"
    - perform: "export"
    - if_success: "mark_rollback_available"
    
  rollback_policy:
    available_for: "30 days"
    requires: "admin_approval"
    
  version_tracking:
    format: "{module_id}-v{major}.{minor}"
    on_export: "increment_minor"
    on_major_revision: "increment_major_reset_minor"
```

#### Progressive capability degradation

```yaml
training_degradation:
  when: "lms_unavailable"
  
  degraded_modes:
    tier_1:
      disabled: ["live_export"]
      enabled: ["generate_scorm_package", "local_download"]
      user_message: "LMS connection unavailable. You can download the package for manual upload."
      
    tier_2:
      disabled: ["scorm_generation"]
      enabled: ["preview_mode", "draft_only"]
      user_message: "Package generation unavailable. Preview and draft editing still work."
      
    tier_3:
      disabled: ["all_generation"]
      enabled: ["view_previous_versions"]
      user_message: "Design system is in read-only mode. Previous versions are accessible."
```

## Artifacts to produce

- **Reliability checklist**: Pre-launch verification items
- **Runbook templates**: Incident response procedures
- **Budget configuration templates**: Token, time, and tool call limits
- **Fallback chain specifications**: Primary → secondary → degraded behavior

## Chapter exercise

Create a runbook for "agent stuck in a loop" incidents.

### Part 1: Detection

1. What metrics would indicate a loop? (tool call frequency, state changes, token consumption)
2. What thresholds trigger an alert?
3. How quickly must detection occur? (before budget is exhausted)

### Part 2: Immediate response

1. What's the first action? (pause, not terminate)
2. What state must be preserved?
3. How is the user notified?

### Part 3: Investigation

1. What logs are needed to diagnose the root cause?
2. What are the three most likely causes?
3. How do you distinguish between them?

### Part 4: Resolution

For each likely cause, document:
1. The fix to apply
2. How to resume from the preserved state
3. How to prevent recurrence

### Part 5: Post-incident

1. What gets added to permanent configuration?
2. How is the incident recorded for future reference?
3. What monitoring improvements follow?

Reliability engineering makes agents dependable. But dependable isn't the same as observable—you also need visibility into what's happening and continuous improvement based on what you learn. Chapter 18 covers observability, evals, and the feedback loops that make agents better over time.

## Notes / references

- Exponential backoff and jitter: AWS Architecture Blog, "Exponential Backoff and Jitter" (foundational pattern)
- Idempotency keys: Stripe API documentation, best practice for payment APIs
- LLM fallback strategies: Research on model cascades and graceful degradation in LLM applications
- OpenAI Structured Outputs: 100% schema compliance with GPT-4o using strict mode
- Model cascade research: Google Research on routing queries to smaller models for cost optimization
- Graceful degradation patterns: Industry practices for maintaining partial functionality during outages
- Constrained decoding: OpenAI's approach to enforcing JSON schema compliance at the token level
