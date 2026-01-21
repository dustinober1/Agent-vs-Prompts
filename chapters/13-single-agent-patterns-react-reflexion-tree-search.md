# Chapter 13 — Single-agent patterns: ReAct, Reflexion, tree search

## Purpose
Provide a toolbox of patterns and when to use them.

## Reader takeaway
Single-agent patterns can increase quality when bounded by evaluators; uncontrolled reflection loops waste budget and add risk.

## Key points
- ReAct loops (reasoning + tool use)
- Reflexion with guardrails
- Branching/tree search: generate → score → select
- Sampling/self-consistency: when it helps vs when it wastes money

## Case study thread
### Research+Write (Policy change brief)
- Generate 3 outlines → evaluate coverage + citation feasibility → choose 1

### Instructional Design (Annual compliance training)
- Generate 3 module flows → evaluate alignment + time fit + accessibility risk → choose 1

## Artifacts to produce
- A bounded “generate 3 → evaluate → pick 1” workflow spec

## Chapter exercise
Implement a “generate 3 → evaluate → pick 1” workflow for either 3 Research+Write outlines or 3 Instructional Design lesson flows.

## Notes / references
- TODO: define evaluator scoring and tie-break rules

