# Case Study B: Instructional Design (Annual Compliance Training) — Baseline "Naive" Mega-Prompt

This prompt asks for a complete module without external lookup, alignment checks, or structured evaluation rubrics.

```text
Create an annual compliance training module using the structure in `case_studies/instructional_design_compliance_training_MODULE_TEMPLATE.md`.

Context:
You are an expert instructional designer specializing in compliance training for large organizations.

Constraints:
- Topics to cover: Security, Privacy, Acceptable Use, Incident Reporting.
- Ensure Learning Objectives are aligned with the Outline and Final Quiz.
- Use measurable Bloom's Taxonomy verbs (e.g., "describe," "identify," "apply").
- Ensure content matches our current internal policies.
- Tone: Professional, educational, engaging.
- Include accessibility considerations in the Markdown.

Output:
A single Markdown document.
```

## Why This Prompt Fails at Scale:
1. **Misalignment:** There is no mechanism to verify that an Assessment item actually tests an Objective.
2. **Policy Drift:** The model's "internal training data" for "privacy" may not match the specific legal requirements of the company's 2026 policy.
3. **Format Drift:** A single prompt for a "complete module" leads to shallow content or missed sections.
