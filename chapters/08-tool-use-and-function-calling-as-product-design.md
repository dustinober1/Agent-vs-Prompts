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

### The week you shipped tools (and everything got worse)

You've seen this story before.

The prompt-only version of your policy brief generator kept hallucinating citations. Chapter 2 warned you this would happen; Chapter 4 told you validation belongs outside the prompt. So your team did the right thing: you added tools. A search tool. A fetch tool. A citation verifier.

The demo worked beautifully. The agent searched internal docs, pulled quotes, drafted the brief, and every citation resolved.

Then production happened.

The search tool returned no results for a perfectly reasonable query—and the agent drafted the brief anyway, inventing sources. The fetch tool timed out on a large document—and the agent reported "source unavailable" for a document that was actually there. The citation verifier failed silently on a malformed doc ID—and the agent marked the citation as verified.

You patched the prompt: "If a tool returns no results, do not proceed." That helped for a week. Then someone changed the search tool's error format, and the agent stopped recognizing failures.

The problem was never the model. The problem was the tools.

### Tools are the hardest part of agent design

Here's something most tutorials don't tell you: tool design is where agentic systems actually succeed or fail.

The model is the easy part. It's a commodity. You can swap providers, upgrade versions, tune prompts. But your tools? Those are *your* system. They encode your data model, your permissions, your business logic, your error conditions. They're the bridge between the model's reasoning and your actual infrastructure.

And when that bridge is poorly designed, no amount of prompt engineering will save you.

This chapter is a field guide to designing tools that make your agent loop reliable—tools that fail clearly, compose cleanly, and give the model enough information to recover from problems.

### What Chapter 7 set up

Chapter 7 defined the agent loop: plan → act → observe → reflect. This chapter expands the "act" step—the moment when the model calls a tool to do something in the world. That step is where the model's reasoning meets reality.

Tools in that loop serve three purposes:

**Grounding.** Retrieval tools—search, fetch, extract—give the model facts it doesn't have. They're how you solve the hallucination problem from Chapter 1. The model can't cite a document it didn't retrieve.

**Computation.** Compute tools—validators, diff engines, calculators—do work the model can't do reliably. Date math. Schema checking. Policy comparisons. These are deterministic operations where correctness matters and the model would only introduce variance.

**Effect.** Effect tools—ticket creation, email sending, record updates—change the world. These are the highest-stakes tools, the ones that need approval gates and audit trails.

The quality of your agent loop depends on the quality of these tools. And "quality" here means something specific: clear contracts, structured errors, and predictable behavior.

### The tool mistake everyone makes

Here's the pattern that trips up almost every team building their first agentic system:

You need the agent to search for policy documents. So you expose your existing search API as a tool. The search API was built for humans using a web interface—it returns HTML snippets, ranks by popularity, and handles errors by returning an empty result with a 200 status code.

The model calls the tool. It gets back... something. An empty list when there were actually permission issues. A list of results that includes stale documents the user shouldn't see. HTML that the model has to parse into something useful.

Every ambiguity becomes a failure mode.

Compare that to a tool designed for agents:
- Returns structured JSON with explicit fields
- Separates "no results found" from "permission denied" from "timeout"
- Filters by permission before returning results
- Includes freshness metadata the model can use

The difference isn't sophistication—it's clarity. The agent-ready tool makes the model's job easier by being explicit about what happened.

### The three kinds of tools (and why it matters)

Before you design individual tools, classify them. The classification determines your authority model.

**Retrieval tools** are read-only. They search, fetch, extract, and cite. They're your lowest-risk tools because they don't change the world—but they can still leak data if you're not careful about permissions. Examples:
- `search`: find documents matching a query
- `fetch`: retrieve a specific document by ID
- `extract_quotes`: pull verbatim excerpts from content
- `cite_store`: save a citation for later verification

