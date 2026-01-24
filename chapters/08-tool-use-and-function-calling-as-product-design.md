# Chapter 8 — Tool use and function calling as product design

## Purpose
Treat tools as contracts, not hacks.

## Reader takeaway
Well-designed tools make agent behavior reliable by constraining inputs/outputs and enabling verification outside the model. A tool inventory with clear contracts is more valuable than a clever prompt.

## Key points
- Tool types: search, databases, calculators, code execution, ticketing, CMS
- Design principles: narrow, composable, schema-first, deterministic, idempotent, least privilege
- Validation: schema validation, allow/deny lists, quotas, semantic validators
- Error handling: structured errors, retry guidance, graceful degradation

## Draft

### From Chapter 7: the "act" step is where tools live
Chapter 7 established the agent loop: interpret → plan → act → observe → update → reflect → decide. The "act" step is tool use: searching, fetching, parsing, calculating, writing.

In that loop, tools serve three functions:
1. **Ground the model in facts** (retrieval tools): search, fetch, extract.
2. **Do work the model can't do reliably** (compute tools): date math, schema validation, diffs, formatting.
3. **Take actions in the world** (effect tools): create tickets, send notifications, update records.

This chapter is about designing those tools well—so the agent loop stays predictable.

### The tool design mistake you've already made
If you've built an agentic system, you've probably experienced this:
- A tool works in the demo.
- In production, edge cases appear: missing fields, timeouts, permission errors, partial results.
- The model doesn't know how to recover: it hallucinates around errors or retries infinitely.
- Someone patches the prompt to explain the error, creating more debt.

The root cause is usually not the model. It's the tool.

A well-designed tool:
- Has a narrow, well-defined job.
- Returns structured output (including structured errors).
- Is deterministic or clearly declares its variance.
- Carries enough information for the model to decide what to do next.

A poorly designed tool:
- Does too many things (conflated concerns).
- Returns unstructured text or ambiguous status.
- Fails silently or returns partial results without signaling.
- Forces the prompt to interpret tool output instead of acting on it.

The rest of this chapter is a field guide to tool design that keeps your agent loop reliable.

### The tool taxonomy: retrieval, compute, effect

Before designing individual tools, classify them. The classification drives your authority model (from Chapter 6).

#### Retrieval tools (read-only, grounding)
- **search:** find documents, passages, or entities matching a query
- **fetch:** retrieve a specific document or record by ID
- **extract:** pull structured data from unstructured content (quotes, entities, sections)
- **cite:** store a source reference for later verification

Retrieval tools are your lowest-risk tools. They can still leak data if permissions aren't enforced, but they don't change the world.

#### Compute tools (deterministic, side-effect-free)
- **parse:** validate and transform structured data (JSON, dates, numbers)
- **diff:** compare two versions of a document or policy
- **calculate:** arithmetic, date math, eligibility rules
- **check:** run a validator (schema, rubric, accessibility checker)

Compute tools are your highest-confidence tools. Their outputs are verifiable. If you can replace model reasoning with a compute tool, do it.

#### Effect tools (write, side effects)
- **create:** tickets, records, drafts
- **update:** modify existing records or documents
- **send:** notifications, emails, exports
- **delete:** remove records (rare; almost always approval-gated)

Effect tools are your highest-stakes tools. They require:
- explicit approval gates (human or policy-based)
- clear rollback or undo paths
- audit logging

The Chapter 6 principle applies: **separate read tools from write tools**. Know where your authority boundary is.

### Six design principles for reliable tools

These principles are not aspirational. They are operational: if you violate them, you will debug mysterious agent failures.

#### 1) Narrow: one tool, one job
A tool should do one thing well.

**Bad:** `search_and_summarize(query)` – conflates retrieval and reasoning.

**Good:**
- `search(query)` → returns source IDs and snippets
- Then the model summarizes (its job)

When a tool does too much, you can't tell where failures originate.

#### 2) Composable: tools should chain cleanly
The output of one tool should be usable as the input to another.

**Example chain:**
```
search("policy on PII handling") → [doc_id_1, doc_id_2]
fetch(doc_id_1) → { content: "...", last_updated: "..." }
extract_quotes(content, query) → [{ quote: "...", section: "..." }]
cite(doc_id_1, quote, claim_id) → { citation_id: "..." }
```

If `search` returned a blob of text instead of IDs, `fetch` couldn't work. Composability requires predictable shapes.

#### 3) Schema-first: every tool has a contract
Define the input schema and output schema before you build the tool.

