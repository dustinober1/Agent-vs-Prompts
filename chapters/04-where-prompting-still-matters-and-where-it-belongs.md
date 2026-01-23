# Chapter 4 — Where prompting still matters (and where it belongs)

## Purpose
Avoid false dichotomies; keep what works.

## Reader takeaway
Prompts still matter for instruction scaffolding and formatting, but rules, security, and evaluation belong outside the prompt.

## Key points
- Prompting as scaffolding, tool hints, formatting constraints, voice guidelines
- Keep business rules, authorization, data access controls, eval criteria, retries outside the prompt
- Prompt engineering becomes prompt design + testing + versioning

## Draft

### The handoff from Chapters 1–3
Chapters 1–3 argued that prompt tweaks plateau, prompt-only systems accumulate debt, and failure modes are mostly systemic. This chapter is the “keep what works” answer: prompts are still valuable, but they must be scoped to interface behavior and paired with enforcement mechanisms.

### This isn’t a rejection of prompts
Prompting still matters. It’s just not the whole system.

Use prompts for what they’re good at:
- Framing intent (“summarize for a VP” vs “write for legal review”)
- Shaping structure (outlines, headings, sections)
- Setting voice and tone (formal, instructional, neutral)
- Guiding tool use (“retrieve sources before drafting”)
- Asking for clarifying questions when inputs are incomplete

But don’t use prompts as a substitute for enforcement.

### A simple split: interface vs enforcement
You can keep most systems sane by drawing one line:

- **Interface (belongs in prompts):**
  - Voice, style, and formatting
  - Task framing and sequence hints
  - Required sections and headings
  - “Ask before acting” guidance

- **Enforcement (belongs outside prompts):**
  - Authorization and access control
  - Data source restrictions (what’s allowed and when)
  - Schema validation and structural contracts
  - Alignment and policy checks
  - Retries, fallbacks, and escalation rules

If it must *always* be true, it cannot live only in a prompt.

### The “prompt surface area” budget
Think of the prompt as a budget you can easily exceed:
- Every new rule increases entropy and variance.
- Every exception is a new failure mode.
- Every “please also” pushes you toward a mega prompt.

So set a budget by asking three questions:
- **What must be in the prompt?** (voice, format, local reasoning steps)
- **What must be in code/config?** (rules, auth, checks, retries)
- **What must be in tools?** (retrieval, parsing, calculation, exports)

If a requirement is high-stakes, put it outside the prompt by default.

A simple budget table you can reuse:

| Requirement | Prompt? | Tool? | Code/config? | Why this location? |
| --- | --- | --- | --- | --- |
| Output format | ✅ | | | Structure/voice is UI |
| Citation validity | | ✅ | ✅ | Must resolve and be enforced |
| Confidentiality | | | ✅ | Access control + redaction |
| Alignment rubric | | ✅ | ✅ | Checked against policy |

### Small prompts inside a bigger system
Good prompts tend to be short and specific. Examples:

**Formatting prompt**
```text
Draft the brief in the policy change template.
Use H2 headings for each section.
Keep paragraphs under 5 sentences.
```

**Clarification prompt**
```text
Before drafting, list any missing inputs that block you.
If none, say "Ready to draft."
```

**Tone prompt**
```text
Write in a neutral, executive style suitable for a VP audience.
Avoid hype and first-person language.
```

These are stable because they describe *interface behavior*, not system rules.

### A quick refactor example (from Chapter 3)
You don’t need to kill the prompt; you need to shrink it.

**From mega prompt:**
- “Include citations, ensure they resolve, check for confidentiality, and validate JSON.”

**To components:**
- Prompt: “Draft the brief in the template with citations placeholders.”
- Tool: `citation_store` + validator (resolve links, map claims).
- Tool: `redaction_check` + policy gate.
- Code/config: schema validator with retry/repair rules.

This preserves prompt value (structure, tone) while moving enforcement into testable components.

### Prompt engineering becomes product design
Once you move rules out of the prompt, “prompt engineering” shifts:
- **Design**: define clear, stable prompt components.
- **Testing**: add evals for each component (format, tone, structure).
- **Versioning**: treat prompts like UI copy with change control.

It’s less about clever phrasing and more about system architecture.

## Case study thread
### Research+Write (Policy change brief)
- Keep prompts focused on structure, tone, and clarity.
- Enforce citations via a citation store and a claim-to-source validator.
- Enforce redaction/confidentiality via a policy checker.
- Make “missing source” a hard stop, not a warning in prose.
- Tie back to Chapter 2 failure modes: fabricated citations and format drift are validator problems, not prompt problems.

### Instructional Design (Annual compliance training)
- Keep prompts focused on learner-facing clarity and tone.
- Enforce policy mapping via a policy lookup tool and required-topic list.
- Enforce alignment via an objective↔activity↔assessment rubric.
- Enforce accessibility via a checklist validator and remediation loop.
- Tie back to Chapter 3 prompt debt: alignment rules belong in a rubric you can version.

## Artifacts to produce
- A “prompt surface area budget” for each agent (what must be in prompt vs in tools/config/policy)
- A short list of prompt components (name, purpose, stable constraints)
- A list of non-prompt controls (validators, gates, approvals)

## Chapter exercise
Create a “prompt surface area” budget for each case study (what must be in prompt vs code/config).

## Notes / references
- Consider adding a prompt catalog appendix if you have enough stable components.
