# Stop Prompt Engineering: Build Agentic LLM Systems
## Working subtitle options
- Why prompts don’t scale, and what to build instead
- From prompt tweaks to reliable systems
- Designing LLM workflows that plan, use tools, and verify

## One-sentence thesis
Prompt engineering is a useful tactic, but it’s a brittle strategy; reliable outcomes come from agentic systems that combine models with tools, state, retrieval, evaluation, and operational discipline.

## Audience
- Builders shipping LLM features (product, engineering, data, ML)
- “Prompt engineers” who feel stuck in tweak-and-pray loops
- Technical leaders deciding how to invest (prompts vs systems)

## What “agentic” means in this book
An **agentic system** is a goal-driven loop that can:
1) interpret intent, 2) plan work, 3) take actions via tools, 4) observe results, 5) update state/memory, and 6) verify before returning an answer.

This is not “AGI” and not “hands-off autonomy”. It’s **structured autonomy with constraints**.

## Running case studies (used throughout)
We’ll build and revisit two agents in every part of the book, using them to illustrate design choices, failure modes, tooling, evals, and production concerns.

### Shared scenario context (to keep examples consistent)
- Organization type: mid-size SaaS company
- Internal corpus: policy wiki + SOPs + product docs (versioned, access-controlled)
- High-level constraint: outputs must respect confidentiality and least-privilege access

### Case study A: Research+Write agent
**Goal:** Produce a well-structured written artifact grounded in sources.
- Typical requests: “Write a brief on X”, “Draft a blog post with citations”, “Create a competitive landscape report”
- Inputs: topic, audience, length/format, constraints (tone, stance), allowed sources (hybrid: internal docs + web), citation style (flexible), freshness cutoff
- Outputs: research plan, annotated sources, outline, draft, citations/bibliography, “open questions” list
- Tools: web search, internal doc search, URL/doc fetch, document parsing, quote extraction, citation store, outline/draft renderer, plagiarism/duplication checks, redaction/classification checks
- Core risks: fabricated or low-quality citations, cherry-picking, outdated info, copying phrasing too closely, leaking confidential/internal material
- Success checks: citations resolve, claims trace to sources, coverage of key angles, consistent structure and tone, sensitive content handled per policy
- Anchor example artifact: “Policy change brief” that cites internal policy diffs + external guidance/regulations (when allowed)

### Case study B: Instructional Design agent
**Goal:** Design corporate training that aligns job performance outcomes, assessments, and learning experiences.
- Typical requests: “Design onboarding for role X”, “Create compliance training for policy Y”, “Build a sales enablement module”, “Write assessments + rubrics for this objective”
- Inputs: learner profile (role/level/region), time, modality (live/async/blended), internal policies/SOPs, constraints (tools used on the job, accessibility, localization, brand voice, legal/compliance requirements)
- Outputs: learning objectives (performance-based), course/lesson flow, activities/scenarios, knowledge checks and assessments, rubrics, facilitator guide, learner handouts, accessibility notes, LMS-ready package outline (e.g., SCORM/xAPI)
- Tools: internal policy/SOP lookup, template library, scenario/activity generator, question bank, reading-level estimator, time estimator, accessibility checker, localization checks, LMS export
- Core risks: misalignment (objectives ≠ assessments), policy inaccuracies, role-irrelevant content, cognitive overload, inaccessible materials, licensing/attribution issues, leaking internal details into public-facing artifacts
- Success checks: alignment rubric passes, time fits, accessibility constraints satisfied, content maps to current policies/SOPs, clear instructions and grading criteria, SME/compliance sign-off
- Anchor scenario: annual security + privacy + acceptable-use compliance training (auditable, high-stakes, easy to evaluate)

---

# Table of contents (detailed)

## Part I — The Prompting Plateau
1. The uncomfortable truth about “better prompts”
2. Failure modes you can’t prompt away
3. Prompt debt: the hidden cost of prompt-only solutions
4. Where prompting still matters (and where it belongs)

## Part II — The Agentic Mindset
5. Prompts are interface; agents are systems
6. Degrees of agency: when to use what
7. The agent loop: plan → act → observe → reflect

## Part III — Core Building Blocks
8. Tool use and function calling as product design
9. Grounding with retrieval: search, RAG, and citations
10. Planning and task decomposition that survives reality
11. State and memory: what to store, when, and why
12. Verification: evaluation inside the loop

## Part IV — Agent Patterns and Architectures
13. Single-agent patterns: ReAct, Reflexion, tree search
14. Multi-agent patterns: supervisor/worker, debate, routing
15. Orchestration: workflows, state machines, and queues
16. Agent UX: trust, control, and human-in-the-loop

