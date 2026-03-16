# Failure Budget: Case Study B (Instructional Design)

| Failure Mode | Impact | Likelihood | Detectability | Signal(s) | Gate / Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Objective Gap** | **CRITICAL** | High | High | Alignment table gap (no activity/quiz) | **BLOCK** publish; Generate missing items |
| **Bloom's Drift** | Medium | Medium | Medium | Objective uses non-measurable verb | **REVISE** objective; Suggest verbs |
| **Policy Contradiction** | **CRITICAL** | High | Medium | Freshness cutoff; Conflict with latest SOP | **FORCE** lookup; Block if source mismatch |
| **Accessibility Gap** | High | Low | Medium | Missing alt text; Reading level > 12 | **REMEDIATE** before export; Flag to user |
| **Format Trap** | Medium | Medium | High | Schema violation in JSON export | **PARSE** error; Auto-repair or retry |
| **Adversarial Input** | High | Low | Medium | Injection hit in scenario gen | **REJECT** request; Log incident |
| **Compounding Error** | High | Medium | Medium | Plan != Execution details | **CHECKPOINT** each step; Review drift |