**Compute tools** are deterministic and side-effect-free. They parse, validate, diff, and calculate. These are your highest-confidence tools because their outputs are verifiable. If you can replace model reasoning with a compute tool, you should. Examples:
- `schema_validate`: check if JSON matches a schema
- `diff_policy`: compare two policy versions
- `calculate_deadline`: date math
- `alignment_check`: verify objectives have assessments

**Effect tools** change the world. They create, update, send, and delete. These are your highest-stakes tools, the ones where mistakes have consequences. They need:
- Explicit approval gates (human or policy-based)
- Clear rollback or undo paths
- Audit logging for every action

The principle from Chapter 6 applies: separate read tools from write tools. Know exactly where your authority boundary is, and make that boundary a system constraint, not a prompt suggestion.

### Six principles that keep tools reliable

These are operational requirements, not optional best practices. Violate them, and you'll spend your time debugging mysterious agent failures instead of improving your product.

#### Narrow: one tool, one job

The most common tool design mistake is conflation. You build `search_and_summarize` because it seems efficient—one tool call instead of two. But now you can't tell whether failures come from search or summarization. You can't reuse the search in other contexts. You can't validate the search results before summarizing.

Good tools do one thing. `search` returns source IDs. The model decides whether to fetch. `fetch` returns content. The model decides whether to extract quotes. Each step is observable, testable, and composable.

If you find yourself naming a tool with "and" in it, split it.

#### Composable: outputs chain into inputs

The output of one tool should be usable as the input to another without the model doing gymnastics.

A composable tool chain looks like this:

```
search("policy on PII handling") 
    → [doc_id_1, doc_id_2]

fetch(doc_id_1) 
    → { content: "...", last_updated: "2025-11-15" }

extract_quotes(content, claim="retention period") 
    → [{ quote: "PII must be deleted within 90 days...", section: "3.2" }]

cite_store(doc_id_1, quote, claim_id) 
    → { citation_id: "cite_001" }
```

Notice how each output is structured to be a valid input for the next step. If `search` returned a blob of merged text instead of IDs, the chain would break.

When you design a new tool, ask: what will call this, and what will this call? Design the interfaces to snap together cleanly.

#### Schema-first: every tool is a contract

Before you write a line of tool code, write the schema. What are the required inputs? What are the optional inputs with defaults? What does success look like? What does failure look like?

This matters because:
- The model needs to know what to pass and what to expect
- Your orchestration code needs to validate inputs before calling
- Your observe step needs to parse outputs reliably
- Your debugging needs to answer "did the tool receive valid input?"

OpenAI introduced structured outputs because "ONLY output JSON" wasn't reliable. Your tools need the same discipline. A tool without a schema is a tool waiting to fail in production.

#### Deterministic: same input, same output

Wherever possible, tools should be deterministic. `fetch(doc_id)` should return the same document every time. `calculate_deadline(start, duration)` should return the same date. `schema_validate(json, schema)` should pass or fail consistently.

Determinism is what makes tools trustworthy. When a tool is deterministic, you can test it, cache its results, and reason about its behavior.

But some tools have inherent variance:
- Search rankings change as documents are added
- Document content changes between versions
- Rate limits cause different results under load

When variance exists, make it explicit. Return a `freshness` field. Accept an `as_of_date` parameter. Include a confidence or stability indicator. Don't pretend variance doesn't exist—the model needs to know.

#### Idempotent: safe to retry

Effect tools need special care. If the agent calls `create_ticket` twice with the same input, you probably don't want two tickets.

Idempotent tools are safe to retry:
- `update_record(id, { status: "resolved" })` sets the status; calling it twice changes nothing
- `create_or_update_draft(draft_id, content)` creates or replaces; idempotent by design

Non-idempotent tools are dangerous:
- `send_email(to, body)` sends two emails
- `create_ticket(fields)` creates duplicates

For non-idempotent effect tools:
- Require explicit human confirmation
- Accept client-generated deduplication keys
- Log and warn on repeated calls with same parameters

#### Least privilege: only what's needed

A tool should only access data and perform actions necessary for its defined job.

