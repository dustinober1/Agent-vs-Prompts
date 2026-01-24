# Chapter 2 — Failure modes you can’t prompt away

## Purpose
Make the limits of prompting concrete with a taxonomy of failures.

## Reader takeaway
The most important failures are systemic (missing data, hidden constraints, long-horizon drift, adversarial inputs). You can reduce them with better prompts, but you can’t eliminate them without detection and system controls.

## Key points
- Hallucination vs fabrication vs speculation
- Context limits and information overload
- Hidden assumptions and “unknown unknowns”
- Long-horizon compounding error
- Non-determinism and variance
- The “format trap” (JSON/citations/structure drift)
- Adversarial inputs: prompt injection, jailbreaks, social engineering

## Draft

### Why users don’t care about your taxonomy (but you should)
Users don’t experience “hallucination” or “context window limits”. They experience:
- Incorrect actions or advice
- Broken workflows (invalid JSON, missing fields, wrong structure)
- Unreliable behavior (“it worked yesterday”)
- Risk (confidentiality leaks, policy violations)

The taxonomy matters because different failures require different *detection* and different *controls*. If you can’t detect a failure mode, you can’t manage it.

### Hallucination vs fabrication vs speculation
These terms blur in practice, but they’re useful when you design checks:

- **Hallucination:** an ungrounded statement that happens to be plausible.
- **Fabrication:** invented details presented as if they were sourced facts.
- **Speculation:** a guess or hypothesis that should be labeled as uncertainty.

From a user’s perspective, they’re all “wrong”. From a system’s perspective, the question is: *Can we detect it before it ships?*

### Failure mode #1: Missing or weak grounding
**What it looks like:**
- Confident claims without sources
- Citations that don’t resolve (or don’t support the claim)
- “Best practices” that sound right but don’t match your environment

**Why prompts don’t fix it:**
- A prompt can request sources, but it can’t fetch them.
- “If you don’t know, say so” is not a guarantee; it’s a preference the model may ignore under pressure to be helpful.

**Minimum detectability signals:**
- Every “key claim” has a source pointer (URL/doc ID) and an excerpt/quote.
- Citations resolve (the system can actually fetch/locate them).
- Claim-to-source coverage: the ratio of claims that map to sources.

### Failure mode #2: Context window constraints and information overload
**What it looks like:**
- Important constraints silently dropped (region, audience, policy, formatting)
- The model “forgets” earlier details in long interactions
- Long documents are summarized incorrectly (or the wrong parts are emphasized)

**Why prompts don’t fix it:**
- You can’t prompt your way into a larger context window.
- When the prompt contains “everything”, attention becomes a bottleneck: the model may comply with some constraints and miss others.

**Minimum detectability signals:**
- Required fields present (e.g., audience, scope, freshness cutoff, confidentiality level).
- Constraint echo: the output explicitly restates key constraints before acting on them.
- “Missing input” detection: the system flags when required fields are absent instead of proceeding.

### Failure mode #3: Hidden assumptions and “unknown unknowns”
**What it looks like:**
- The model fills gaps with assumptions (sometimes reasonable, often wrong)
- A “complete” artifact that is built on the wrong premise
- Stakeholders disagree because the model chose a default nobody approved

**Why prompts don’t fix it:**
- Models are optimized to continue; they’ll often choose a plausible path rather than stop.
- Prompts can encourage questions, but they can’t guarantee the *right* questions are asked at the right time.

**Minimum detectability signals:**
- An explicit “assumptions” list (or “open questions”) when inputs are incomplete.
- A gate that blocks execution when high-impact inputs are missing (e.g., confidentiality level, allowed sources).

### Failure mode #4: Long-horizon tasks and compounding error
**What it looks like:**
- The first step is slightly wrong, and every later step amplifies it
- Intermediate artifacts drift from the original intent
- A plan looks good, but execution quietly deviates

**Why prompts don’t fix it:**
- Multi-step reliability is not the same as single-response quality.
- Prompt rules don’t create checkpoints; they just add prose.

**Minimum detectability signals:**
- Step-level artifacts (plan, retrieved sources, outline, draft, checks) are stored and inspectable.
- Each step has a verification outcome (pass/fail + reason).
- Retry counts and fallback paths are recorded (so you can see instability, not just outcomes).

### Failure mode #5: Non-determinism and variance
**What it looks like:**
- Same input, different outputs (sometimes materially different)
- Output quality changes across model versions or latency/cost constraints
- “It depends on the day” behavior that erodes trust

**Why prompts don’t fix it:**
- Temperature, tool latency, and retrieval results change outcomes.
- Prompts reduce variance on the happy path, but they can’t remove stochasticity or upstream variability.

**Minimum detectability signals:**
- Variance monitoring: sampled re-runs for key flows (or eval runs) to measure drift.
- Model/version logging for every output (so you can attribute changes).
- Confidence is treated as *data* (a signal), not as a guarantee.

### Failure mode #6: The format trap (contracts that break)
**What it looks like:**
- “Valid JSON” that still violates a schema or misses required fields
- Tables that shift columns or reorder in ways downstream can’t handle
- Citations that are formatted correctly but are substantively wrong

**Why prompts don’t fix it:**
- “ONLY output JSON” is not a validator.
- A schema pasted into the prompt is not the same as a contract enforced by software.

**Minimum detectability signals:**
- Parse success (JSON/YAML/etc) and schema validation pass/fail.
- Required-field presence checks.
- Citation resolution checks (not just citation formatting).

### Failure mode #7: Adversarial inputs (prompt injection, jailbreaks, social engineering)
**What it looks like:**
- A user or document attempts to override system instructions
- The model is tricked into leaking sensitive info or using forbidden tools
- “Helpful” behavior becomes a security incident

