# Chapter 6 — Degrees of agency: when to use what

## Purpose
Prevent over-agenting; introduce a decision framework.

## Reader takeaway
Use the minimum viable agency that achieves reliability; escalate to agents only when task stakes and uncertainty demand it.

## Key points
- Not every LLM feature needs an “agent”; start with the simplest rung that can meet your acceptance criteria.
- Agency has two dials: **autonomy** (who chooses the steps) and **authority** (what side effects are allowed).
- Ladder: template → few-shot → structured output + validation → RAG → tool use → plan-and-execute → routed/multi-agent.
- Choose the rung using criteria: task length, uncertainty, stakes, freshness needs, side effects, latency/cost tolerance, and available ground-truth checks.
- Constrain the chosen rung with budgets, gates, and stopping conditions (so “more agency” doesn’t mean “more chaos”).

## Draft

### The trap: “just make it an agent”
In 2024–2026, teams fell into a predictable pattern:
- A prompt-only feature ships.
- It fails in edge cases.
- Someone proposes an “agent” as the upgrade.
- The “agent” is really a long prompt + a bunch of tool calls, with no constraints, no gates, and no observability.

That path often makes things worse:
- more moving parts to fail (tools, parsing, retries, state)
- more latency and cost
- more ways to leak data or take the wrong action
- harder debugging (“why did it do that?”)

This chapter is a counterweight. The point of “degrees of agency” is not to gatekeep: it’s to **choose deliberately**.

### Define “agency” so you can control it
In this book, “agency” is not a vibe. It’s a design choice about **who decides what happens next**.

Two practical dials:

#### Dial 1: Autonomy (sequencing)
How much freedom does the system have to decide the next step?
- low autonomy: one-shot response, no branching
- medium autonomy: fixed workflow with a few decisions (“if missing input, ask; else proceed”)
- high autonomy: open-ended planning with iterative actions and reflection

#### Dial 2: Authority (side effects)
What is the system allowed to do to the world?
- read-only: search, fetch, parse, summarize, compute
- write-with-approval: drafts, tickets, emails, updates (human must confirm)
- write-autonomous: direct changes to systems of record (rare; high-stakes)

Most product failures happen because these dials are turned up without constraints.

### The ladder: minimum viable agency (MVA)
The ladder is not a maturity model. It’s a **menu of solution shapes**. Most real systems mix rungs:
- structured outputs + validation *and* RAG
- tool use *inside* a plan-and-execute loop
- routing *for intake*, then a constrained workflow for execution

But the ladder helps you answer the design question: *What is the minimum capability set that can meet the requirement?*

Quick summary (least → most agentic):

| Rung | What it is | Good for | Common failure | Typical next upgrade |
|---:|---|---|---|---|
| 1 | Static prompt template | low-stakes rewriting/drafting | inconsistent structure | add examples (2) or validation (3) |
| 2 | Few-shot examples | style/format consistency | format still drifts | add schema validation (3) |
| 3 | Structured output + validation | machine-ingested outputs | missing/invalid fields | add retrieval (4) or tools (5) |
| 4 | RAG (retrieve then answer) | fresh/large corpora + citations | weak retrieval / wrong sources | add reranking, constraints, tools (5) |
| 5 | Tool use (APIs) | actions + deterministic checks | tool errors / misuse | add orchestration loop (6) |
| 6 | Plan-and-execute | multi-step tasks | loops / compounding error | add routing/supervision (7) |
| 7 | Routed / multi-agent | heterogenous tasks at scale | coordination overhead | add strong evals + ops discipline |

Use this table as an architectural checklist: if you skip a rung, be able to explain why.

### Rung-by-rung: what you gain (and what you risk)

#### 1) Static prompt template
**Shape:** One prompt, one response.

Use when:
- task is short and low-stakes
- inputs are already complete
- you can tolerate occasional variance
- no need for external data or actions

Typical examples:
- rewrite for tone
- summarize a provided document
- generate brainstorming options (clearly labeled as options)

Watch-outs:
- “hidden requirements” creep in (citations, formatting contracts, compliance constraints)
- prompt debt accumulates (Chapter 3)

Upgrade triggers:
- format drift becomes user-visible → add examples (2) or validation (3)
- knowledge must be current or sourced → add retrieval (4)

#### 2) Prompt + few-shot examples
**Shape:** One prompt + a handful of input→output exemplars.

Use when:
- you need output that “looks like this” consistently
- you can provide canonical examples of good behavior

Watch-outs:
- examples become stale (product evolves)
- you still have no enforcement (the model can ignore examples)

Upgrade triggers:
- downstream systems need reliability → add structured output + validation (3)

#### 3) Structured output + validation
**Shape:** Constrain outputs to a schema, then validate; fail closed when needed.

