# Failure Budget: Case Study A (Research+Write)

| Failure Mode | Impact | Likelihood | Detectability | Signal(s) | Gate / Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Hallucinated Citation** | **CRITICAL** | High | High | Citation resolution fails; no excerpt match | **BLOCK** publish; Force retrieval of source |
| **Citation Drift** | High | Medium | Medium | Excerpt doesn't support claim | Flag for human review; Request stronger evidence |
| **Context Loss** | Medium | Medium | Low | Missing audience/region constraints | **FAIL** check; Re-run with explicit constraint echo |
| **Format Break** | Medium | Low | High | JSON/Markdown parse error | **RETRY** with repair prompt or fallback |
| **Confidentiality Leak** | **CRITICAL** | Low | Medium | Redaction hit; Source/Dest mismatch | **BLOCK** release; Alert security; Redact output |
| **Stale Policy** | High | Medium | Medium | Fetch date > freshness window | **FORCE** refresh of policy store |
| **Ambiguous Intent** | Medium | High | Medium | Assumptions list > 3 items | **ASK** user for clarification before proceeding |
