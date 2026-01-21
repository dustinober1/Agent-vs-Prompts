# Chapter 3 — Prompt debt: the hidden cost of prompt-only solutions

## Purpose
Introduce maintenance, versioning, and testability.

## Reader takeaway
Prompt-only features accumulate “prompt debt” quickly because requirements, models, and knowledge sources change; you need contracts, versioning, and evals.

## Key points
- Prompt debt vs tech debt: why it’s harder to see
- Why prompts rot (requirements, model upgrades, tools/knowledge evolve, edge cases)
- Anti-patterns: mega prompts, business logic in prose, “please be accurate”
- Prompts as components with contracts

## Case study thread
### Research+Write (Policy change brief)
- Mega prompt tries to encode citation and confidentiality rules
- Break into components: router, researcher, writer, citation auditor/redaction checker

### Instructional Design (Annual compliance training)
- Mega prompt tries to encode compliance policy + pedagogy + accessibility
- Break into components: policy mapper, assessment designer, activity/scenario designer, alignment QA

## Artifacts to produce
- A prompt-component map with inputs/outputs for each component

## Chapter exercise
Refactor a “mega prompt” for one case study into roles: router, researcher, writer, verifier.

## Notes / references
- TODO: add a simple versioning convention for prompts and templates

