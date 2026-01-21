# Chapter 17 — Reliability engineering for agents

## Purpose
Turn probabilistic models into dependable features.

## Reader takeaway
Reliability comes from retries, idempotency, fallbacks, budgets, and recoverable partial progress—not from hoping the model “tries harder”.

## Key points
- Failure handling: retries/backoff, idempotent tool calls, fallbacks, partial recovery
- Guardrails: budgets, safe defaults, constraint enforcement outside the model
- Determinism where it matters: structured outputs, stable tools, caching

## Case study thread
### Research+Write (Policy change brief)
- Retry strategy for fetch/search; cache retrieval results; refuse if sources can’t be verified
- Recovery: keep artifacts so a user can continue later without rerunning everything

### Instructional Design (Annual compliance training)
- Idempotent exports; rollback and versioning for LMS packages
- Recovery: keep approval state and regenerate only what changed

## Artifacts to produce
- Reliability checklist + runbook templates

## Chapter exercise
Create a runbook for “agent stuck in a loop” incidents.

## Notes / references
- TODO: define the most common incident classes and their user-facing behaviors

