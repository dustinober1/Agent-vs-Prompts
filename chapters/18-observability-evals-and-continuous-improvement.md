# Chapter 18 — Observability, evals, and continuous improvement

## Purpose
Make debugging and iteration measurable.

## Reader takeaway
You can’t improve what you can’t measure; traces + evals + rollout discipline are the real “prompt engineering”.

## Key points
- What to log: tool calls/results (redacted), plans, decisions/scores, user feedback
- Tracing: step spans, cost attribution, latency breakdown
- Evals: golden sets, injection suite, regression across model versions
- Deployment: staged rollouts, canaries, kill switches, feature flags

## Case study thread
### Research+Write (Policy change brief)
- Logs: what sources were used, what claims were made, what was redacted
- Evals: “citation resolves” and “claim traceability” regression tests

### Instructional Design (Annual compliance training)
- Logs: policy versions used, rubric results, approvals, export metadata
- Evals: alignment and accessibility regression tests across template/policy updates

## Artifacts to produce
- An eval plan and a minimal telemetry schema (what gets logged where)

## Chapter exercise
Define an eval pipeline and the “stop-ship” thresholds.

## Notes / references
- TODO: decide which artifacts are retained for audit vs discarded for privacy

