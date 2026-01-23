# Chapter 7 — The agent loop: plan → act → observe → reflect

## Purpose
Establish a canonical loop to reference throughout the book.

## Reader takeaway
A reliable agent is a **bounded control loop** with explicit budgets, stopping conditions, and measurable success criteria—not an unbounded “think harder” prompt.

## Key points
- Minimal loop: interpret → plan → act (tool call) → observe (parse) → update state → reflect (checks) → decide next step.
- Reflection is operational: sanity checks, constraint checks, uncertainty estimation, and clarifying questions.
- Budgets make autonomy safe: max tool calls, retries, latency, and cost; plus a clear authority model (read vs write).
- Stopping conditions prevent runaway behavior: success met, budget exceeded, permission/approval needed, or irrecoverable tool failure.
- Persist artifacts + telemetry so you can debug and improve: plans, evidence sets, drafts, validation results, tool traces.

## Draft

### The loop is the product
“Agent” is a loaded word. In practice, most useful agentic systems are just **control loops** wrapped around an LLM:
- The model helps interpret intent, generate plans, and draft artifacts.
- Tools do retrieval, computation, and side effects.
- Validators and gates enforce constraints.
- The loop coordinates steps, remembers what happened, and decides what to do next.

If you do not have a loop, you do not have an agent—you have a chat completion.

This chapter defines a loop that we’ll reuse in Parts III–V:
- Chapter 8 expands the “tools” leg.
- Chapter 9 expands the “retrieve” leg.
- Chapter 10 expands “planning”.
- Chapter 11 expands “state/memory”.
- Chapter 12 expands “verification”.

### A minimal loop you can actually build
Here is the smallest loop that still deserves to be called “agentic”:

1) **Interpret**
- Parse the request into: goal, audience, constraints, and required inputs.
- Decide whether you can proceed or must ask clarifying questions.

2) **Plan**
- Produce a short, explicit plan: steps, expected artifacts, and checks.
- Pick a budget (time/tool calls/retries) appropriate to stakes.

3) **Act (tool call)**
- Choose a tool action (search, fetch, extract, validate, etc.).
- Execute within allowlists and authority constraints.

4) **Observe (parse result)**
- Parse tool output into structured data you can reason about.
- Detect tool errors, partial failures, or missing fields.

5) **Update state**
- Record what you learned and what you produced (artifacts).
- Track progress: which step you’re on, what’s still missing, what failed.

6) **Reflect (checks)**
- Run checks that answer: “Is this safe, correct enough, and on track?”
- If not, decide: revise, retry with a new strategy, ask the user, escalate, or stop.

7) **Decide next step**
- Continue the loop, deliver the output, or exit with a clear reason.

One way to visualize it is a small state machine:
```text
intake → clarify? → plan → act(tool) → observe(parse) → update state → reflect(checks)
                                         ↑                                 ↓
                                         └────────── decide next step ─────┘
```

Or as a minimal “agent state” you can log and debug:
```yaml
state:
  goal: ""
  constraints:
    allowed_sources: []
    confidentiality_level: ""
    required_sections: []
  plan:
    steps: []
    current_step: 0
  artifacts:
    - name: ""
      status: "draft|final"
      location: ""
  budgets:
    max_tool_calls: 0
    max_retries: 0
    max_latency_seconds: 0
    max_cost_usd: 0
  counters:
    tool_calls: 0
    retries: 0
  tool_trace: []
  validation_results: []
  open_questions: []
```

Nothing here is “mystical.” It’s just a design that makes behavior predictable.

### “Reflection” without mysticism: checks, not vibes
Reflection in production systems is not “let the model think harder.” It’s a set of explicit questions that you answer with tools, validators, and a small amount of model judgment.

Useful reflection checks:

#### Sanity checks
- Does the output parse (JSON/Markdown table/required headings)?
- Are numbers plausible (date ranges, counts, totals)?
- Did the system accidentally drop required sections?

#### Constraint checks
- Did we use only allowed sources?
- Did we follow confidentiality and redaction rules?
- Did we exceed budgets (tool calls, retries, time, cost)?

#### Uncertainty checks
- Is a required input missing (audience, scope, region, “as-of” date)?
- Are the sources contradictory or too weak to support a key claim?
- Do we need to ask a human for approval or interpretation?

