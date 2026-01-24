# Chapter 5 — Prompts are interface; agents are systems

## Purpose
Define the mental model shift from text to systems engineering.

## Reader takeaway
Treat the model as a reasoning module inside a system with boundaries, state, observability, and invariants.

## Key points
- Systems thinking: inputs, outputs, constraints, state transitions, observability, invariants
- Tasks (intent) vs actions (tools) vs artifacts (outputs)
- “Make the environment do the work”: store facts externally, compute with tools, verify with tests
- A minimal “agent spec” turns vague behavior into an owned, versioned system contract

## Draft

### The shift: from “write better prompts” to “design better systems”
By now, the argument should feel clear:
- Prompts are necessary.
- Prompts are not sufficient.

Chapter 4 drew a boundary: prompts are great for interface (clarity, structure, voice), but not for enforcement (security, contracts, evals, retries). This chapter goes one level deeper: what does it mean to treat an LLM feature as a *system*?

The simplest mental model is:
- **Prompts are the interface layer**: they describe the job and shape the output.
- **The agent is the system**: it chooses actions, calls tools, stores state, and verifies results.

### The LLM is a reasoning module, not a database
Models are good at:
- turning messy input into a structured plan
- writing clear drafts in a given voice and structure
- mapping between representations (bullets → table; outline → section)
- generating candidates for later verification (queries, hypotheses, options)

Models are not good at being your:
- **source of truth** (they don’t “contain your policy wiki”)
- **authorization system** (“don’t reveal secrets” isn’t access control)
- **deterministic function** (you can reduce variance, not eliminate it)
- **audit trail** (you need stored artifacts + tool traces)
- **policy engine** (rules change, need owners, and must be testable)

If you treat the model like a database, you will ship confident drift (outputs that *feel* correct but silently diverge from ground truth). If you treat it like a reasoning component, you can build a system that is reliable and inspectable.

### Systems thinking for agentic LLM features
A useful way to operationalize “system” is to force yourself to name five things:

#### 1) Inputs
What comes in, and what must be present before you act?
- user request (intent)
- required metadata (audience, scope, confidentiality, freshness cutoff)
- context objects (documents, evidence snippets, templates)

If an input is required and missing, the system should *block or ask*, not guess.

#### 2) Outputs (artifacts)
What do you produce that someone else depends on?
- a plan
- retrieved sources + excerpts
- a draft
- a checklist
- an alignment table
- a final deliverable

Treat these as first-class artifacts (stored, versioned, and reviewable), not just words in a chat transcript.

#### 3) Constraints
What must always be true?
- allowed sources only
- no confidential leakage
- cite every key claim (and citations resolve)
- objectives must be assessed and practiced
- time/cost budgets

Constraints are only real when they are enforced by gates (validators, policies, or human approval).

#### 4) State transitions
What are the stages, and what moves the system from one stage to the next?

Example state machine (generic):
```
intake → clarify → plan → act(tool) → observe → update state → verify → (revise | deliver | escalate)
```

Notice what’s missing: “write a longer prompt”. Reliability comes from explicit stages and checks.

#### 5) Observability
When something goes wrong, can you answer:
- what tool calls happened?
- what sources were used?
- what failed validation?
- which prompt/component version ran?
- which model + settings ran?

If you can’t answer those questions, you don’t have a system—you have a demo.

### The core abstraction: tasks vs actions vs artifacts
This book will keep coming back to a simple distinction:
- **Task (intent):** what the user wants accomplished
- **Action (tool):** what the system does in the world (search, fetch, parse, calculate, create ticket)
- **Artifact (output):** what the system produces and stores (plan, evidence set, draft, report, checklist)

If you keep these separate, design becomes easier:
- tasks map to **workflows**
- actions map to **tool APIs**
- artifacts map to **schemas/templates**

Here’s how it looks in our two running case studies:

| Agent | Task (intent) | Actions (tools) | Artifacts (outputs) |
|---|---|---|---|
| Research+Write | “Write a policy change brief with citations” | search internal docs, fetch pages, extract quotes, resolve citations, run redaction check | brief draft, sources list, claim-to-source map, redaction report |
| Instructional Design | “Design annual compliance training aligned to policy” | fetch current policies/SOPs, apply templates, run alignment rubric, accessibility checks, prepare LMS export | module outline, scenarios, item bank, alignment table, approval log |

This isn’t theory. It’s how you make the work testable: you can validate an artifact and measure an action’s success rate.

### “Make the environment do the work”
Most prompt-only systems fail because they make the model do jobs that the environment can do better.

You want the environment (tools + storage + validators) to carry the weight of:

#### Store facts externally
Instead of “remember policy text”, store and retrieve it:
- keep policies/SOPs in a versioned system of record
- retrieve the relevant sections on demand (permission-filtered)
- store the evidence snippets that were actually used in the output

The model’s job becomes: *interpret and use evidence*, not *invent and remember facts*.

#### Compute with tools
Any time correctness matters and a tool exists, prefer tools:
- date math and deadlines
- diffing “before vs after” policy text
- checking that citations resolve
- checking for required fields (schema validation)
- running readability/accessibility checks

#### Verify with tests (gates)
Verification isn’t a vibe. It’s a pass/fail gate on an artifact:
- “All key claims have sources and quotes” (Research+Write)
- “No objective lacks practice + assessment evidence” (Instructional Design)
- “Output parses and meets schema” (machine-ingested outputs)
- “Policy mapping present and last verified date within freshness window”

