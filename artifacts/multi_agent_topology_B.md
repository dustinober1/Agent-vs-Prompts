# Multi-Agent Topology: Instructional Design (Case Study B)

## Architecture: Supervisor/Worker

### 1. Supervisor: Curriculum Coordinator
- **Role:** Orchestrate the pipeline and enforce alignment gates.
- **Responsibilities:**
  - Decompose the request into topics.
  - Assign sub-tasks to Workers.
  - Collect worker outputs into a single module.
  - **GATES:** Block if Alignment QA fails; Block if Accessibility fail.

### 2. Worker: Objectives Mapper
- **Input:** Policy documents + Job Role.
- **Output:** Measurable Learning Objectives (Bloom's Taxonomy).
- **Constraint:** Must map every objective to a specific policy section.

### 3. Worker: Assessment Designer
- **Input:** Learning Objectives.
- **Output:** Multiple-choice quiz items + Rationales.
- **Constraint:** Every objective must have at least one assessment.

### 4. Worker: Scenario Designer
- **Input:** Learning Objectives + Policy Map.
- **Output:** Realistic, job-relevant scenarios with feedback.
- **Constraint:** Scenarios must prepare learners for the assessment.

### 5. Worker: Accessibility Reviewer
- **Input:** Draft Module (Objectives, Scenarios, Assessments).
- **Output:** WCAG 2.1 AA Report + Remediation Suggestions.
- **Constraint:** Flag cognitive load and reading level (> Grade 12).

### 6. Worker: Alignment QA
- **Input:** Full Module Artifacts.
- **Output:** Alignment Matrix (Obj <-> Practice <-> Assessment).
- **Constraint:** Flag any objective without a corresponding practice or assessment.

## Communication Flow
```text
User -> [Supervisor]
          |
          +-> [Objectives Mapper] -> [Policy Map + Obj List]
          |
          +-> [Assessment Designer] + [Scenario Designer] (Parallel)
          |
          +-> [Alignment QA] -> [Alignment Matrix]
          |
          +-> [Accessibility Reviewer] -> [QA Report]
          |
        [Supervisor] -> Final Package -> User
```
