# Chapter 20 — Cost, latency, and model routing in production

## Purpose
Keep agentic systems economically viable.

## Reader takeaway
Agent costs are driven by context growth and multi-step loops; control them with routing, caching, and early exits.

## Key points
- Cost drivers: context growth, loops, retrieval/reranking, sampling
- Optimization: compaction, caching, smaller models for substeps, early exit, batching/async
- SLAs: interactive vs background; progressive disclosure

## Case study thread
### Research+Write (Policy change brief)
- Use smaller models for extraction; larger for synthesis; cache retrieval/quotes
- Early exit if sources are insufficient or policies are restricted

### Instructional Design (Annual compliance training)
- Use templates to reduce generation; regenerate only deltas when policy changes
- Background exports; interactive preview of outlines and assessments

## Artifacts to produce
- Cost model spreadsheet outline (assumptions + budgets + guards)

## Chapter exercise
Create a cost model for either Research+Write or Instructional Design and set budget guards.

## Notes / references
- TODO: define routing policy (which model for which step) in a simple table