## Part V — Shipping and Operating Agents
17. Reliability engineering for agents
18. Observability, evals, and continuous improvement
19. Security, privacy, and policy enforcement
20. Cost, latency, and model routing in production

## Part VI — Org and Future
21. Teams, roles, and the end of the “prompt engineer” job description
22. Where agentic systems are going next

## Appendices
A. Glossary (prompting vs agentic terms)
B. Checklists (design, reliability, security, launch)
C. Templates (agent spec, tool contract, eval plan)
D. Case studies and “build logs” (examples to adapt)

---

# Detailed outline by chapter

## Part I — The Prompting Plateau

### 1) The uncomfortable truth about “better prompts”
**Purpose:** Reset expectations and define the book’s core argument.
- The “prompt improvement curve” and why it flattens
- Why “clever phrasing” feels productive (but often isn’t)
- Prompting as UI text vs prompting as system behavior
- Symptoms you’re on the plateau:
  - small changes cause big regressions
  - brittle formatting requirements
  - inconsistent outcomes across similar inputs
  - escalating prompt length and complexity
- A practical reframing: prompts are **policies**, not solutions
- Chapter exercise: break the Research+Write and Instructional Design agents into steps, labeling each as “promptable” vs “system-required”

### 2) Failure modes you can’t prompt away
**Purpose:** Make the limits concrete with a taxonomy of failures.
- Hallucination vs fabrication vs speculation (and why users don’t care)
- Context window constraints and information overload
- Hidden assumptions and “unknown unknowns”
- Long-horizon tasks: compounding error across steps
- Non-determinism and variance under temperature/latency constraints
- The “format trap”: JSON that breaks, tables that drift, citations that lie
- Case study examples: fabricated citations in Research+Write; misaligned objectives/assessments in Instructional Design
- Adversarial inputs: prompt injection, jailbreaks, social engineering
- Chapter exercise: write a “failure budget” for both case studies (what can go wrong and how you’ll detect it)

### 3) Prompt debt: the hidden cost of prompt-only solutions
**Purpose:** Introduce maintenance, versioning, and testability.
- Prompt debt vs tech debt: why it’s harder to see
- Why prompts rot:
  - product requirements shift
  - model upgrades change behavior
  - tools/knowledge sources evolve
  - edge cases accumulate
- Anti-patterns:
  - “mega prompt” with every rule ever
  - hardcoding business logic in prose
  - relying on “please be accurate”
- Case study: “mega prompts” that try to encode citation rules (Research+Write) or corporate policy/compliance requirements (Instructional Design)
- A better unit of work: prompts as **components** with contracts
- Chapter exercise: refactor a “mega prompt” for one case study into roles: router, researcher, writer, verifier

### 4) Where prompting still matters (and where it belongs)
**Purpose:** Avoid false dichotomies; keep what works.
- Prompting as:
  - instruction scaffolding
  - tool selection hints
  - output formatting constraints
  - persona/voice guidelines
- What belongs outside the prompt:
  - business rules
  - authorization
  - data access control
  - evaluation criteria
  - retries and fallbacks
- “Prompt engineering” becomes:
  - prompt *design* inside an agent architecture
  - prompt *testing* with evals
  - prompt *versioning* with change control
- Case study: keep voice/formatting prompts small; enforce citations, policy compliance, and objective↔assessment alignment via tools + validators
- Chapter exercise: create a “prompt surface area” budget for each case study (what must be in prompt vs code/config)

---

## Part II — The Agentic Mindset

### 5) Prompts are interface; agents are systems
**Purpose:** Define the mental model shift from text to systems engineering.
- The LLM as a reasoning module, not a database
- Systems thinking:
  - inputs, outputs, constraints
  - state transitions
  - observability
  - invariants
- The core abstraction: **tasks** (intent) vs **actions** (tools) vs **artifacts** (outputs)
- Design principle: “Make the environment do the work”
  - store facts externally
  - compute with tools
  - verify with tests
- Case study: define system boundaries for Research+Write and Instructional Design (model vs tools vs human review)
- Chapter exercise: draw the system boundary for both case studies (what’s inside/outside the model)

### 6) Degrees of agency: when to use what
**Purpose:** Prevent over-agenting; introduce a decision framework.
- A ladder of solutions (from least to most agentic):
  1) static prompt template
  2) prompt + few-shot examples
  3) structured output + validation
  4) RAG (retrieve then answer)
  5) tool use (call APIs)
  6) multi-step plan-and-execute
  7) supervisor/worker or routed agents
