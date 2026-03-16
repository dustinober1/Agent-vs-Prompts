# Retrieval Map: Research+Write (Case Study A)

## Retrieval Pipeline

1.  **Query Expansion:** Rewrite user intent into search queries for internal policy wiki.
2.  **Hybrid Search:** Combine BM25 (keyword) and Semantic (vector) search over the `internal_policy_wiki` corpus.
3.  **Metadata Filtering:** Filter by `policy_area` and `confidentiality_level` (match user context).
4.  **Reranking:** Score the top 20 results for relevance to the specific policy update.
5.  **Selection:** Pick the top 5 documents; extract relevant snippets and full-text sections.

## Source Trust Tiers

| Tier | Source Type | Usage | Verification Requirement |
| :--- | :--- | :--- | :--- |
| **Tier 1** | Official Policy Wiki / SOPs | **REQUIRED** for all key claims | `cite_resolve` + verbatim quote match |
| **Tier 2** | Internal Guidance / FAQs | Support context only | `cite_resolve` |
| **Tier 3** | External Regulatory Docs | Industry comparison only | Link must resolve; mark as External |

## Citation Policy

- **All Key Claims:** Must have a Tier 1 citation (Doc ID, Section, Verbatim Quote).
- **Format:** `[Source ID: POL-XYZ, Section: 1.2, Quote: "..."]`.
- **Gaps:** If no Tier 1 source is found for a required section, mark as `[NEEDS SOURCE]` and block publication.
- **Verification Gate:** `cite_verify` tool must return 100% success before delivery.