#### Progress checks (anti-loop)
- Are we repeating the same tool calls without new information?
- Are retries changing anything, or are we stuck?
- Is the remaining work blocked by missing permissions?

Reflection outputs should be actionable:
- “Ask user X”
- “Retry tool Y with parameters Z”
- “Stop and escalate to approver”
- “Proceed to drafting step”

### Budgets: the loop’s guardrails
Budgets are what turn “agentic” into “safe and shippable.”

At minimum, define these budgets per request:

| Budget | Controls | Why it matters |
|---|---|---|
| Tool-call budget | max tool calls total + per tool | prevents tool spam and runaway loops |
| Retry budget | max retries per gate/tool | prevents infinite “try again” cycles |
| Latency budget | max end-to-end seconds | keeps UX predictable |
| Cost budget | max spend per request | makes routing decisions enforceable |

And two “non-negotiable” budgets in high-stakes work:

| Budget | Controls | Why it matters |
|---|---|---|
| Authority budget | read-only vs write-with-approval vs write-autonomous | prevents accidental side effects |
| Context budget | what the model can see (least context) | reduces leakage and confusion |

Budget violations should have default behaviors:
- **soft fail** (for low stakes): return best effort + “what I couldn’t do”
- **hard fail** (for high stakes): block/ask/escalate

### Stopping conditions: how the loop exits safely
Every agent loop needs explicit stop rules. Without them, you’ll see:
- runaway latency and cost
- inconsistent outputs (“it kept going until it hallucinated something”)
- unclear accountability (“it tried its best” is not a system behavior)

Recommended stopping conditions (match the outline):

#### Stop: success criteria met
Examples:
- all required sections are present
- all validators pass
- approvals are recorded (if required)

#### Stop: budget exceeded
Behavior options:
- return partial output + what’s missing + next actions
- ask the user to approve spending more budget (if you have such a UI)
- switch to safe mode (read-only, summarization-only)

#### Stop: missing permission / needs human approval
Examples:
- requested write action requires approval
- requested docs are restricted
- policy interpretation requires a policy owner sign-off

#### Stop: irrecoverable tool failure
Examples:
- tool consistently errors after retries
- source system is down
- parsing fails due to unexpected formats (and you cannot repair)

In all non-success exits, be explicit:
- what you attempted
- what failed (gate/tool/budget)
- what the user can do next

### The loop depends on artifacts (not just chat messages)
The loop stays coherent when each phase produces artifacts you can store and validate:
- plan (steps + success criteria)
- evidence set (sources + excerpts)
- draft artifacts (outline, module flow, brief)
- validation reports (citation resolution, alignment rubric, accessibility checklist)
- final deliverable

This is the tasks/actions/artifacts model from Chapter 5, applied over time:
- **Task** stays stable (“produce a policy change brief”).
- **Actions** vary step-by-step (search, fetch, extract, validate).
- **Artifacts** accumulate and become auditable.

If you only store a chat transcript, you are missing the most useful debug surface: the artifacts and validation results.

### The same loop scales down (and up)
The loop is not “only for complex agents.”

Low-agency example (rung 1–2 from Chapter 6):
```text
interpret → draft → sanity check → deliver
```

Medium-agency example (rung 4–5):
```text
interpret → retrieve → draft → cite-check → deliver
```

High-agency example (rung 6–7):
```text
interpret → plan → (tool loop + revisions) → verify → (deliver | ask | escalate)
```

What changes is not whether you have a loop. What changes is:
- which tools are allowed
- which gates can block
- how budgets are set
- how much autonomy the system has to choose the next step

## Case study thread

### Research+Write (Policy change brief)
Anchor template: `../case_studies/research_write_policy_change_brief_TEMPLATE.md`

#### A concrete loop for the brief
Plan steps (with artifacts + gates):

1) **Clarify**
- Artifact: clarified requirements (audience, scope, “as-of” date, allowed sources)
- Gate: missing required inputs → ask user (don’t guess)

2) **Gather sources**
- Actions: internal search → fetch docs; external search only if allowed
- Artifact: evidence set (doc IDs/URLs + snippets)
- Gate: permission failures → escalate/deny; weak sources → expand search within budget