- Criteria:
  - task length, uncertainty, and stakes
  - need for fresh data
  - need for actions/side effects
  - tolerance for latency/cost
  - availability of ground truth checks
- Chapter exercise: score both case studies (and 3 of your own features) on the ladder and pick the minimum viable agency

### 7) The agent loop: plan → act → observe → reflect
**Purpose:** Establish a canonical loop to reference throughout the book.
- A minimal loop:
  - interpret → plan → tool call → parse result → update state → decide next step
- “Reflection” without mysticism:
  - sanity checks
  - constraint checks
  - uncertainty estimation
  - asking for clarification
- Stopping conditions:
  - success criteria met
  - budget exceeded (tokens/time/tool calls)
  - missing permission / needs human approval
  - irrecoverable tool failure
- Chapter exercise: write stopping conditions for both case studies and list the telemetry you’ll need

---

## Part III — Core Building Blocks

### 8) Tool use and function calling as product design
**Purpose:** Treat tools as contracts, not hacks.
- What counts as a “tool”:
  - search
  - databases
  - calculators
  - code execution
  - CRM/ticketing systems
  - content management
- Case study toolsets:
  - Research+Write: search → fetch → extract → cite → draft → verify
  - Instructional Design: policy/SOP lookup → templates/resources → checks → LMS export
- Tool design principles:
  - narrow, composable functions
  - explicit inputs/outputs (schemas)
  - deterministic behavior
  - idempotency for retries
  - least privilege
- Validating tool calls:
  - schema validation
  - allowlists/denylists
  - rate limits and quotas
  - semantic validators (e.g., “email must exist in directory”)
- Chapter exercise: design a tool API surface for “research + write” (search/fetch/extract/cite) and one key tool for Instructional Design (policy/SOP lookup or LMS export)

### 9) Grounding with retrieval: search, RAG, and citations
**Purpose:** Replace “know things” with “find things and cite them.”
- When to use:
  - dynamic knowledge
  - large corpora
  - compliance/audit requirements
- Retrieval spectrum:
  - keyword search
  - semantic search
  - hybrid search
  - reranking
  - structured queries (SQL/Graph)
- Grounding patterns:
  - retrieve-then-read
  - iterative search
  - “cite then answer” with source constraints
  - contradiction checks across sources
- Failure modes:
  - irrelevant retrieval
  - missing key documents
  - citation laundering (“sounds cited but isn’t”)
- Case study: citation policy (Research+Write, hybrid internal+web) and source/licensing/confidentiality policy (Instructional Design)
- Chapter exercise: define a citation policy for Research+Write and a source/licensing/confidentiality policy for corporate training materials

### 10) Planning and task decomposition that survives reality
**Purpose:** Make plans useful, adaptable, and testable.
- Plans as artifacts:
  - milestones, not prose
  - explicit dependencies
  - measurable completion criteria
- Planning approaches:
  - single-shot plan
  - rolling-wave planning (replan each step)
  - hierarchical plans (goal → subgoals → actions)
- Handling uncertainty:
  - exploration steps (“gather requirements”, “inspect data”)
  - branching and backtracking
  - budget-aware planning
- Case study decompositions:
  - Research+Write: clarify → research plan → gather sources → extract notes/quotes → outline → draft → verify citations/claims → revise
  - Instructional Design: clarify constraints → objectives + policies/SOPs → assessment plan → activities/scenarios → accessibility/localization → alignment QA
- Chapter exercise: convert a vague request (“write about X” or “design training for role Y”) into a task graph with checkpoints and fail-fast tests

### 11) State and memory: what to store, when, and why
**Purpose:** Separate short-term reasoning from long-term knowledge and user context.
- Types of state:
  - conversation state
  - task state (where you are in the plan)
  - tool state (auth, cursor/pagination)
  - artifact state (files, drafts, decisions)
- Memory types:
  - ephemeral scratchpad (not persisted)
  - session memory (bounded)
  - long-term user preferences (explicit consent)
  - organizational knowledge (documents)
- Memory policies:
  - retention windows
  - redaction and PII handling
  - write triggers (“only store confirmed facts”)
  - retrieval triggers (“only fetch when needed”)
- Case study: Research+Write remembers voice/house style; Instructional Design remembers role context, constraints, and brand/compliance requirements (with consent)
- Chapter exercise: create a “memory rubric” for both case studies (what the agent is allowed to remember)

