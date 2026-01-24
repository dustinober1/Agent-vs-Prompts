# Chapter 4 — Where prompting still matters (and where it belongs)

## Purpose
Avoid false dichotomies; keep what works.

## Reader takeaway
Prompts still matter for instruction scaffolding, tool awareness, structure, and voice—but prompts are not enforcement. Put rules, security boundaries, validation, eval criteria, and retries in the system.

## Key points
- Prompting as: instruction scaffolding, tool selection hints, output structure/formatting, voice/reading level
- What belongs outside the prompt: business rules, authorization + data access control, evaluation criteria, retries/fallbacks
- “Prompt engineering” becomes prompt design inside an architecture: small components, versioned, tested with evals
- Use a “prompt surface area budget” to keep prompts small and stable

## Draft

### Prompts aren’t going away—they’re being demoted
This book is not “anti-prompt”. It’s “anti-prompts-as-a-system”.

Prompts are still one of your best levers for:
- clarifying intent
- narrowing output shape
- setting tone and reading level
- giving the model a clean “job to do” inside a larger workflow

But prompts are not a reliable place to put:
- security boundaries (what data can be accessed, what should never be revealed)
- business rules (if/then logic, region-specific constraints, product invariants)
- hard contracts (valid JSON, required fields, schema compliance)
- quality gates (citation resolution, alignment rubrics, policy compliance)
- operational behavior (retries, fallbacks, escalations, audit trails)

When you use prompts for the first list and the system for the second list, prompting starts working again—because it’s doing the job it’s best at.

### Where prompting still matters (4 high-leverage uses)
#### 1) Instruction scaffolding (reduce ambiguity)
Prompts are great at narrowing an otherwise vague request into a constrained job:
- establish scope (“what counts as done”)
- set defaults (tone, audience, format)
- ask for missing inputs when stakes are high
- encourage intermediate artifacts (plan → evidence → draft), even if the system ultimately enforces them

Good scaffolding is specific, short, and front-loads the shape of the output.

Example (small, “inside a system”):
```text
You are writing for busy stakeholders.

Task: Draft a policy change brief using the structure in `case_studies/research_write_policy_change_brief_TEMPLATE.md`.

Constraints:
- If required metadata is missing, ask up to 5 clarifying questions before drafting.
- Use only the provided evidence snippets and source IDs. Do not add new facts.
```

This prompt doesn’t try to *enforce* evidence use. It just makes the desired behavior legible. Enforcement happens elsewhere (retrieval + citation checks).

#### 2) Tool selection hints (make the model “tool-aware”)
In an agentic system, the model needs to know:
- what tools exist
- what each tool returns
- when to use them vs when to ask a question

Prompts are a good place to *hint* at tool usage:
- “Use the doc search tool when you need policy text.”
- “If citations are required, retrieve sources before drafting.”
- “If a tool fails, stop and report the error.”

But you should treat these as guidance, not guarantees. The system still needs:
- tool allowlists (what’s even callable)
- permission checks (who can access which data)
- tool output validation (shape, freshness, confidence)

#### 3) Output structure and formatting (make the response predictable)
Prompts can do a lot for structure:
- headings and section order
- checklists and tables
- voice consistency (“plain language”, “executive tone”)

This is the best kind of prompting: it turns “a blob of text” into a usable artifact.

Where teams get burned is when they rely on prompts for *machine contracts*:
- “ONLY output valid JSON”
- “Always include every required field”
- “Never include extra commentary”

Natural language requests can improve adherence, but they can’t make it deterministic. For machine-ingested outputs, you need validators, and ideally structured outputs / function calling (so the system can reject or repair outputs that don’t parse). OpenAI’s guidance on function calling and structured outputs exists for a reason: format instructions in prompts are not enough when the downstream depends on it.

#### 4) Voice, persona, and reading level (make it usable for humans)
Tone and clarity are a real product requirement. Prompts are the right place to encode:
- “Write for frontline managers.”
- “Use plain language; define acronyms.”
- “Keep sections to 3–5 bullets.”
- “Be calm and procedural; avoid speculation.”

The failure mode here is not “wrong JSON”. It’s trust. If the voice changes every run, users feel the system is unstable even when the substance is correct.

