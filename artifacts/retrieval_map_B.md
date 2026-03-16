# Retrieval Map: Instructional Design (Case Study B)

## Retrieval Pipeline

1.  **Topic Mapping:** Extract required policy topics from learner job descriptions and constraints.
2.  **Lookup stage:** Call `policy_lookup` for each topic; fetch the latest approved SOPs.
3.  **Template stage:** Fetch training templates from the `approved_templates` repository.
4.  **Freshness Check:** Verify each policy reference's `last_verified` date is < 30 days old.
5.  **Selection:** Include only Tier 1 policy text and approved pedagogical snippets.

## Source & Licensing Policy

- **Policy claims:** Must cite internal Tier 1 sources (Latest SOP/Policy).
- **Template use:** Must be from the `approved_templates` corpus; no external templates.
- **Media/Assets:** Use only internal asset library; no external copyrighted material.
- **Scenarios:** Must be generated based on internal SOP evidence; no copying from existing vendors.

## Freshness Policy

| Topic Type | Threshold | Required Action on Fail |
| :--- | :--- | :--- |
| **Safety / Security** | 15 Days | **BLOCK**; Force lookup update |
| **Privacy / HR** | 30 Days | **WARN**; Request SME review |
| **General Admin** | 60 Days | Proceed; note last verified date |

## Citation Policy

- **All Module Content:** Must map to a `policy_id` and `last_verified_date`.
- **In-Module Display:** Show `Last Updated: [Date]` for each major policy reference.
- **Alignment Table:** Map every Learning Objective to its policy source.
