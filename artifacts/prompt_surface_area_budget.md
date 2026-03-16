# Prompt Surface Area Budget

The **Prompt Surface Area** is the amount of product behavior that lives only in prompt text. Use this budget to keep prompts small, stable, and maintainable.

## Decision Checklist: Prompt vs. System

Apply this checklist to every new requirement:

- **Is it high-stakes?** (Security, compliance, money) → **SYSTEM** (Enforce with Validator/Gate)
- **Does it change often?** (Policy, pricing, org rules) → **SYSTEM** (Move to Config/Policy Engine)
- **Is it machine-consumed?** (JSON, tickets, diffs) → **SYSTEM** (Use Schema + Validators)
- **Is it about readability?** (Tone, structure, clarity) → **PROMPT** (Use Instructions/Scaffolding)
- **Is it a security boundary?** (Data access, secrets) → **SYSTEM** (Use Authorization/Filtering)

## Surface Area Allocation

| Requirement Type | In Prompt? | In System? | Mechanism |
| :--- | :---: | :---: | :--- |
| **Tone & Voice** | ✅ | ◻️ | Instruction Scaffolding |
| **Output Template** | ✅ | ✅ | Prompt Guides; Validator Enforces |
| **Business Rules** | ◻️ | ✅ | Config / Policy Engine |
| **Data Access** | ◻️ | ✅ | Auth / Retrieval Filters |
| **Format Contract** | ◻️ | ✅ | Schema / Structured Output |
| **Quality Gates** | ◻️ | ✅ | Rubrics / Evals / Human-in-the-Loop |

## Rules of Thumb
1. **Signage vs. Locks:** Prompts are signs (guidance); Systems are locks (enforcement).
2. **The 60-Second Rule:** A teammate should be able to read and understand a prompt component's job in 60 seconds or less.
3. **Small Prompts Scale:** If a prompt is longer than 2 screens, it has too much "surface area." Decompose it.
