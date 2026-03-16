# Prompt Change Log CONVENTION

All prompt modifications must be tracked with the following schema to prevent "silent regressions" and manage prompt debt.

- **Component:** [e.g., Writer, Router, Verifier]
- **Version:** [Semantic Versioning (e.g., v1.2.3)]
- **Date:** [YYYY-MM-DD]
- **Author:** [Username or Agent ID]
- **Change:** [Brief description of the change (e.g., "Added rule for regional data residency")]
- **Why:** [The problem this change solves (e.g., "Stakeholders in EU require specific GDPR citations")]
- **Expected Impact:** [What behavior should change]
- **Risks/Regressions to Watch:** [What might break because of this edit]
- **Evals Updated?** [Yes/No] (If No, explain why)

## Change Log Rules
1. **Never** edit a prompt without a corresponding log entry.
2. **Never** edit multiple components in a single log entry.
3. **Always** update the version number based on the impact (Major/Minor/Patch).