For retrieval tools, this means permission filtering. `internal_search` should never return documents the current user can't access—filter *before* returning results, not after. Don't trust the model to respect access boundaries.

For effect tools, this means scoped capabilities. The ticket tool can create and update, but not delete. The email tool can draft, but sending requires a separate approval-gated tool.

Least privilege isn't just security—though it is that. It's also reducing the blast radius of model errors. When the model makes a mistake (and it will), you want the damage contained.

### Structured errors: how agents recover

Most tool failures in production aren't "tool is down." They're edge cases:
- No results found (but the query was valid)
- Permission denied (for some documents, not all)
- Partial results (some sources fetched, others timed out)
- Rate limited (try again later)

If your tool returns `{ "error": "Something went wrong" }`, the model will guess about what happened. If your tool returns structured errors, the model can actually decide what to do.

Here's what a good error looks like:

```json
{
  "error_type": "PERMISSION_DENIED",
  "message": "User lacks access to confidential policy corpus.",
  "recoverable": false,
  "suggestion": "Narrow query to non-confidential sources or request approval."
}
```

The error type tells the model *what* happened. The message explains *why*. The recoverable flag tells the model whether to retry. The suggestion tells the model what to try instead.

Define a standard set of error types across all your tools:

| Error Type | Meaning | Typical Response |
|---|---|---|
| `INVALID_INPUT` | Request didn't pass schema validation | Fix the input, retry |
| `NOT_FOUND` | The requested resource doesn't exist | Try a different ID or report missing |
| `PERMISSION_DENIED` | User can't access this resource | Escalate or narrow scope |
| `PARTIAL_RESULT` | Some data returned, some missing | Proceed with caution, note gaps |
| `TIMEOUT` | Tool didn't respond in time | Retry once with same parameters |
| `RATE_LIMITED` | Too many requests | Wait, then retry or switch strategy |
| `INTERNAL_ERROR` | Something unexpected failed | Stop and escalate to human |

When your observe step encounters one of these errors, the reflect step can make a real decision instead of guessing.

### Validation happens in layers

You can't validate just once. Validation happens at three points in the tool flow:

**Before the tool call** — validate inputs. Does the request have all required fields? Are the types correct? Is the query length within bounds? Catch problems before you hit your infrastructure.

**After the tool call** — validate outputs. Did the tool return the expected shape? Are required fields present? Did an error occur that needs handling? Don't pass garbage to the model.

**Before the final output** — validate the artifact. Do citations resolve? Does content pass redaction checks? Does the alignment table have gaps? This is where semantic validation happens.

For each layer:

**Schema validation** checks structural correctness. Use JSON Schema or equivalent. This is table stakes.

**Allow/deny lists** enforce policy. Which corpora can be searched? Which document types can be exported? Which terms trigger redaction? These are gates, not suggestions.

**Quotas and budgets** protect resources. Max results per search (prevent context overflow). Max calls per tool per request (prevent spam loops). These are part of the contract.

**Semantic validation** checks meaning, not just structure. Does the cited passage actually support the claim? Is the policy version current? Does the training module cover all required topics? These often require their own tools—a citation verifier, a policy freshness checker.

### Tool contracts: the artifact that makes everything else easier

For each tool your agent can call, write a contract. This isn't documentation—it's a system artifact that makes everything else easier.

A tool contract specifies:
- **Inputs**: required fields, optional fields, types, constraints
- **Outputs**: success shape, error shape, partial-result shape
- **Behavior**: deterministic? idempotent? latency expectations?
- **Permissions**: what scopes are required? what data is denied?
- **Budgets**: max calls per request, max results

When you have contracts:
- You can generate model-facing tool descriptions automatically
- You can validate inputs before calling
- You can parse outputs reliably in the observe step
- You can debug incidents by checking whether contracts were honored

Keep contracts in source control alongside your code. Version them like APIs—breaking changes are major versions. Review them during design and incident review.

### The tool inventory: what you're actually running

Chapter 3 introduced prompt components. This chapter introduces the **tool inventory**: a versioned, owned list of every tool your agent can call.