### Where prompts don’t belong (5 common misplacements)
#### 1) Business rules and product invariants
If you’re encoding rules like these in a prompt, you’re buying prompt debt:
- “If region is EU, include clause X.”
- “If the user is on plan Y, do not offer feature Z.”
- “Always recommend our internal workflow unless exception A applies.”

Rules like this change frequently, need owners, and require test coverage. Put them in:
- code
- config
- a policy/rules engine
- a lookup table owned by the domain team

Prompts can *describe* the rules (“follow the policy engine’s decision”), but shouldn’t be the source of truth.

#### 2) Authorization and data access control
This is the sharpest line: prompts are not a security boundary.

If a system retrieves or has access to sensitive data, you can’t rely on “don’t reveal secrets” phrasing to keep you safe—especially under prompt injection. The UK National Cyber Security Centre (NCSC) puts it plainly: current LLMs do not enforce a security boundary between instructions and data inside a prompt.

Put access control in the system:
- authenticate users and tools
- filter retrieval by permission (least privilege)
- never pass secrets you wouldn’t show the user
- isolate tool outputs as untrusted inputs (scan/strip/validate)

#### 3) Evaluation criteria (“be correct”, “be compliant”, “be aligned”)
Prompts can request self-checks, but:
- self-checks are not independent verification
- “be compliant” has no teeth without a rubric
- “aligned objectives” is meaningless unless you check objective↔activity↔assessment coverage

Move “done-ness” into explicit gates:
- citation resolution and claim-to-source coverage thresholds
- alignment rubrics that can fail
- policy mapping checks (“every required topic has a policy reference”)
- human review gates for high-stakes outputs

#### 4) Retries, fallbacks, and incident handling
If a tool times out or returns malformed data, the system needs a response policy:
- retry (how many times?)
- fallback tool/model
- ask the user for missing info
- escalate to a human reviewer
- fail safely with a partial result + next steps

You can *tell* the model “if you fail, retry”, but the system should own the loop: retries, budgets, timeouts, and logging.

#### 5) “Security promises” and “never do X” rules
“Never reveal confidential info” is a necessary instruction—but it’s not sufficient.

Treat prompts like signage, not locks:
- signage helps good-faith behavior
- locks (policy enforcement) stop failures and adversarial behavior

This is why the Open Worldwide Application Security Project (OWASP) includes prompt injection and insecure output handling as top risks for LLM applications: attackers (and accidents) will route around text-only constraints.

### The prompt surface area budget (a practical design tool)
Define your **prompt surface area** as: *the amount of product behavior that lives only in prompt text*.

The larger it is, the more you’ll suffer:
- brittle regressions from small edits
- unclear ownership (“who approved this behavior?”)
- difficulty testing (“what does this prompt guarantee?”)
- higher security risk (“is a prompt instruction acting like a control?”)

A useful way to shrink prompt surface area is to ask, for each requirement:
- **Is it high-stakes?** (security, compliance, money) → enforce outside prompt
- **Does it change often?** (policy, pricing, org rules) → config/policy engine, not prompt prose
- **Is it machine-consumed?** (JSON, tickets, diffs) → schema + validators, not “ONLY output JSON”
- **Is it about readability?** (tone, structure, clarity) → prompt is usually the right layer

Quick cheat sheet:

| Requirement | In prompt? | In system? | Why |
|---|---:|---:|---|
| Tone/voice/reading level | ✅ | ◻️ | Best handled as instruction |
| Section structure/template | ✅ | ✅ | Prompt guides; validator enforces |
| Allowed sources | ✅ (declare) | ✅ (enforce) | Permissions + retrieval controls |
| “Include citations” | ✅ (request) | ✅ (enforce) | Retrieval + resolution checks |
| “Never leak secrets” | ✅ (request) | ✅ (enforce) | Prompts aren’t security boundaries |
| Output must parse/schema | ◻️ | ✅ | Needs validation + repair loop |

### “Small prompts” that scale (because the system does the heavy lifting)
Here are examples of prompts that stay small because they assume the system provides data and enforces checks.

#### Example A: Evidence-first drafting
```text
Input: evidence snippets with source IDs + a brief outline.

Write the draft section in plain language.
- Use only the evidence provided.
- For every key claim, include the source ID in parentheses.
- If evidence is insufficient, write “NEEDS SOURCE” and list what to retrieve.
```

#### Example B: Claim extraction for citation auditing
```text
From the draft, extract 10–20 key claims that require sources.
Return a bulleted list of {claim} → {where it appears in the draft}.
Do not add new claims.
```

