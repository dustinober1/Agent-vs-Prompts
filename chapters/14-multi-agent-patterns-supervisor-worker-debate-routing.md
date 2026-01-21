# Chapter 14 — Multi-agent patterns: supervisor/worker, debate, routing

## Purpose
Show how to decompose responsibility without chaos.

## Reader takeaway
Multi-agent systems help when roles have clear contracts and contexts are controlled; otherwise you just multiply confusion.

## Key points
- Why multiple agents: specialization, parallelism, separation of concerns
- Architectures: supervisor→workers→aggregator; router→specialists; bounded debate
- Coordination challenges: context explosion, conflicting objectives, debugging difficulty

## Case study thread
### Research+Write (Policy change brief)
- Roles: researcher → writer → citation auditor → editor
- Supervisor enforces: citations required, confidentiality policy, budget limits

### Instructional Design (Annual compliance training)
- Roles: objectives/policy mapper → assessment designer → activity/scenario designer → accessibility reviewer → QA aligner
- Supervisor enforces: alignment rubric + approval gates

## Artifacts to produce
- Role specs (inputs/outputs) and a minimal supervisor policy

## Chapter exercise
Design roles for both case studies and define each role’s input/output contract.

## Notes / references
- TODO: decide what context each role is allowed to see (least context principle)