Use when:
- outputs are machine-ingested (JSON, tables, form fields)
- you can define “valid” structurally
- you want deterministic failure handling (retry, ask user, block)

The key shift:
- prompts become **suggestions** for structure
- validators become **enforcement** for structure

Watch-outs:
- you can validate structure without validating truth
- retries without a strategy can create loops

Upgrade triggers:
- correctness depends on external facts → add retrieval (4) or tools (5)

#### 4) RAG (retrieve then answer)
**Shape:** Retrieve relevant sources from a corpus, then answer grounded in those sources.

Use when:
- the answer must be based on a large or changing corpus
- you need citations or “show your work”
- you need permission-filtered access to internal knowledge

What RAG does *not* automatically give you:
- correct retrieval (you still need good indexing, query rewriting, reranking)
- correct reasoning (the model can still misread sources)
- safety (you still need policy enforcement and redaction)

Upgrade triggers:
- you need deterministic checks (citations resolve, excerpts match) → add tools (5)
- you need multi-step research (iterative search, contradiction checks) → add a loop (6)

#### 5) Tool use (call APIs)
**Shape:** The model chooses and calls tools: search, databases, calculators, ticketing systems, diffing, extractors, validators.

Use when:
- the task requires actions beyond text
- correctness relies on deterministic operations
- you need integration with systems of record

Important constraint:
- separate **read tools** from **write tools**
- treat write tools as higher-stakes and usually approval-gated

Watch-outs:
- tool errors and partial failures
- permission mistakes (least privilege violations)
- “tool spam” (calling tools without improving the answer)

Upgrade triggers:
- the tool sequence is long or branching → add orchestration (6)

#### 6) Multi-step plan-and-execute
**Shape:** Interpret intent → plan → take actions → observe → update state → verify → decide next step.

Use when:
- the task is long-horizon (multiple dependent steps)
- you need iterative research, drafting, verification
- you can define stopping conditions and budgets

What makes this safe:
- budgets (time/tool calls/retries)
- gates (schema/rubric/human approval)
- stored artifacts (plan, evidence, drafts, validations)

Watch-outs:
- compounding error across steps
- “agent runs away” (loops, overconfidence, unnecessary actions)
- higher operational burden (logs, metrics, incident response)

Upgrade triggers:
- tasks become heterogenous at scale → add routing/supervision (7)

#### 7) Supervisor/worker or routed agents
**Shape:** Multiple specialized components: intake router, researcher, writer, verifier; or supervisor/worker patterns.

Use when:
- you serve many distinct intents (support, research, ops, writing)
- different steps require different models/tool policies
- you want tighter least-context/least-privilege separation

Watch-outs:
- coordination overhead (handoffs, shared state, inconsistent assumptions)
- emergent complexity (harder to debug than a single workflow)

If you go here, you’re committing to operations:
- artifact store and traceability
- evaluation suites (offline and in-the-loop)
- versioning for prompts/tools/policies

### A decision framework: pick the rung, then constrain it
Use this sequence (it turns “agent design” into a repeatable decision):

#### Step 0: Confirm you need an LLM
Before rung 1, ask:
- Is this actually classification, lookup, or deterministic transformation?
- Do we already have structured data and rules?

If yes, don’t add agency. Add software.

#### Step 1: Write acceptance criteria first
If you can’t say what “good” means, you can’t pick a rung.

Minimum acceptance criteria template:
- Output format:
- Required fields/sections:
- Grounding requirement (citations? internal-only? freshness cutoff?):
- Safety constraints (what must not appear):
- Latency budget:
- Cost budget:
- Failure behavior (retry/ask/block/escalate):

#### Step 2: Score the task along the criteria that drive agency
Use a quick 0–3 scoring (low → high). You don’t need perfect numbers; you need clarity.

| Criterion | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| Task length | one-shot | 2–3 steps | 4–8 steps | 9+ steps / branching |
| Uncertainty | clear ask | minor ambiguity | needs clarification | unknowns dominate |
| Stakes | low | moderate | high | very high / regulated |
| Freshness need | none | occasional | frequent | always current |
| Side effects | none | draft only | write w/ approval | autonomous writes |
| Budget sensitivity | unconstrained | some | tight | extremely tight |
| Ground truth checks | strong | moderate | weak | none |

Interpretation:
- High freshness → you’re likely at least rung 4.
- Any side effects → you’re likely at least rung 5 (and need authority gating).
- Long tasks + weak ground truth → you need rung 6 *with strong budgets and human escalation* (not “more clever prompting”).

#### Step 3: Choose the minimum rung that can satisfy the acceptance criteria
Then add constraints so the system stays inside the lane:
- tool allowlist (read-only vs write tools)
- validation gates (schema, rubric, citation resolver)
- budgets (time/tool calls/retries)
- stopping conditions (success, budget exceeded, needs approval, tool failure)