The system can then verify: do those claims map to retrieved sources? Do citations resolve?

#### Example C: Objective↔assessment alignment mapping
```text
Given learning objectives and assessment items, produce an alignment table.
Mark any objective with no assessment evidence as GAP.
```

The system can enforce the rubric: “No GAPs allowed before publishing.”

### Prompt engineering, redefined
After Chapters 1–3, “prompt engineering” can’t mean “make the prompt bigger”.

In an agentic approach, it becomes:
- **Prompt design:** short, legible instructions that define a component’s job
- **Prompt testing:** eval sets that catch regressions and measure adherence
- **Prompt versioning:** change control with owners, diffs, and rollbacks

Prompts become one layer in a stack—not the whole stack.

With the boundaries of prompting now clear, we can shift from thinking about prompts to thinking about systems. In Part II, we'll define what it means to build agentic systems—and why the mindset change matters more than any particular framework.

## Case study thread
### Research+Write (Policy change brief)
Keep prompts focused on structure, tone, and audience. Enforce citations, traceability, and confidentiality via tools + validators.

Prompt surface area budget (recommended):
- In prompt:
  - Brief structure (use `case_studies/research_write_policy_change_brief_TEMPLATE.md`)
  - Audience + tone (executive, plain language)
  - Evidence-use instruction (“use only provided sources; mark NEEDS SOURCE”)
- Outside prompt (system):
  - Retrieval over internal docs (permission-filtered)
  - Citation resolution (links/doc IDs must resolve)
  - Claim-to-source coverage checks (block publish on gaps)
  - Redaction/confidentiality checks

Hard stops / gates:
- “Missing source” is a hard stop, not a warning in prose.
- Tie back to Chapter 2: fabricated citations and format drift are validator problems, not prompt problems.

### Instructional Design (Annual compliance training)
Keep prompts focused on learner-facing clarity and tone. Enforce policy mapping, alignment, accessibility checks, and approvals outside the prompt.

Prompt surface area budget (recommended):
- In prompt:
  - Module structure (use `case_studies/instructional_design_compliance_training_MODULE_TEMPLATE.md`)
  - Learner profile + reading level targets
  - Scenario tone (realistic, role-based, non-alarmist)
- Outside prompt (system):
  - Policy/SOP lookup and mapping (must cite current internal policies)
  - Alignment rubric checks (no objective without practice + assessment)
  - Accessibility checklist enforcement
  - Human approvals + audit trail

Hard stops / gates:
- No objective without practice + assessment evidence.
- Accessibility checklist must pass before publishing/export.
- Tie back to Chapter 3: alignment rules belong in a rubric you can version.

## Artifacts to produce
- A “prompt surface area budget” for each agent (what must be in prompt vs tools/config/policy).
- A one-page “prompt vs system” checklist you can apply to any new requirement.
- Two or three “small prompts” per agent that assume retrieval + validation (design patterns, not mega prompts).
- A list of non-prompt controls (validators, gates, approvals) for both case studies.

## Chapter exercise
Create a “prompt surface area” budget for each case study (what must be in prompt vs code/config).

Suggested format (copy/paste for each case study):

| Requirement | Prompt text | Tool/data layer | Validator/gate | Owner |
|---|---|---|---|---|
| | | | | |

Rules:
- Anything **high-stakes** must have a **validator or gate**.
- Anything that **changes often** should be **config/policy**, not prose.
- Prompts should be short enough that a teammate can read them and understand the component’s job in 60 seconds.

## Notes / references
- OpenAI prompt engineering best practices: https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
- OpenAI function calling + structured outputs: https://help.openai.com/en/articles/8555517-function-calling-updates
- OpenAI structured outputs announcement: https://openai.com/index/introducing-structured-outputs-in-the-api/
- OWASP Top 10 for LLM applications: https://owasp.org/www-project-top-10-for-large-language-model-applications/
- UK NCSC on prompt injection (“not SQL injection”): https://www.ncsc.gov.uk/pdfs/blog-post/prompt-injection-is-not-sql-injection.pdf
- Indirect prompt injection in integrated apps (Greshake et al., 2023): https://arxiv.org/abs/2302.12173
- NIST AI RMF Generative AI Profile: https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial-intelligence-profile
