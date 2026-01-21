# Chapter 19 — Security, privacy, and policy enforcement

## Purpose
Treat agents as security-sensitive automation.

## Reader takeaway
Agents expand the attack surface through tools and retrieval; security comes from trust boundaries, least privilege, and explicit confirmation for side effects.

## Key points
- Threats: injection via retrieved docs, exfiltration via tools, indirect injection, privilege escalation through tool chains
- Defenses: least-privileged tools, trust boundaries, sanitization, output filtering/DLP, sandboxing, confirmations
- Compliance: PII handling, retention/deletion, auditability and access logs

## Case study thread
### Research+Write (Policy change brief)
- Injection: untrusted web pages and untrusted internal docs
- Controls: source trust tiers, redaction checks, allowlisted domains, refusal modes

### Instructional Design (Annual compliance training)
- Confidentiality: internal policy details must not leak into public-facing artifacts
- Controls: licensed assets only, approval gates with Security/Legal, audit logs for exports

## Artifacts to produce
- Tool security checklist + threat model for each agent

## Chapter exercise
Write a “tool security checklist” and apply it to one tool.

## Notes / references
- TODO: define “safe mode” behavior when policy is ambiguous or tools fail