**Why prompts don’t fix it:**
- Attackers can target the prompt itself.
- “Please ignore malicious instructions” is not a security boundary.

**Minimum detectability signals:**
- Injection detection signals (patterns, classifiers, or rule-based checks).
- Tool-call policy denials and “safe mode” triggers are logged.
- Outputs run through a confidentiality/policy check before release.

### The minimum detectability signals (baseline instrumentation)
If you instrument nothing else, instrument these:
- **Input completeness:** required fields present (audience, scope, allowed sources, confidentiality).
- **Grounding coverage:** key claims map to sources; citations resolve; excerpt/quote captured.
- **Contract validity:** output parses; schema/required-field checks pass.
- **Tool health:** tool errors, timeouts, and latency (by tool).
- **Decision trace:** plan + tool calls + intermediate artifacts retained (at least temporarily).
- **Safety events:** injection signals, policy denials, redaction hits, “safe mode” triggers.
- **Variance hooks:** model/version logged; periodic re-runs/evals for drift.

These are not “nice to have”. They are the minimum needed to turn failures into debuggable incidents instead of mysteries.

In the next chapter, we'll see how these failures accumulate over time into *prompt debt*—and why that debt is harder to see and repay than the technical debt you're used to.

## Case study thread
### Research+Write (Policy change brief)
- Fabricated or low-quality citations:
  - What it looks like: “Policy X requires Y” with citations that don’t resolve, or with no excerpt/quote support.
  - Signals: citation resolution failures; missing excerpt/quote for key claims; low claim-to-source coverage.
  - Response: block publish; request sources/retrieval; require a claim-to-source map for release.
- Citation laundering (“sounds cited but isn’t”):
  - What it looks like: a real source is listed, but it doesn’t actually support the claim being made.
  - Signals: claim-to-source map requires a quote/excerpt per key claim; verifier flags “quote doesn’t support claim”.
  - Response: treat as grounding failure; revise claim or retrieve stronger evidence.
- Confidentiality risk when mixing internal + web sources:
  - What it looks like: internal doc IDs or sensitive details appear in an externally shareable brief.
  - Signals: confidentiality level mismatch; redaction/policy checks; “external allowed = no” but web-style citations appear.
  - Response: safe mode/redaction; human review gate for external sharing.
- Anchor template: `case_studies/research_write_policy_change_brief_TEMPLATE.md`

### Instructional Design (Annual compliance training)
- Misalignment (objectives ≠ activities ≠ assessments):
  - What it looks like: objectives describe job behaviors; assessments test definitions; scenarios don’t practice the behaviors.
  - Signals: an alignment table that requires every objective to be practiced and assessed (no gaps allowed).
  - Response: block publish until alignment passes; rewrite objectives/activities/assessments as a set.
- Policy drift (training contradicts the current policy wiki/SOPs):
  - What it looks like: a module ships with last quarter’s rules because “the model remembered it that way”.
  - Signals: policy section references + “last verified” dates; freshness cutoff; missing policy mapping flagged.
  - Response: force policy lookup; fail if policies aren’t retrieved/verified within the freshness window.
- Accessibility issues that aren’t fixed by “please be accessible”:
  - What it looks like: missing captions, poor contrast, unreadable copy, missing alt text, no localization notes.
  - Signals: accessibility checklist completion; reading-level/length checks; missing-alt-text flags (when assets exist).
  - Response: fail checks; remediate before export.
- Anchor template: `case_studies/instructional_design_compliance_training_MODULE_TEMPLATE.md`

## Artifacts to produce
- A failure-mode matrix for each agent (impact × likelihood × detectability).
  - Example row (Research+Write):
    - Failure: unresolved citations
    - Signal: citation resolution < 100%
    - Response: block publish + request retrieval
- A short list of “stop-ship” failures (the ones you refuse to publish without a gate):
  - Unresolved citations for key claims (Research+Write)
  - Missing policy mapping or stale policy verification (Instructional Design)
  - Confidentiality/policy check failure for the intended audience
  - Contract failure for machine-ingested outputs (schema/required-field checks fail)
  - Injection/suspicious instruction signals when tools/data access are involved
- A baseline “detectability dashboard” checklist (signals you can actually measure):
  - Grounding: citation resolution rate; claim-to-source coverage
  - Contracts: schema pass rate; missing required fields
  - Safety: policy denials; safe mode/redaction triggers
  - Tools: error rate and latency by tool
  - Drift: retries/fallbacks per request; model/version distribution

## Chapter exercise
Write a “failure budget” for both case studies: what can go wrong, how you’ll detect it, and what you’ll do when detection fires.

Suggested format (copy/paste for each case study):

| Failure mode | Impact | Likelihood | Detectability | Signal(s) | Gate / response |
|---|---:|---:|---:|---|---|
| Objective not assessed | High | Medium | High | Alignment table has a gap | Block publish; regenerate assessment + scenario |
| | | | | | |

Rules of thumb:
- If a failure is **high impact** and **hard to detect**, it requires a **human gate** or a redesign (don’t ship it “best effort”).
- If a failure is **high likelihood**, invest in detection early so you can measure improvement.
- If you can’t describe the signal, you don’t actually have a plan to manage the failure.

## Notes / references
- Optional further reading (for later chapters):
  - Truthfulness and hallucination measurement (TruthfulQA): https://arxiv.org/abs/2109.07958
  - Retrieval-Augmented Generation (RAG): https://arxiv.org/abs/2005.11401
  - Indirect prompt injection in integrated apps: https://arxiv.org/abs/2302.12173
  - OWASP Top 10 for LLM applications: https://owasp.org/www-project-top-10-for-large-language-model-applications/
