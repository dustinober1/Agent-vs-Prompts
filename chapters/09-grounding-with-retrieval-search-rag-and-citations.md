# Chapter 9 — Grounding with retrieval: search, RAG, and citations

## Purpose
Replace “know things” with “find things and cite them.”

## Reader takeaway
Grounded outputs come from retrieval + constraints + citation discipline, not from “being accurate” instructions.

## Key points
- When retrieval is necessary (dynamic knowledge, large corpora, auditability)
- Retrieval spectrum: keyword, semantic, hybrid, reranking, structured queries
- Patterns: retrieve-then-read, iterative search, cite-then-answer, contradiction checks
- Failure modes: irrelevant retrieval, missing docs, citation laundering

## Case study thread
### Research+Write (Policy change brief)
- Hybrid retrieval: internal policy diffs + external guidance (if allowed)
- Citation rules: every claim references an internal doc ID or external link + quote

### Instructional Design (Annual compliance training)
- Ground truth: internal policy wiki/SOPs are the source of truth
- Source policy: licensed assets only; avoid copying external content into training

## Artifacts to produce
- Citation policy (Research+Write) + source/licensing/confidentiality policy (Instructional Design)

## Chapter exercise
Define a citation policy for Research+Write and a source/licensing/confidentiality policy for corporate training materials.

## Notes / references
- TODO: define “source trust tiers” and how the agent treats each tier