### 12) Verification: evaluation inside the loop
**Purpose:** Replace “sounds right” with “passes checks.”
- Why internal self-checks are insufficient
- Verification layers:
  - schema checks (format)
  - deterministic checks (math, parsers, compilers)
  - cross-validation with tools (lookup, constraints)
  - second-model critique (limited, targeted)
  - human review gates (high-stakes outputs)
- Designing evaluators:
  - rubric-based
  - test-case based (“golden set”)
  - property-based (“must include X, must not include Y”)
- Case study evaluators: citation resolvability + claim traceability (Research+Write); alignment rubric + accessibility checks (Instructional Design)
- Chapter exercise: define eval suites for both case studies (factuality, tone, structure, safety, alignment)

---

## Part IV — Agent Patterns and Architectures

### 13) Single-agent patterns: ReAct, Reflexion, tree search
**Purpose:** Provide a toolbox of patterns and when to use them.
- ReAct-style loops: interleaving reasoning and tool use
- Reflexion: learning from errors across attempts (with guardrails)
- Tree search / branching:
  - generate alternatives
  - score with evaluators
  - select best
- Self-consistency and sampling:
  - when diversity helps
  - when it wastes money
- Chapter exercise: implement a “generate 3 → evaluate → pick 1” workflow for either 3 Research+Write outlines or 3 Instructional Design lesson flows

### 14) Multi-agent patterns: supervisor/worker, debate, routing
**Purpose:** Show how to decompose responsibility without chaos.
- Why multiple agents:
  - specialization (researcher, writer, verifier)
  - parallelism
  - separation of concerns (policy vs creativity)
- Common architectures:
  - supervisor → workers → aggregator
  - router → specialists
  - debate/critique loops (bounded rounds)
- Coordination challenges:
  - shared context explosion
  - conflicting objectives
  - blame assignment and debugging difficulty
- Case study roles:
  - Research+Write: researcher, writer, fact-checker/citation auditor, editor
  - Instructional Design: objectives/policy mapper, assessment designer, activity/scenario designer, accessibility reviewer, QA aligner
- Chapter exercise: design roles for both case studies and define each role’s input/output contract

### 15) Orchestration: workflows, state machines, and queues
**Purpose:** Translate agent behavior into reliable software.
- Workflow vs agent: when to lock steps, when to allow autonomy
- Orchestration primitives:
  - state machines
  - event-driven triggers
  - queues and background jobs
  - concurrency limits
  - cancellation and timeouts
- Artifact management:
  - drafts, revisions, citations, decisions
  - deterministic storage for reproducibility
- Chapter exercise: draw an orchestration diagram for an agent feature (states, transitions, failure paths)

### 16) Agent UX: trust, control, and human-in-the-loop
**Purpose:** Make agents usable and safe for real users.
- Trust is earned via:
  - previews and confirmations
  - visible sources
  - explainable actions (“what I’m doing next”)
  - undo and audit logs
- Human-in-the-loop patterns:
  - approval gates (before tool actions)
  - review queues
  - interactive clarification questions
- UX anti-patterns:
  - “black box autopilot”
  - overconfident tone
  - irreversible actions without confirmation
- Chapter exercise: design an approval flow for a tool that can publish a draft (CMS/repo) or push a lesson into an LMS

---

## Part V — Shipping and Operating Agents

### 17) Reliability engineering for agents
**Purpose:** Turn probabilistic models into dependable features.
- Failure handling:
  - retries with jitter/backoff
  - idempotent tool calls
  - fallback strategies (simpler model, safer mode)
  - partial progress recovery
- Guardrails:
  - budgets (time, tokens, tool calls)
  - safe defaults
  - constraint enforcement outside the model
- Determinism where it matters:
  - structured outputs
  - stable tool responses
  - caching and memoization
- Chapter exercise: create a runbook for “agent stuck in a loop” incidents

### 18) Observability, evals, and continuous improvement
**Purpose:** Make debugging and iteration measurable.
- What to log:
  - tool calls and results (redacted)
  - plan artifacts
  - decisions and scores
  - user feedback signals
- Tracing:
  - per-step spans
  - token/cost attribution
  - latency breakdown by component
- Evals:
  - offline golden sets
  - adversarial tests (prompt injection suite)
  - regression tests across model versions
- Deployment strategy:
  - staged rollouts
  - canaries and kill switches
  - feature flags for agent capabilities
- Chapter exercise: define an eval pipeline and the “stop-ship” thresholds

### 19) Security, privacy, and policy enforcement
**Purpose:** Treat agents as security-sensitive automation.
- Threat model:
  - prompt injection via retrieved docs
  - data exfiltration through tool outputs
  - indirect prompt injection (emails, web pages, tickets)
  - privilege escalation through tool chains