Why maintain an inventory?
- New tools require review before deployment (authority, permissions, error handling)
- Deprecated tools need migration paths
- Tool changes require versioning with clear breaking-change policies
- Incidents become debuggable ("which version of search was deployed?")

A minimal inventory entry:
- Name and version
- Type (retrieval / compute / effect)
- Status (active / deprecated / experimental)
- Link to contract spec
- Owner and review date

When your 2 AM incident response starts with "which tools were available and what did they return?", you'll be grateful for the inventory.

## Case study thread

### Research+Write (Policy change brief)

Let's apply these principles to the policy brief agent.

**The tool problem we're solving**: The prompt-only version from Chapter 1 produced citations that didn't resolve. Chapter 4 said validation belongs outside the prompt. Chapter 7 defined the loop. Now we need the tools.

#### The tool inventory

| Tool | Type | Purpose |
|---|---|---|
| `internal_search` | retrieval | Find internal policy/SOP docs matching a query |
| `web_search` | retrieval | Find external sources (when allowed) |
| `fetch` | retrieval | Retrieve a specific document by ID |
| `extract_quotes` | retrieval | Pull verbatim excerpts from content |
| `cite_store` | retrieval | Store a source reference for verification |
| `cite_verify` | compute | Check that a citation resolves and supports the claim |
| `redaction_check` | compute | Scan output for confidential content |
| `diff_policy` | compute | Compare two policy versions |

#### Design decisions

**Why separate `internal_search` and `web_search`?** Because they have different permission models. Internal search is always allowed; web search requires explicit `external_allowed = true` in context. Making them separate tools means the allowlist is a system constraint, not a prompt instruction.

