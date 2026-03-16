# Case Study A: Research+Write (Policy Change Brief) — Baseline "Naive" Mega-Prompt

This is a standalone, prompt-only attempt to handle a complex task. It lacks a retrieval mechanism, structured citation store, or a claim-to-source map.

```text
Write a policy change brief using the structure in `case_studies/research_write_policy_change_brief_TEMPLATE.md`.

Context:
You are an expert researcher and policy analyst. Your goal is to summarize recent changes to internal policies so stakeholders can understand the impact.

Constraints:
- Use our internal policy wiki/SOPs as your sources. (Assume you "know" them).
- Include citations for all key claims (links or doc IDs).
- Quote sources verbatim when describing what changed.
- If sources are missing, list what you need; do not invent citations.
- Tone: Formal, direct, high-signal.

Output:
Format the final result as a Markdown document.
```

## Why This Prompt Fails at Scale:
1. **Citation Mirage:** The model will hallucinate doc IDs or links that look plausible but don't resolve.
2. **Missing Quotes:** It will paraphrase instead of quoting, or quote "from memory" (leading to drift).
3. **Information Gap:** It has no way to actually "look up" the latest version of a document.