**Input schema:**
- Required fields (with types and constraints)
- Optional fields (with defaults)
- Validation rules

**Output schema:**
- Success shape (typed fields)
- Error shape (structured, not prose)
- Partial-result shape (when applicable)

**Why this matters:**
- The model can be told what to pass and what to expect.
- Validators can check inputs before calling.
- Observers (in the loop) can parse outputs reliably.

OpenAI's function calling and structured outputs exist precisely because "ONLY output JSON" isn't reliable. Tools need the same discipline.

#### 4) Deterministic (or declare variance)
Wherever possible, tools should return the same output for the same input.

Deterministic tools:
- `fetch(doc_id)` returns the same document
- `calculate_deadline(start_date, duration)` returns the same date
- `schema_validate(json, schema)` passes or fails consistently

Variance sources (flag these explicitly):
- search ranking changes over time
- document versions change (require "as-of" parameters)
- rate limits and latency cause partial results

When variance exists, the tool should signal it (e.g., `{ results: [...], freshness: "live", confidence: "may-change" }`).

#### 5) Idempotent (for effect tools)
Calling an effect tool twice with the same input should not double the effect.

**Idempotent (safe to retry):**
- `update_ticket(ticket_id, { status: "resolved" })` – same status, no change
- `create_or_update_draft(draft_id, content)` – replaces if exists

**Not idempotent (dangerous to retry):**
- `send_email(to, body)` – sends two emails
- `create_ticket(fields)` – creates two tickets

For non-idempotent tools:
- require explicit confirmation (human gate)
- use deduplication keys (client-generated IDs)
- log and warn on duplicate calls

#### 6) Least privilege: only what's needed
A tool should only access data and systems it needs for its job.

**For retrieval tools:**
- scope to allowed corpora (permission-filtered)
- never return docs the user/context shouldn't access

**For effect tools:**
- scope to allowed actions (create but not delete; update status but not reassign)
- require escalation for sensitive operations

Least privilege is not just security—it reduces the blast radius of model errors and prompt injections.

### Tool contracts: the artifact that makes agents debuggable

For each tool, write a contract spec. This is the artifact that makes agent behavior auditable.

**Contract template:**
```yaml
tool:
  name: ""
  purpose: ""
  owner: ""
  version: ""

inputs:
  required:
    - name: ""
      type: ""
      description: ""
      constraints: ""
  optional:
    - name: ""
      type: ""
      default: ""
      description: ""

outputs:
  success:
    - name: ""
      type: ""
      description: ""
  error:
    shape: "{ error_type, message, recoverable, suggestion }"
    error_types:
      - name: ""
        meaning: ""
        recovery: ""
  partial:
    - name: ""
      type: ""
      description: ""

behavior:
  deterministic: true | false
  idempotent: true | false (for effect tools)
  latency_p50_ms: 0
  latency_p99_ms: 0

permissions:
  required_scopes: []
  denied_data: []

budgets:
  max_calls_per_request: 0
  max_results: 0
```

This contract is not documentation—it's a system artifact. Use it to:
- generate model-facing tool descriptions
- validate inputs before calling
- parse outputs in the observe step
- audit tool behavior during incidents

### Structured errors: the key to agent recovery

Most tool failures in production are not "tool down." They're edge cases:
- permission denied
- no results found
- partial match (low confidence)
- invalid input
- timeout

If your tool returns `{ "error": "Something went wrong" }`, the model will guess. If your tool returns structured errors, the model can act.

**Error schema (example):**
```json
{
  "error_type": "PERMISSION_DENIED",
  "message": "User lacks access to confidential policy docs.",
  "recoverable": false,
  "suggestion": "Request approval or narrow query to non-confidential sources."
}
```

**Error types to define (minimum viable):**
| Error type | When to use | Model response |
|---|---|---|
| INVALID_INPUT | Schema validation failed | Fix input and retry |
| NOT_FOUND | No results / doc doesn't exist | Broaden query or report missing |
| PERMISSION_DENIED | Scope violation | Escalate or narrow scope |
| PARTIAL_RESULT | Some results, not all | Proceed with caution + note gaps |
| TIMEOUT | Tool didn't respond in time | Retry once or switch strategy |
| RATE_LIMITED | Quota exceeded | Wait or switch strategy |
| INTERNAL_ERROR | Unexpected failure | Stop and escalate |

When the observe step parses a structured error, the reflect step can decide:
- retry (with modifications)?
- ask user?
- proceed with partial data?
- stop and escalate?

Without this structure, recovery is guesswork.

