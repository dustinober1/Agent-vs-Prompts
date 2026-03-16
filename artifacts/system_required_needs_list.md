# System-Required Needs List

A prompt expresses intent, but only a system can enforce it. Here are the needs that text alone cannot guarantee:

- **Truth:** The model can't cite a document it didn't retrieve. (Requires **Retrieval**)
- **Freshness:** Prompts don't update when policies or docs change. (Requires **State/Freshness**)
- **Authorization:** "Don't reveal X" is not an access control system. (Requires **Authorization**)
- **Contracts:** "ONLY output JSON" is not schema validation. (Requires **Validation**)
- **Alignment:** "Make it aligned" is not an alignment rubric. (Requires **Verification**)
- **Accountability:** "Be auditable" is not an audit trail. (Requires **Logging/Observability**)
- **Stability:** "Follow all rules" is not a regression test. (Requires **Evals/Continuous Improvement**)