If you can’t state the check, you can’t enforce the requirement.

### System boundaries: what belongs in the model vs tools vs humans
When you design an agentic system, you’re choosing boundaries:

- **Inside the model (good fit):**
  - drafting, rewriting, summarizing
  - proposing plans, queries, and decompositions
  - mapping between structures (outline ↔ draft; bullets ↔ table)
  - generating candidate scenarios and assessment items

- **Inside tools/services (good fit):**
  - retrieval (search/fetch)
  - deterministic transforms (parsing, extraction, diffing)
  - policy enforcement (auth, least privilege)
  - validation (schemas, rubrics, checkers)
  - storage (artifacts, logs, versions)

- **Inside human review (often required):**
  - high-stakes approvals (legal/privacy/security)
  - ambiguous brand/voice decisions
  - exception handling (“ship despite failing check”)
  - accountability decisions (“this is accurate enough to publish”)

The mistake is not using humans. The mistake is pretending prompts replace them.

### A minimal “agent spec” (so later chapters have something concrete)
To make the rest of the book practical, here’s a minimal agent spec format you can reuse. Keep it short, owned, and versioned.

Copy/paste template:
```yaml
agent:
  name: ""
  goal: ""
  owner: ""
  version: ""

inputs:
  required:
    - name: ""
      description: ""
  optional:
    - name: ""
      description: ""

artifacts:
  - name: ""
    format: "markdown|json|table"
    template: ""
    storage: ""

tools:
  allowed:
    - name: ""
      purpose: ""
      inputs: ""
      outputs: ""
  denied:
    - name: ""

policies_and_constraints:
  - ""

invariants_and_gates:
  - invariant: ""
    validator_or_gate: "schema|rubric|tool-check|human-approval"
    fail_response: "retry|revise|ask|escalate|block"

budgets:
  max_tool_calls: 0
  max_latency_seconds: 0
  max_cost_usd: 0

telemetry:
  log:
    - model_and_settings
    - prompt_component_versions
    - tool_calls_and_errors
    - artifacts_and_validation_results
```

This spec forces the question that prompts can’t answer: *What does the system guarantee, and how do we know?*

With this systems mindset established, the next question is: how much agency does a given task actually need? Chapter 6 introduces a ladder of solutions—from static prompts to multi-agent orchestration—so you can choose the simplest architecture that still works.

## Case study thread
### Research+Write (Policy change brief)
- Draw the boundary:
  - Model: turns evidence into a readable brief; asks clarifying questions; extracts key claims.
  - Tools: retrieve policy docs; extract quotes; resolve citations; diff policy sections.
  - Validators: citation resolution + claim-to-source coverage; redaction/confidentiality check.
  - Human review (as needed): policy owner signs off on interpretation and required actions.
- Example invariants:
  - Every key claim maps to a retrieved source with a quote/excerpt.
  - Citations resolve (links/doc IDs fetch successfully).
  - Confidentiality level matches the intended audience (no internal-only details in external output).

### Instructional Design (Annual compliance training)
- Draw the boundary:
  - Model: drafts module flow, scenarios, and assessment items in a consistent learner voice.
  - Tools: fetch current policies/SOPs; pull role/context templates; prep LMS export outline.
  - Validators: objective↔activity↔assessment alignment rubric; accessibility checklist; “source-of-truth mapping” completeness.
  - Human review: Security + Legal/Privacy approvals with an audit trail.
- Example invariants:
  - Every objective is practiced and assessed (no gaps allowed).
  - Content is mapped to current policy/SOP sources with “last verified” dates.
  - Accessibility checklist is complete before publishing/export.
  - Approvals recorded for audit.

## Artifacts to produce
- System boundary diagrams for both case studies (model vs tools vs validators vs humans)
- A minimal agent spec for each case study (use the template above)
- A short invariants list per agent (“what must always be true”)

## Chapter exercise
Draw the system boundary for both case studies (what’s inside/outside the model), then write a minimal agent spec.

Suggested format (copy/paste for each case study):

1) **Boundary diagram (boxes)**
```
[User/UI] → [Prompted model] → [Tools] → [Validators/Gates] → [Artifact store] → [Final output]
                            ↘→ [Human review (optional/required)]
```

2) **Tasks vs actions vs artifacts**
| Task (intent) | Actions (tools) | Artifacts (outputs) | Gate (pass/fail) |
|---|---|---|---|
| | | | |

3) **Invariants (what must always be true)**
- Invariant:
  - How verified (validator/gate):
  - What happens on failure (retry/revise/ask/escalate/block):

4) **Agent spec**
- Fill in the YAML template from the Draft section, and give it:
  - an owner
  - a version
  - 3–5 invariants you’re willing to block on

## Notes / references
- NIST AI RMF 1.0 (risk framing and controls): https://www.nist.gov/itl/ai-risk-management-framework
- NIST AI RMF Generative AI Profile: https://www.nist.gov/itl/ai-risk-management-framework/ai-rmf-generative-ai-profile
- OWASP Top 10 for LLM Applications: https://owasp.org/www-project-top-10-for-large-language-model-applications/
- OpenAI function calling updates (tooling + structured outputs context): https://help.openai.com/en/articles/8555517-function-calling-updates
- OpenAI Structured Outputs (stronger contract enforcement than “ONLY output JSON”): https://openai.com/index/introducing-structured-outputs-in-the-api/
- ReAct (reasoning + acting framing for tool-using agents): https://arxiv.org/abs/2210.03629
