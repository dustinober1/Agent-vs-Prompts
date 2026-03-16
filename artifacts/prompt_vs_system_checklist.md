# Prompt vs. System Decision Checklist

Apply this checklist to every new requirement to determine where it belongs in your agentic architecture.

- [ ] **Is it high-stakes?** (Security, compliance, money) → **SYSTEM** (Enforce with Validator/Gate)
- [ ] **Does it change often?** (Policy, pricing, org rules) → **SYSTEM** (Move to Config/Policy Engine)
- [ ] **Is it machine-consumed?** (JSON, tickets, diffs) → **SYSTEM** (Use Schema + Validators)
- [ ] **Is it about readability?** (Tone, structure, clarity) → **PROMPT** (Use Instructions/Scaffolding)
- [ ] **Is it a security boundary?** (Data access, secrets) → **SYSTEM** (Use Authorization/Filtering)

## Allocation Rules
- **SIGNAGE (Prompt):** Use for tone, voice, reading level, and output templates.
- **LOCKS (System):** Use for business rules, authorization, data access, and hard contracts.