### Validation layers: schema, allow/deny, quotas, semantic

Validation happens at three points:
1. **Before the tool call:** validate inputs
2. **After the tool call:** validate outputs
3. **Before the final output:** validate the artifact

#### Schema validation (structural correctness)
- inputs match required fields and types
- outputs parse into the expected shape
- missing fields are flagged, not ignored

Use JSON Schema or equivalent. This is table stakes.

#### Allow/deny lists (policy enforcement)
- allowed sources / corpora (least privilege)
- allowed actions / write scopes
- denied content patterns (redaction triggers)

These are not suggestions—they are gates. Tool calls that violate lists should fail, not proceed.

#### Quotas and budgets (resource protection)
- max results per search (prevent context overflow)
- max calls per tool per request (prevent spam loops)
- max total tool calls per request (budget from Chapter 7)

Quotas are part of the contract. Violating them is an error, not an exception.

#### Semantic validation (content correctness)
- citation resolution: does the cited doc ID actually exist and contain the quoted text?
- redaction checks: does the output contain strings that shouldn't be exposed?
- freshness checks: is the policy current, or was it superseded?

Semantic validation is harder than schema validation. It often requires a tool itself (e.g., `cite_verify`, `redaction_check`).

### The tool inventory: your most valuable system artifact

Just as Chapter 3 introduced prompt components, this chapter introduces the **tool inventory**: a versioned, owned list of every tool the agent can call.

**Why this matters:**
- New tools require review (authority, permissions, error handling).
- Deprecated tools need migration paths.
- Tool changes require versioning (breaking changes are major versions).
- Incidents are debuggable ("which version of `search` ran?").

**Tool inventory format:**
```yaml
inventory:
  last_updated: ""
  owner: ""

tools:
  - name: ""
    version: ""
    type: "retrieval | compute | effect"
    status: "active | deprecated | experimental"
    contract_path: ""
    dependencies: []
    allowed_contexts: []
```

Keep this inventory in source control. Review it during design and incident review.

## Case study thread

### Research+Write (Policy change brief)

#### Tool contracts
The agent needs these tools:

| Tool | Type | Purpose | Key constraints |
|---|---|---|---|
| `web_search` | retrieval | Find external sources (if allowed) | allowed-domains list; external-only flag |
| `internal_search` | retrieval | Find internal policy/SOP docs | permission-filtered; scope to assigned corpora |
| `fetch` | retrieval | Retrieve full doc by ID | last_updated returned; version parameter |
| `extract_quotes` | retrieval | Pull verbatim excerpts from content | returns quote + section anchor |
| `cite_store` | retrieval | Store citation for verification | returns citation_id; links claim to source |
| `cite_verify` | compute | Check that citation resolves | returns pass/fail + quote match score |
| `redaction_check` | compute | Scan for confidential strings | returns matches + severity |
| `diff_policy` | compute | Compare two policy versions | returns structured diff |

#### Guardrails
- `web_search` only callable if `external_allowed = true` in context
- `cite_verify` must pass before publishing
- `redaction_check` must pass; failures are hard stops

#### Example tool contract: `internal_search`
```yaml
tool:
  name: "internal_search"
  purpose: "Search internal policy and SOP corpus for relevant documents."
  owner: "knowledge-platform-team"
  version: "1.2.0"

inputs:
  required:
    - name: "query"
      type: "string"
      description: "Natural language query for policy content."
      constraints: "1-500 characters"
  optional:
    - name: "corpus"
      type: "string[]"
      default: ["policies", "sops"]
      description: "Corpora to search."
    - name: "as_of_date"
      type: "date"
      default: "today"
      description: "Return docs valid as of this date."
    - name: "max_results"
      type: "integer"
      default: 10
      description: "Max documents to return."

outputs:
  success:
    - name: "results"
      type: "array"
      description: "List of { doc_id, title, snippet, score, last_updated }."
  error:
    shape: "{ error_type, message, recoverable, suggestion }"
    error_types:
      - name: "PERMISSION_DENIED"
        meaning: "User lacks access to one or more corpora."
        recovery: "Narrow corpus or escalate."
      - name: "NO_RESULTS"
        meaning: "Query returned no matches."
        recovery: "Broaden query or report."
  partial:
    - name: "results"
      type: "array"
      description: "Partial results with { incomplete: true } flag."

behavior:
  deterministic: false
  idempotent: true
  latency_p50_ms: 200
  latency_p99_ms: 1500

permissions:
  required_scopes: ["internal-docs:read"]
  denied_data: ["confidential:executive"]

budgets:
  max_calls_per_request: 3
  max_results: 20
```

