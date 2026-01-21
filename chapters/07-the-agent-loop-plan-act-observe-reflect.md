# Chapter 7 — The agent loop: plan → act → observe → reflect

## Purpose
Establish a canonical loop to reference throughout the book.

## Reader takeaway
A reliable agent is a bounded control loop with explicit stopping conditions and measurable success criteria.

## Key points
- Minimal loop: interpret → plan → tool call → parse → update state → decide next step
- Reflection as checks: sanity, constraints, uncertainty, clarifying questions
- Stopping conditions: success, budget exceeded, permission needed, irrecoverable tool failure

## Case study thread
### Research+Write (Policy change brief)
- Plan steps: clarify → gather sources → extract quotes → outline → draft → verify → revise
- Stopping: all claims mapped; citations resolve; redaction check passes

### Instructional Design (Annual compliance training)
- Plan steps: clarify constraints → objectives + policy mapping → assessment plan → scenarios → QA checks → approvals → export
- Stopping: alignment rubric passes; accessibility passes; approvals recorded

## Artifacts to produce
- A plan representation for each agent (steps + artifacts + success criteria)
- A stopping-conditions checklist

## Chapter exercise
Write stopping conditions for both case studies and list the telemetry you’ll need.

## Notes / references
- TODO: define a “loop budget” (max tool calls, retries, total time)

