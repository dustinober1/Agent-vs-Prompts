# Chapter 8 — Tool use and function calling as product design

## Purpose
Treat tools as contracts, not hacks.

## Reader takeaway
Well-designed tools make agent behavior reliable by constraining inputs/outputs and enabling verification outside the model.

## Key points
- Tool types: search, databases, calculators, code execution, ticketing, CMS
- Design principles: narrow, composable, schema-first, deterministic, idempotent, least privilege
- Validation: schema validation, allow/deny lists, quotas, semantic validators

## Case study thread
### Research+Write (Policy change brief)
- Tool contracts: `web_search`, `internal_search`, `fetch`, `extract_quotes`, `cite_store`, `redaction_check`
- Guardrails: no external calls unless allowed; redact confidential strings

### Instructional Design (Annual compliance training)
- Tool contracts: `policy_lookup`, `sop_lookup`, `template_render`, `accessibility_check`, `lms_export`
- Guardrails: only use current policy versions; log approval metadata

## Artifacts to produce
- A tool inventory and contract spec for each case study (inputs/outputs/errors)

## Chapter exercise
Design a tool API surface for “research + write” (search/fetch/extract/cite) and one key tool for Instructional Design (policy/SOP lookup or LMS export).

## Notes / references
- TODO: decide how tool errors are represented and handled across the system

