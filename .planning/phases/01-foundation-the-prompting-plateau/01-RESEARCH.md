# Phase 1 Research: Foundation and The Prompting Plateau

## Research Objective
Identify the necessary components, definitions, and artifact structures required to successfully plan and implement Phase 1 (Chapters 1-4).

## 1. Chapter Status and Refinement Needs
The core content for Chapters 1-4 is already drafted in a high-quality state. Planning should focus on **refining** these drafts to ensure they seamlessly integrate the artifacts and case study baselines.

| Chapter | Title | Key Theme | Required Refinement |
| :--- | :--- | :--- | :--- |
| **01** | The Uncomfortable Truth About "Better Prompts" | The Prompting Plateau | Formalize the "Plateau Symptom Checklist" and "System-Required Needs List". |
| **02** | Failure Modes You Can't Prompt Away | Taxonomy of Failure | Map the "Seven Failure Modes" to specific "Failure Budgets" for Case Study A & B. |
| **03** | Prompt Debt: The Hidden Cost of Prompt-Only Solutions | Maintenance & Versioning | Create the "Prompt-Component Map" and "Change Log Convention". |
| **04** | Where Prompting Still Matters | Strategic Prompt Usage | Define the "Prompt Surface Area Budget" and "Prompt vs. System" checklist. |

## 2. Case Study Baseline Definitions
To effectively demonstrate the "transition to agentic," we must establish "intentionally naive" baselines.

### Case Study A: Research+Write (Policy Change Brief)
- **Baseline Prompt:** A single "mega-prompt" asking for research, citations, and a draft in one go without retrieval tools.
- **Diagnostic Failures:** Fabricated citations, missing source-of-truth diffs, and inconsistent formatting.
- **Prompt Debt:** Hardcoded rules for citation styles and internal policy acronyms.

### Case Study B: Instructional Design (Compliance Training)
- **Baseline Prompt:** A single prompt asking for objectives, content, and assessments aligned to a policy without lookup or validation tools.
- **Diagnostic Failures:** Objective↔Assessment misalignment, outdated policy references, and accessibility omissions.
- **Prompt Debt:** Business logic for regional compliance requirements embedded in prose.

## 3. The Seven Failure Modes (Ch 2)
The planning phase must utilize this taxonomy for all initial testing:
1. **Hallucination/Fabrication:** Ungrounded claims or invented citations.
2. **Context Window Limits:** Dropping constraints in long-form generation.
3. **Hidden Assumptions:** Filling gaps with "hallucinated" defaults instead of asking.
4. **Long-Horizon Drift:** Compounding errors across multi-step drafting.
5. **Non-Determinism:** Quality variance that breaks downstream workflows.
6. **The Format Trap:** Brittle JSON or broken Markdown tables.
7. **Adversarial Inputs:** Susceptibility to prompt injection in source material.

## 4. Required Artifacts (The "How to Plan Well" Answer)
To plan this phase well, the following artifact structures must be established in a new `/artifacts/` directory:

### Foundational Artifacts (Standalone)
- [ ] **Plateau Symptom Checklist:** A diagnostic tool for builders to identify when they've hit the limits of prompting.
- [ ] **Failure Budget (A/B):** A table defining acceptable vs. unacceptable failure rates for specific agent tasks.
- [ ] **Prompt-Component Map:** A template for breaking mega-prompts into versioned, testable modules.
- [ ] **Prompt Surface Area Budget:** A constraint-setting tool that limits how much "system logic" is allowed in text.

### Implementation Patterns
- **Small Prompts:** Move away from "please be accurate" toward "Task: Extraction; Input: Sources; Output: Claims."
- **Verification Gates:** Define the "Hard Stops" (e.g., "Citation must resolve before Draft phase begins").

## 5. Project Skill Alignment
No custom project skills were found in `.agents/skills/`. Planning will proceed using the standard Senior Software Engineer persona and the "unified flow" established in the project state.

---
*Research completed: 2026-03-15*
*Status: Ready for Phase 1 Strategy*