Think of it as a contract:
- “We will do these steps.”
- “We will not do these steps.”
- “We will block when these checks fail.”

### Budgets: the control surface that keeps agency safe
Budgets are not “nice to have”. Budgets are what make autonomy non-dangerous.

Use four budgets in almost every system:

1) **Tool-call budget**
- max tool calls per request
- max calls per tool (avoid repeated search loops)

2) **Retry budget**
- max retries per validation failure
- retry backoff and alternative strategy (“retry” is not a strategy)

3) **Latency budget**
- max end-to-end time
- step-level timeouts for slow tools

4) **Cost budget**
- max spend per request (tokens + tools)

And one budget that teams forget:

5) **Authority budget**
- which write actions are allowed
- when human approval is required
- what “safe mode” looks like (read-only fallback)

If you set these budgets up front, “more agency” becomes “more capability within constraints,” not “more risk.”

### An escalation path: how you upgrade when reality hits
You rarely get the rung perfect on day one. A practical way to evolve is to tie upgrades to observed failure modes.

Example escalation map:
- format drift → add schema validation (3)
- outdated answers → add retrieval with citations (4)
- incorrect math/dates/eligibility logic → add tools (5)
- long tasks and missing steps → add planning + artifacts (6)
- mixed intents and inconsistent routing → add an intake router (7-lite)

The key is to upgrade in response to **measured failures**, not vibes.

## Case study thread

### Research+Write (Policy change brief)
Anchor template: `../case_studies/research_write_policy_change_brief_TEMPLATE.md`

#### Requirements that force agency
- Freshness: policies and guidance can change; you must cite the current version used.
- Grounding: key claims must map to sources and excerpts.
- Auditability: you need a reproducible evidence set (what was retrieved, when, by which version).
- Confidentiality: least-privilege retrieval + redaction/approval gates.

#### MVA decision (what rung, and why)
Minimum viable agency: **Rung 6 (plan-and-execute)**, constrained to **read-only tools** plus deterministic verification.

Why this is not a rung 1–3 problem:
- A perfect prompt cannot make up for missing evidence.
- A schema cannot enforce that facts are current or sourced.

Why rung 4 alone is not enough:
- RAG gives you sources, but you still need:
  - citation resolution (do links/doc IDs actually fetch?)
  - excerpt extraction (what text supports this claim?)
  - redaction/classification checks

Why you likely don’t need rung 7 (yet):
- The workflow is consistent and can usually be handled by a single constrained agent.
- Add routing later if you support many artifact types (briefs, emails, FAQs, release notes) with different rules.

#### Example scoring (0–3)
| Criterion | Score | Notes |
|---|---:|---|
| Task length | 3 | plan → search → fetch → extract → draft → verify → revise |
| Uncertainty | 2 | scope/audience often unclear; needs clarifying questions |
| Stakes | 3 | policy interpretation; could cause real-world mistakes |
| Freshness need | 3 | must reflect current policy/guidance versions |
| Side effects | 1 | typically draft-only; publishing is approval-gated |
| Budget sensitivity | 2 | needs bounded loops; not free-form searching forever |
| Ground truth checks | 1 | partial: citations resolve, but some interpretation remains |

#### A constrained workflow (read-only by default)
Suggested steps (single-agent, artifacts stored each step):
1) Intake + clarify (audience, scope, “as-of” date, allowed sources).
2) Plan (queries, internal docs to fetch, output outline).
3) Retrieve (internal search → fetch; optional external search if allowed).
4) Extract evidence (quotes/excerpts with doc IDs + section anchors).
5) Draft brief (claims written against evidence set).
6) Verify:
   - citations resolve (fetch succeeds)
   - every key claim has at least one supporting excerpt
   - redaction/classification passes for the audience
7) Deliver or escalate:
   - if verification fails: revise within retry budget
   - if ambiguity remains: ask user / request human policy-owner review

#### Budgets + gates (example)
| Control | Default |
|---|---|
| Tool allowlist | internal_search, fetch_doc, extract_quotes, cite_resolve, redaction_check |
| Write tools | none (draft only) |
| Max tool calls | 12 |
| Max retries | 2 per gate |
| Stop conditions | all gates pass; budget exceeded; needs approval; tool failure |
| Fail closed on | redaction/classification failure; missing required sources |

### Instructional Design (Annual compliance training)
Anchor template: `../case_studies/instructional_design_compliance_training_MODULE_TEMPLATE.md`

