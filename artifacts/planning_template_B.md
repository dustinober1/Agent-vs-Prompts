# Planning Template: Instructional Design (Case Study B)

## Goal
Draft annual compliance training modules with alignment and accessibility gates.

## Task Graph (Hierarchical)

```yaml
high_level_plan:
  id: "training_module_B"
  phases:
    - name: "Intake & Policy Mapping"
      sub_steps:
        - name: "Clarify constraints"
          produces: "module_requirements"
        - name: "Map topics to policies"
          produces: "policy_map"
          checkpoint: "topic_coverage_gt_90pct"

    - name: "Instructional Design"
      sub_steps:
        - name: "Draft objectives"
          produces: "objectives_artifact"
          checkpoint: "objectives_measurable"
        - name: "Design flow"
          produces: "module_outline"

    - name: "Content Generation"
      sub_steps:
        - name: "Generate practice scenarios"
          produces: "scenarios_artifact"
        - name: "Generate assessments"
          produces: "items_bank"
          checkpoint: "alignment_check_pass"

    - name: "Final QA & Export"
      sub_steps:
        - name: "Run QA suite"
          produces: "qa_report"
          checkpoint: "access_AA_pass"
        - name: "Capture approvals"
          produces: "approval_log"
        - name: "Prepare export"
          action: "export_prep"
          produces: "export_package"
```

## Checkpoint Details

| Checkpoint | What is checked | Failure Response |
| :--- | :--- | :--- |
| **Topic Coverage** | All required topics have policy references | **BLOCK**; Force policy lookup |
| **Obj Measurable** | Uses action verbs; measurable criteria | **REVISE** objectives |
| **Alignment Check** | `Obj <-> Practice <-> Assessment` mapping | **REGENERATE** missing items |
| **Access AA** | WCAG 2.1 AA checklist compliance | **BLOCK**; remediate content |
| **Approval** | SME, Legal, and Security sign-off | **BLOCK**; Escalate to human |