**Why `cite_store` and `cite_verify` as separate tools?** Storage is instant and always succeeds. Verification might fail (document moved, quote doesn't match, permission denied). Separating them means the agent can store citations as it works, then verify them all before publishing.

**Why is `redaction_check` a compute tool, not part of the publish flow?** Because the agent needs to see the result before deciding what to do. If redaction check is hidden in the publish step, the agent can't revise and retry.

#### Guardrails baked into tools

- `internal_search` filters by permission before returning results
- `web_search` fails if `external_allowed` is false in context
- `cite_verify` returns structured failure when docs don't resolve
- `redaction_check` returns exact matches and severity levels

These aren't prompt instructions. They're tool behavior. The model can't accidentally bypass them.

#### Example contract: internal_search

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
      description: "Natural language query."
      constraints: "1-500 characters"
  optional:
    - name: "corpus"
      type: "string[]"
      default: ["policies", "sops"]
    - name: "as_of_date"
      type: "date"
      default: "today"
    - name: "max_results"
      type: "integer"
      default: 10

outputs:
  success:
    shape: "{ results: [{ doc_id, title, snippet, score, last_updated }] }"
  error:
    shape: "{ error_type, message, recoverable, suggestion }"
    types: ["PERMISSION_DENIED", "NO_RESULTS", "TIMEOUT"]
  partial:
    shape: "{ results: [...], incomplete: true, reason: '...' }"

behavior:
  deterministic: false # rankings can change
  latency_p50_ms: 200
  latency_p99_ms: 1500

permissions:
  required_scopes: ["internal-docs:read"]
  denied_data: ["confidential:executive"]

budgets:
  max_calls_per_request: 3
  max_results: 20
```

With this contract, the agent knows exactly what to send, what to expect back, and how to handle each error type.

### Instructional Design (Annual compliance training)

**The tool problem we're solving**: The prompt-only version from Chapter 1 produced objectives that weren't assessed. Chapter 4 said alignment checks belong outside the prompt. Now we need tools that enforce alignment.

#### The tool inventory

| Tool | Type | Purpose |
|---|---|---|
| `policy_lookup` | retrieval | Fetch current policy sections by topic |
| `sop_lookup` | retrieval | Fetch SOPs for role-specific procedures |
| `template_library` | retrieval | Retrieve module templates |
| `alignment_check` | compute | Validate objective↔practice↔assessment mapping |
| `accessibility_check` | compute | Run accessibility checklist |
| `reading_level_check` | compute | Score content against target grade level |
| `lms_export` | effect | Package module for LMS import |

#### Design decisions

**Why is `alignment_check` a tool, not a prompt instruction?** Because "make sure objectives are assessed" is exactly the kind of instruction that fails in prompt form (Chapter 1). The alignment check tool takes structured inputs—objectives, practices, assessments—and returns a structured gap report. The model can't hallucinate past a failing check.

**Why is `lms_export` separated from the rest of the flow?** Because it's an effect tool. It packages content and prepares it for export. That's a write action that needs an approval gate. Keeping it separate makes the gate enforceable.

**Why does `policy_lookup` return `last_verified` dates?** Because freshness matters. Compliance training that references a superseded policy is a liability. The tool's contract includes freshness metadata so the agent can detect stale sources.

#### Guardrails baked into tools

- `policy_lookup` returns `last_verified` date; agent can check against freshness cutoff
- `alignment_check` returns structured gaps; any gap is a blocking issue
- `lms_export` requires approval scope; fails without it

#### Example contract: alignment_check

```yaml
tool:
  name: "alignment_check"
  purpose: "Validate that every learning objective has practice and assessment."
  owner: "learning-design-team"
  version: "2.0.1"

inputs:
  required:
    - name: "objectives"
      type: "array"
      description: "[{ objective_id, objective_text }]"
    - name: "practices"
      type: "array"
      description: "[{ practice_id, practice_text, objective_ids }]"
    - name: "assessments"
      type: "array"
      description: "[{ assessment_id, assessment_text, objective_ids }]"

outputs:
  success:
    shape: |
      {
        alignment_table: [{ objective_id, has_practice, has_assessment }],
        gaps: [{ objective_id, missing: ['practice' | 'assessment'] }],
        pass: boolean
      }
  error:
    shape: "{ error_type, message, recoverable, suggestion }"
    types: ["INVALID_INPUT"]

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

When the agent calls `alignment_check` and gets `{ pass: false, gaps: [...] }`, the reflect step knows exactly what to fix before trying again.

## Artifacts to produce
- A tool inventory for each case study (name, type, version, status)
- A tool contract spec for each major tool (inputs/outputs/errors/behavior/permissions)
- An error-handling matrix: error type → model response → escalation path
- A validation layer checklist: what's validated before/after tool calls

## Chapter exercise
Design a tool API surface for both case studies.

### Part 1: Research+Write tools
Pick two tools from the inventory and write full contracts:
1. `fetch` — retrieve a document by ID
2. `cite_verify` — check that a citation resolves

For each, answer:
- What inputs are required vs optional?
- What does a successful response look like?
- What errors can occur?
- How should the agent respond to each error type?

### Part 2: Instructional Design tools
Pick two tools and write full contracts:
1. `policy_lookup` — fetch current policy sections
2. `lms_export` — package for LMS (an effect tool)

For each, answer:
- What approval gates apply?
- What makes this tool idempotent (or not)?
- How do you handle partial success?

### Bonus: Design an error
Pick one common failure from your own system. Design the structured error response that would let an agent recover automatically.

## Notes / references
- OpenAI Function Calling: https://platform.openai.com/docs/guides/function-calling
- OpenAI Structured Outputs: https://openai.com/index/introducing-structured-outputs-in-the-api/
- Anthropic Tool Use: https://docs.anthropic.com/en/docs/build-with-claude/tool-use
- JSON Schema specification: https://json-schema.org/
- ReAct (reasoning + acting for tool use): https://arxiv.org/abs/2210.03629
- Toolformer (models learning to use tools): https://arxiv.org/abs/2302.04761
- OWASP LLM Top 10 (LLM07 Insecure Plugin Design): https://owasp.org/www-project-top-10-for-large-language-model-applications/