#### Requirements that force agency
- Alignment: every objective must be practiced and assessed (no “nice-to-have” gaps).
- Policy accuracy: content must map to current policy/SOP sources.
- Accessibility: required checks before publishing.
- Audit trail: approvals and “last verified” dates are part of the deliverable.

#### MVA decision (what rung, and why)
Minimum viable agency: **Rung 6 (plan-and-execute)**, but with a **fixed workflow** and strong validators. In practice, this looks like orchestration more than “autonomous reasoning.”

Why this is not a rung 1–2 problem:
- The hard part is not writing; it’s alignment + correctness + auditability.

Why rung 3 is necessary (but insufficient):
- You need structured artifacts you can validate (alignment tables, item banks, checklists).
- But validators still need current policy inputs (retrieval) and deterministic checks (tools).

Why rung 5 is necessary:
- You need tools for:
  - policy/SOP lookup (system of record)
  - template library retrieval
  - accessibility checklist checks
  - (optional) LMS export packaging

#### Example scoring (0–3)
| Criterion | Score | Notes |
|---|---:|---|
| Task length | 3 | objectives → flow → scenarios → assessments → checks → export |
| Uncertainty | 2 | learner context and constraints often incomplete |
| Stakes | 3 | compliance training; audit exposure |
| Freshness need | 3 | policies change; training must reflect current versions |
| Side effects | 2 | exports/updates are write actions (usually approval-gated) |
| Budget sensitivity | 2 | bounded iteration; avoid endless rewrites |
| Ground truth checks | 2 | strong structural checks (alignment/accessibility), partial content truth |

#### A fixed workflow with validators (the “agent” is the coordinator)
Suggested steps:
1) Intake + constraints (role, region, time, modality, policies in scope).
2) Retrieve sources (policies/SOPs + existing training templates).
3) Draft objectives (performance-based) and module flow.
4) Generate practice activities + scenarios.
5) Generate assessments + rubrics.
6) Validate:
   - objective↔practice↔assessment alignment rubric
   - accessibility checklist
   - policy mapping completeness (“every module section maps to a source”)
7) Prepare export package (approval-gated).
8) Record approvals (Security/Legal/SME) and publish.

#### Budgets + gates (example)
| Control | Default |
|---|---|
| Tool allowlist | policy_lookup, template_fetch, alignment_check, accessibility_check, export_prep |
| Write tools | export_prep requires approval |
| Max tool calls | 14 |
| Max retries | 2 per gate |
| Stop conditions | all gates pass; needs approval; budget exceeded |
| Fail closed on | alignment failures; missing policy mappings; accessibility failures |

## Artifacts to produce

### Minimum viable agency (MVA) decision record
Copy/paste template (fill one per feature):
```yaml
feature:
  name: ""
  user_job: ""
  primary_artifact: ""

acceptance_criteria:
  required_sections: []
  grounding:
    citations_required: true
    allowed_sources: []
    freshness_cutoff: ""
  safety_constraints: []

agency_choice:
  rung: 0
  autonomy: "low|medium|high"
  authority: "read-only|write-with-approval|write-autonomous"
  rationale: ""

tools:
  allowlist: []
  write_tools_require_approval: []

gates:
  - name: ""
    type: "schema|rubric|tool-check|human-approval"
    fail_response: "retry|revise|ask|escalate|block"

budgets:
  max_tool_calls: 0
  max_retries_per_gate: 0
  max_latency_seconds: 0
  max_cost_usd: 0

stopping_conditions: []
escalation_path:
  - observed_failure: ""
    upgrade: ""
```

### Budget + gates table
For each feature, write a one-page table that makes trade-offs explicit:
- what you will block on (fail closed)
- what you will retry
- what requires human approval
- what you will not do at all (denylist)

## Chapter exercise
1) For each case study, fill an MVA decision record:
   - Research+Write: a policy change brief with citations and confidentiality constraints.
   - Instructional Design: annual compliance training module with alignment + accessibility gates.
2) Pick 3 features from your own product and do the same.
3) For one feature, write an escalation path:
   - list your top 3 observed failure modes
   - for each, pick the smallest rung upgrade that addresses it

Suggested output (per feature):
- one paragraph describing the user job
- a completed scoring table (0–3)
- an MVA choice (rung + autonomy + authority)
- budgets + gates (what you block on)

## Notes / references
- ReAct (reasoning + acting for tool use): https://arxiv.org/abs/2210.03629
- Retrieval-Augmented Generation (RAG framing): https://arxiv.org/abs/2005.11401
- Toolformer (models learning tool use): https://arxiv.org/abs/2302.04761
- OWASP Top 10 for LLM Applications (risk categories): https://owasp.org/www-project-top-10-for-large-language-model-applications/
- NIST AI RMF 1.0 (risk framing and controls): https://www.nist.gov/itl/ai-risk-management-framework
