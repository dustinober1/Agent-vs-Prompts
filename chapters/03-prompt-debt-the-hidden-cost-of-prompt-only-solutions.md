# Chapter 3 — Prompt debt: the hidden cost of prompt-only solutions

## Purpose
Introduce maintenance, versioning, and testability for LLM prompts in production.

## Reader takeaway
Prompt-only features accumulate “prompt debt” as requirements, models, and knowledge sources change. Treat prompts as versioned components with contracts and evals—not as a single ever-growing blob of rules.

## Key points
- Prompt debt vs tech debt: why it’s harder to see
- Why prompts rot: requirements shift, model upgrades, tools/knowledge evolve, edge cases accumulate
- Anti-patterns: mega prompts, business logic in prose, “please be accurate”
- A better unit: prompt components with contracts (inputs/outputs/invariants)
- Minimum viable discipline: versioning, logging, and small eval sets

## Draft

### Prompt debt, defined
Prompt debt is the maintenance burden created when a prompt becomes the primary place you encode product behavior, policy, and downstream contracts.

A typical arc:
- Demo works → patch an edge case with another paragraph → add more rules for new requirements → model/tools change → the prompt becomes untouchable.

Symptoms:
- “One more paragraph” fixes today’s bug and breaks yesterday’s.
- Prompts grow faster than reliability.
- You can’t explain or audit *why* the system decided something.

### Why it’s sneakier than tech debt
- Prompts are probabilistic: small textual diffs can cause large behavioral diffs.
- Coupling is hidden: model/version, decoding, retrieval, and tool outputs all affect results.
- Failures are often silent: the output looks plausible even when it’s wrong.
- Interfaces aren’t enforced: “ONLY output JSON” is not schema validation.

### Why prompts rot
Prompts decay when the environment moves:
- **Requirements shift:** new fields, new constraints, new stakeholders’ definitions of “done”.
- **Models change:** format adherence, question-asking behavior, citation behavior, style defaults.
- **Sources/tools evolve:** docs move, retrieval changes, tool output shapes change.
- **Edge cases accumulate:** the prompt becomes a junk drawer of exceptions.

### Three anti-patterns (and the replacement)
1) **Mega prompt**
   - Smell: one prompt does routing + research + writing + policy + validation.
   - Replace with: 3–6 prompt components + validators.

2) **Business logic in prose**
   - Smell: auth, routing, regional rules described as “if…then…” text.
   - Replace with: code/config/policy engines + checks; prompts handle interface and constrained reasoning.

3) **“Please be accurate” as enforcement**
   - Smell: “don’t hallucinate / include citations” with no measurable check.
   - Replace with: required artifacts + validation (citations resolve, coverage thresholds, schema checks, alignment checks).

### Prompts as components with contracts
A prompt component is a small, named behavior you can test and version.

Minimal contract:
- Name, purpose, owner
- Inputs (required) + allowed tools/sources
- Outputs (shape/schema) + where stored
- Invariants you validate
- Failure response (retry / ask / fallback / human gate)
- Version

### Case study A: Research+Write (Policy change brief)
Treat `case_studies/research_write_policy_change_brief_TEMPLATE.md` as the output contract, and split the mega prompt:
- Router → route + plan + missing inputs
- Retriever (tool) → sources + excerpts
- Researcher → annotated sources + quotes
- Writer → brief draft in template structure
- Citation auditor (verifier) → claim-to-source coverage + gaps
- Redaction checker (verifier) → confidentiality pass/fail + fixes

Key shift: “include citations” becomes “produce and validate a claim map”.

### Case study B: Instructional Design (Compliance training)
Treat `case_studies/instructional_design_compliance_training_MODULE_TEMPLATE.md` as the contract, and split the mega prompt:
- Policy mapper → required topics + must/must-not + policy refs
- Objective builder → measurable objectives
- Scenario designer → scenarios + decision points + policy mapping
- Assessment writer → items + rationales + mapping
- Alignment QA (verifier) → objective↔activity↔assessment gaps
- Accessibility QA (verifier) → checklist gaps

Key shift: “make it aligned” becomes “block publish if alignment matrix has gaps”.

### Minimum viable discipline
- Version like APIs: major=contract change; minor=behavior improvement; patch=copy/clarity.
- Log what ran: component+version, model/version+settings, tool contract versions.
- Keep eval sets small: 10–30 cases per component, including past regressions.

## Case study thread
### Research+Write (Policy change brief)
- Break into components: router, retriever, researcher, writer, citation auditor, redaction checker
- Anchor template: `case_studies/research_write_policy_change_brief_TEMPLATE.md`

### Instructional Design (Annual compliance training)
- Break into components: policy mapper, objective builder, scenario designer, assessment writer, alignment QA, accessibility QA
- Anchor template: `case_studies/instructional_design_compliance_training_MODULE_TEMPLATE.md`

## Artifacts to produce
- A prompt-component map with inputs/outputs and invariants for each component
- A “prompt change log” convention (owner, version, reason, expected impact)
- A minimal eval set outline per component (10–30 cases + what to validate)

Suggested format (copy/paste):

| Component | Purpose | Inputs (required) | Outputs | Invariants (validated) | Failure response |
|---|---|---|---|---|---|
| | | | | | |

Prompt changelog entry (copy/paste):
- Component:
- Version:
- Date:
- Change:
- Why:
- Expected impact:
- Risks/regressions to watch:
- Evals updated? (yes/no):

## Chapter exercise
Refactor a “mega prompt” for one case study into roles: router, researcher, writer, verifier.

Checklist:
- Pick a prompt that keeps growing.
- List the distinct jobs it’s trying to do.
- Split into 3–6 components, each with:
  - purpose
  - required inputs
  - output artifact shape
  - one or two invariants you can validate
- Decide where each invariant is enforced (prompt vs tool vs validator vs human gate).
- Write 10 test cases that would have regressed in the old mega prompt.

## Notes / references
- Optional grounding:
  - Technical debt origin (Ward Cunningham): https://en.wikipedia.org/wiki/Technical_debt
  - Semantic Versioning: https://semver.org/
