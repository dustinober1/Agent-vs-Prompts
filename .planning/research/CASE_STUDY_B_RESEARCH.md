# Research: Case Study B - Instructional Design Agent

## Goal
Design corporate training that aligns job performance outcomes, assessments, and learning experiences.

## Key Findings from Outline
- **Typical requests**: "Design onboarding for role X", "Create compliance training for policy Y", "Build a sales enablement module", "Write assessments + rubrics for this objective".
- **Inputs**: learner profile (role/level/region), time, modality (live/async/blended), internal policies/SOPs, constraints (tools used on the job, accessibility, localization, brand voice, legal/compliance requirements).
- **Outputs**: learning objectives (performance-based), course/lesson flow, activities/scenarios, knowledge checks and assessments, rubrics, facilitator guide, learner handouts, accessibility notes, LMS-ready package outline (e.g., SCORM/xAPI).
- **Tools**: internal policy/SOP lookup, template library, scenario/activity generator, question bank, reading-level estimator, time estimator, accessibility checker, localization checks, LMS export.
- **Core risks**: misalignment (objectives ≠ assessments), policy inaccuracies, role-irrelevant content, cognitive overload, inaccessible materials, licensing/attribution issues, leaking internal details into public-facing artifacts.
- **Success checks**: alignment rubric passes, time fits, accessibility constraints satisfied, content maps to current policies/SOPs, clear instructions and grading criteria, SME/compliance sign-off.
- **Anchor scenario**: annual security + privacy + acceptable-use compliance training (auditable, high-stakes, easy to evaluate).

## Research Directions
1. **Alignment Rubric**: define metrics for mapping objectives to assessments and activities.
2. **Tool APIs**: define interfaces for `policy_lookup`, `sop_lookup`, `accessibility_check`, `lms_export`.
3. **Eval Suites**: alignment QA, time estimates, accessibility constraints.