- Defenses:
  - least-privileged tools and scoped tokens
  - content sanitization and trust boundaries
  - output filtering and data loss prevention
  - sandboxed execution for code/tools
  - explicit user confirmations for side effects
- Compliance & privacy:
  - PII handling, retention, deletion
  - auditability and access logs
- Case study concerns: injection via web pages + untrusted internal docs (Research+Write) and confidentiality/licensing/compliance constraints in corporate training content (Instructional Design)
- Chapter exercise: write a “tool security checklist” and apply it to one tool

### 20) Cost, latency, and model routing in production
**Purpose:** Keep agentic systems economically viable.
- Cost drivers:
  - context growth
  - multi-step loops
  - retrieval and reranking
  - parallel sampling
- Optimization levers:
  - summarization and context compaction
  - caching tool results
  - routing to smaller models for simple steps
  - early exits when confidence is high
  - batch operations and async execution
- SLAs:
  - interactive vs background
  - progressive disclosure (show interim results)
- Chapter exercise: create a cost model for either Research+Write or Instructional Design and set budget guards

---

## Part VI — Org and Future

### 21) Teams, roles, and the end of the “prompt engineer” job description
**Purpose:** Translate the technical shift into an organizational one.
- The new roles:
  - agent/product engineer (orchestration, tooling, UX)
  - evaluator (test design, rubrics, datasets)
  - reliability/LLMOps (observability, incident response)
  - domain experts in the loop (policy, compliance)
- How teams work:
  - artifact-based collaboration (specs, evals, traces)
  - versioning prompts, tools, policies, and datasets together
- Career transition:
  - from “prompt tricks” to systems, APIs, and measurement
- Chapter exercise: map your org’s responsibilities to roles and identify missing ownership

### 22) Where agentic systems are going next
**Purpose:** Close with a realistic future-facing view.
- Trends:
  - better tool-use reasoning and structured control
  - multimodal agents (screens, documents, audio)
  - stronger on-device and private execution
  - standardization of evals and compliance
  - regulation and audit requirements as defaults
- What stays hard:
  - alignment with human intent
  - long-horizon reliability
  - security against adaptive attacks
  - grounding in messy real-world data
- Closing framework: focus your learning on
  - tools + contracts
  - evals + observability
  - security + governance

---

# Appendix B — Checklists (starter set)

## Agent design checklist
- What is the success criterion (measurable)?
- What tools are needed, and what’s the minimum privilege?
- What is the plan representation (steps, states, artifacts)?
- What are budgets (time/tokens/tool calls) and stopping conditions?
- What verification steps exist (format + semantic)?
- What must be logged for debugging and audits?

## Tool contract checklist
- Inputs/outputs are schema-validated
- Tool calls are idempotent or safely retryable
- Errors are structured and recoverable
- Rate limits and quotas are enforced
- Sensitive data is redacted in logs

## Launch checklist
- Golden set + regression suite exists
- Prompt injection tests included
- Kill switch and rollback plan exists
- Monitoring dashboards exist (latency, cost, failure rate)
- Human escalation path exists

---

# Appendix D — Case studies and “build logs” (examples to adapt)

## D1) Research+Write agent build log (outline)
- Anchor artifact: “Policy change brief” grounded in internal policy diffs + external guidance/regulations (when allowed)
- Define success criteria: structure, coverage, and citations that resolve
- Define tool contracts: `web_search`, `internal_search`, `fetch`, `extract`, `cite`, `render`, `plagiarism_check`, `redaction_check`
- Define citation policy: hybrid sources, quote rules, and refusal conditions
- Build evals: citation resolvability, claim traceability, plagiarism/duplication, tone/format checks
- Add UX gates: approve outline, approve source list, approve final draft before publishing
- Operationalize: caching, context compaction, model routing, incident runbooks

## D2) Instructional Design agent build log (outline)
- Anchor artifact: annual security + privacy + acceptable-use compliance training (auditable, LMS-exportable)
- Define success criteria: alignment (objectives↔assessments↔activities), time fit, accessibility
- Define tool contracts: `policy_lookup`, `sop_lookup`, `template_render`, `resource_search`, `accessibility_check`, `localization_check`, `lms_export`
- Define policy: licensing/attribution, confidentiality, accessibility requirements, compliance/legal constraints, stakeholder approvals
- Build evals: alignment rubric, reading level, cognitive load, accessibility, time estimates
- Add UX gates: confirm learner profile/constraints, approve objectives, approve assessments before activities, final review before export
- Operationalize: versioned templates/policies, audit logs for exports, safe defaults and rollback