3) **Extract and map**
- Actions: extract quotes/excerpts; build claim→source map (even if rough)
- Artifact: claim map + excerpt set
- Gate: missing evidence for key claims → block or mark NEEDS SOURCE (depending on stakes)

4) **Outline**
- Artifact: brief outline aligned to the template
- Gate: required sections present

5) **Draft**
- Artifact: draft brief

6) **Verify**
- Actions: resolve citations; redaction/classification checks; coverage checks
- Artifact: validation report (pass/fail + issues)
- Gate: confidentiality failure → hard stop; citation failures → revise within retry budget

7) **Deliver or escalate**
- Deliver when gates pass.
- Escalate when interpretation requires a policy owner.

#### Default budgets (example)
| Budget | Default |
|---|---|
| Tool calls | 12 |
| Retries | 2 per gate |
| Latency | 90 seconds |
| Authority | read-only tools; publishing requires approval |

#### Telemetry you want from day one
- query terms used + doc IDs fetched
- citation resolution success/failure
- claim coverage (% of key claims with excerpts)
- redaction/classification results
- budgets consumed and stop reason

### Instructional Design (Annual compliance training)
Anchor template: `../case_studies/instructional_design_compliance_training_MODULE_TEMPLATE.md`

#### A concrete loop for the module
Plan steps (with artifacts + gates):

1) **Clarify constraints**
- Artifact: learner profile, modality, time, region, policies in scope
- Gate: missing context → ask; don’t invent role details

2) **Retrieve policy sources + templates**
- Actions: policy/SOP lookup; template retrieval
- Artifact: policy map (source IDs + “last verified” date) + selected templates
- Gate: missing current policies → block/ask SME

3) **Draft objectives + module flow**
- Artifact: objectives + flow outline
- Gate: objectives must be performance-based (review rubric)

4) **Generate practice + scenarios**
- Artifact: scenario set + facilitator/learner instructions

5) **Generate assessments + rubrics**
- Artifact: question bank + rubrics

6) **Validate**
- Actions: alignment rubric (objective↔practice↔assessment); accessibility checklist
- Artifact: QA report (pass/fail + fixes)
- Gate: alignment/accessibility failures → revise within retry budget; approvals required before export

7) **Approvals + export**
- Artifact: approval log + export package outline
- Gate: missing approval → stop and request sign-off

#### Default budgets (example)
| Budget | Default |
|---|---|
| Tool calls | 14 |
| Retries | 2 per gate |
| Latency | 120 seconds (often interactive) |
| Authority | export/write actions require approval |

#### Telemetry you want from day one
- policy sources used + versions (or last verified timestamps)
- alignment rubric results (which objective failed, why)
- accessibility checklist results
- edits per iteration (how many revision loops)
- approvals captured (who/when) and stop reason

## Artifacts to produce
- A loop diagram for each case study (states + stop conditions).
- A step table for each case study: step → actions/tools → artifact → gate → stop behavior.
- A loop budget configuration for each case study (tool calls, retries, latency, authority).
- A standard “stop reason” taxonomy (success, budget, permission, approval, tool failure, policy violation).

## Chapter exercise
For both case studies:
1) Write explicit stopping conditions (success, budget exceeded, permission needed, irrecoverable tool failure).
2) Define a loop budget (max tool calls, retries, total time, and authority).
3) List the telemetry you need to debug failures and improve the loop.

Suggested format (copy/paste):

**Loop budget**
| Budget | Value | Notes |
|---|---:|---|
| max tool calls |  |  |
| max retries per gate |  |  |
| max latency seconds |  |  |
| authority |  |  |

**Stopping conditions**
| Stop reason | Trigger | User-facing response |
|---|---|---|
| success |  |  |
| budget exceeded |  |  |
| needs approval |  |  |
| missing permission |  |  |
| irrecoverable tool failure |  |  |

**Telemetry**
- inputs (audience, scope, “as-of” date, policies in scope)
- plan + step index
- tool calls (name, args, latency, status)
- artifact IDs/paths + validation results
- budgets consumed + stop reason

## Notes / references
- ReAct (reasoning + acting with tools): https://arxiv.org/abs/2210.03629
- OODA loop (control-loop framing): https://en.wikipedia.org/wiki/OODA_loop
- “Building Systems with the ChatGPT API” (tool use + moderation patterns): https://platform.openai.com/docs/guides/gpt
