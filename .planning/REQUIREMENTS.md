# Requirements: Agent-vs-Prompts

## 1. Book Structure
- **Content**: 22 chapters divided into 6 parts.
- **Format**: Markdown.
- **Case Studies**: Two running case studies (Research+Write, Instructional Design) must be integrated into chapters.
- **Appendices**: Glossary, Checklists, Templates, Build Logs.

## 2. Case Study A: Research+Write Agent
### Functional Requirements
- MUST perform web and internal search.
- MUST extract and cite sources.
- MUST generate a research plan and draft.
- MUST verify citations and check for plagiarism.
### Non-Functional Requirements
- MUST respect confidentiality and least-privilege access.
- MUST handle sensitive content per policy.

## 3. Case Study B: Instructional Design Agent
### Functional Requirements
- MUST align objectives, assessments, and activities.
- MUST lookup internal policies/SOPs.
- MUST generate knowledge checks and rubrics.
- MUST export in LMS-ready format (SCORM/xAPI outline).
### Non-Functional Requirements
- MUST satisfy accessibility and localization constraints.
- MUST ensure cognitive load is managed.

## 4. Operational Requirements
- **Observability**: Log tool calls, results, and agent decisions.
- **Reliability**: Implement retries, fallbacks, and idempotent tool calls.
- **Security**: Defense against prompt injection and data exfiltration.
- **Cost/Latency**: Optimize token usage and model routing.
