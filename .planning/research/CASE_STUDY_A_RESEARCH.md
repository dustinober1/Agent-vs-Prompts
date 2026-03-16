# Research: Case Study A - Research+Write Agent

## Goal
Produce a well-structured written artifact grounded in sources.

## Key Findings from Outline
- **Typical requests**: "Write a brief on X", "Draft a blog post with citations", "Create a competitive landscape report".
- **Inputs**: topic, audience, length/format, constraints (tone, stance), allowed sources (hybrid: internal docs + web), citation style (flexible), freshness cutoff.
- **Outputs**: research plan, annotated sources, outline, draft, citations/bibliography, "open questions" list.
- **Tools**: web search, internal doc search, URL/doc fetch, document parsing, quote extraction, citation store, outline/draft renderer, plagiarism/duplication checks, redaction/classification checks.
- **Core risks**: fabricated or low-quality citations, cherry-picking, outdated info, copying phrasing too closely, leaking confidential/internal material.
- **Success checks**: citations resolve, claims trace to sources, coverage of key angles, consistent structure and tone, sensitive content handled per policy.
- **Anchor example artifact**: "Policy change brief" that cites internal policy diffs + external guidance/regulations (when allowed).

## Research Directions
1. **Tool APIs**: Define interfaces for `web_search`, `fetch`, `extract`, `cite`, `render`, `plagiarism_check`, `redaction_check`.
2. **Citation Policy**: hybrid sources, quote rules, and refusal conditions.
3. **Eval Suites**: citation resolvability, claim traceability, plagiarism/duplication, tone/format checks.