### Instructional Design (Annual compliance training)

#### Tool contracts
The agent needs these tools:

| Tool | Type | Purpose | Key constraints |
|---|---|---|---|
| `policy_lookup` | retrieval | Fetch current policy sections | must return version + last_verified |
| `sop_lookup` | retrieval | Fetch SOPs for role-specific procedures | scoped by role/region |
| `template_library` | retrieval | Retrieve module templates | version-controlled |
| `alignment_check` | compute | Validate objective↔practice↔assessment mapping | returns gaps as structured list |
| `accessibility_check` | compute | Run accessibility checklist | returns pass/fail per criterion |
| `reading_level_check` | compute | Score content against target grade level | returns score + suggestions |
| `lms_export` | effect | Package module for LMS import | requires approval; returns export_id |

#### Guardrails
- `policy_lookup` must include `last_verified` date within freshness window
- `alignment_check` failures block publishing (no objective without assessment)
- `lms_export` requires approval gate

#### Example tool contract: `alignment_check`
```yaml
tool:
  name: "alignment_check"
  purpose: "Validate that every learning objective has corresponding practice and assessment."
  owner: "learning-design-team"
  version: "2.0.1"

inputs:
  required:
    - name: "objectives"
      type: "array"
      description: "List of { objective_id, objective_text }."
      constraints: "1-50 objectives"
    - name: "practices"
      type: "array"
      description: "List of { practice_id, practice_text, objective_ids }."
    - name: "assessments"
      type: "array"
      description: "List of { assessment_id, assessment_text, objective_ids }."

outputs:
  success:
    - name: "alignment_table"
      type: "array"
      description: "{ objective_id, has_practice: bool, has_assessment: bool }."
    - name: "gaps"
      type: "array"
      description: "{ objective_id, missing: ['practice' | 'assessment'] }."
    - name: "pass"
      type: "boolean"
      description: "True if no gaps."
  error:
    shape: "{ error_type, message, recoverable, suggestion }"
    error_types:
      - name: "INVALID_INPUT"
        meaning: "Objectives, practices, or assessments malformed."
        recovery: "Fix input structure."

behavior:
  deterministic: true
  idempotent: true
  latency_p50_ms: 50
  latency_p99_ms: 200

permissions:
  required_scopes: ["learning-content:validate"]

budgets:
  max_calls_per_request: 2
```

## Artifacts to produce
- A tool inventory for each case study (name, type, version, status)
- A tool contract spec for each tool (inputs/outputs/errors/behavior/permissions)
- An error-handling matrix: error type → model response → human escalation path
- A validation layer checklist: what's validated before/after tool calls

## Chapter exercise
Design a tool API surface for both case studies.

### Part 1: Research+Write tools
Define contracts for:
1. `internal_search` – search internal docs
2. `fetch` – retrieve full document
3. `extract_quotes` – pull verbatim excerpts
4. `cite_store` + `cite_verify` – store and verify citations

For each, specify:
- required/optional inputs
- success/error output shapes
- determinism and idempotency
- budget constraints

### Part 2: Instructional Design tools
Define contracts for:
1. `policy_lookup` – fetch current policy
2. `alignment_check` – validate objective coverage
3. `lms_export` – package for LMS (effect tool)

For each:
- What inputs are required vs optional?
- What errors can occur and how should the agent respond?
- What approval gates apply?

### Suggested format
Copy/paste per tool:
```yaml
tool:
  name: ""
  purpose: ""
  type: "retrieval | compute | effect"

inputs:
  required: []
  optional: []

outputs:
  success: []
  error:
    types: []
  partial: []

behavior:
  deterministic: true | false
  idempotent: true | false

permissions:
  required_scopes: []

budgets:
  max_calls_per_request: 0
```

## Notes / references
- OpenAI Function Calling: https://platform.openai.com/docs/guides/function-calling
- OpenAI Structured Outputs: https://openai.com/index/introducing-structured-outputs-in-the-api/
- Anthropic Tool Use: https://docs.anthropic.com/en/docs/build-with-claude/tool-use
- JSON Schema specification: https://json-schema.org/
- ReAct (reasoning + acting for tool use): https://arxiv.org/abs/2210.03629
- Toolformer (models learning to use tools): https://arxiv.org/abs/2302.04761
- OWASP LLM Top 10 (tool-related risks: LLM07 Insecure Plugin Design): https://owasp.org/www-project-top-10-for-large-language-model-applications/

