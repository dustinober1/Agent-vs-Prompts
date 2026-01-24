# Chapter 11 — State and memory: what to store, when, and why

## Purpose
Separate short-term reasoning from long-term knowledge and user context.

## Reader takeaway
State and memory are product and policy decisions: what to store, what to forget, and what requires explicit consent.

## Key points
- State: conversation, task, tool, artifact
- Memory: ephemeral, session, long-term preferences (consent), organizational knowledge
- Policies: retention, redaction/PII, write triggers, retrieval triggers

## Draft

### The agent that remembered too much

The training module came out perfectly. Accurate content, aligned assessments, polished scenarios. The compliance team approved it for deployment.

Three months later, a different team requested a new module on the same topic. The agent, trying to be helpful, included an example scenario based on a real incident it had "remembered" from the first project—an incident that involved specific employees, specific dates, and specific failures.

That incident had been shared as context during development. It was never supposed to appear in training materials. But the agent had stored it as "useful background" and retrieved it when the topic came up again.

The training got pulled. The investigation took weeks. The agent lost access to production.

This is the memory problem: an agent that forgets nothing is an agent that leaks everything.

### Why memory is a policy decision, not a feature

It's tempting to think of memory as purely technical: "the agent should remember things so it can do better work." And that's true, as far as it goes. An agent that forgets its own plan mid-task is useless.

But the harder questions are policy:
- **What** is the agent allowed to remember?
- **For how long?**
- **Whose consent is required?**
- **Who can see what the agent remembers?**
- **What triggers deletion?**

These aren't engineering questions. They're product, legal, and compliance questions. The system you design shapes what's possible. The policy you set shapes what's allowed.

This chapter separates two concepts that often get conflated:
- **State**: what the agent knows during a single task
- **Memory**: what the agent retains across tasks

State is technical. Memory is political.

### State: what the agent knows right now

State is the working memory of a single task. It's what the agent needs to complete the current request.

#### Conversation state

The messages so far. What the user asked. What the agent replied. What clarifications were exchanged.

- **Scope**: Current conversation only
- **Lifetime**: Until conversation ends
- **Risk**: Context window limits; loss of early messages if conversation is long

#### Task state

The current step, plan, and progress. What's been done, what's pending, what's blocked.

From Chapter 10's plan-as-artifact:
```yaml
state:
  goal: "Write policy change brief"
  current_step: 4
  steps_complete: [1, 2, 3]
  steps_pending: [5, 6, 7]
  blocked_on: null
```

- **Scope**: Current task
- **Lifetime**: Until task completes (or times out)
- **Risk**: Losing state on interruption; inconsistent state after retries

#### Tool state

What tools have been called, what they returned, what errors occurred.

```yaml
tool_trace:
  - tool: "internal_search"
    args: { query: "PII retention policy" }
    result: { doc_ids: ["POL-2025-001", "POL-2024-089"] }
    latency_ms: 340
    
  - tool: "fetch"
    args: { doc_id: "POL-2025-001" }
    result: { content: "...", last_updated: "2025-01-10" }
    latency_ms: 120
```

- **Scope**: Current task
- **Lifetime**: Often persisted for debugging/audit even after task completes
- **Risk**: Storing sensitive content from tool responses

#### Artifact state

The intermediate and final products. The evidence set, the draft, the validation report.

```yaml
artifacts:
  - name: "evidence_set"
    status: "complete"
    path: "/artifacts/task_001/evidence_set.yaml"
    
  - name: "draft_v1"
    status: "failed_validation"
    path: "/artifacts/task_001/draft_v1.md"
    
  - name: "draft_v2"
    status: "final"
    path: "/artifacts/task_001/draft_v2.md"
```

- **Scope**: Current task (may be promoted to longer-term storage)
- **Lifetime**: Persisted for audit and resumption
- **Risk**: Artifacts contain the real work—they need the same protection as the final output

State is mostly uncontroversial. You need it to do the task. The question is what happens to it when the task ends.

### Memory: what survives across tasks

Memory is what the agent retains after a task completes. This is where the policy decisions get interesting.

#### Ephemeral memory

Forgotten when the session ends. The safest default.

**What ephemeral means:**
- Conversation history from this session
- Task state from completed tasks
- Tool traces (unless persisted for audit)

**When ephemeral is right:**
- No user consent for retention
- Sensitive content was discussed
- Compliance requires minimal data retention

#### Session memory

Persists within a session (hours to days), then cleared.

**What session memory enables:**
- "We discussed this earlier today"
- Continuity across related tasks
- User doesn't have to repeat themselves

**When session memory is right:**
- User is working on a project over time
- Context is useful but not worth storing permanently
- Consent is implied by continued use

#### Long-term user preferences

Persisted indefinitely (with consent). Explicit opt-in.

**What long-term preferences include:**
- Voice and style preferences ("I prefer bullet points")
- Role and context ("I'm on the Security team")
- Past outputs they've approved as templates

**When to persist:**
- User explicitly approves
- Clear benefit to user from remembering
- Consent is documented

**What long-term memory does NOT include (without explicit approval):**
- Sensitive content from past tasks
- Internal documents or quotes
- Personal information beyond what's necessary

#### Organizational memory

Shared knowledge that belongs to the organization, not any individual user.

**What organizational memory includes:**
- House style guides
- Approved templates
- Common definitions and glossaries
- Feedback on past outputs (anonymized/aggregated)

**How it differs from user memory:**
- Owned by the organization, not the user
- Updated through formal processes
- Available to all users with appropriate permissions

### The memory stack

Think of memory as a stack with different retention policies at each layer:

```
┌─────────────────────────────────────────────┐
│  Organizational knowledge  │  Persistent   │  Org-owned
│  (style guides, templates) │  (versioned)  │
├─────────────────────────────────────────────┤
│  User preferences          │  Persistent   │  User-consented
│  (voice, role, context)    │  (with opt-in)│
├─────────────────────────────────────────────┤
│  Session memory            │  Hours–days   │  Auto-cleared
│  (recent tasks, context)   │               │
├─────────────────────────────────────────────┤
│  Task state                │  Task duration│  Auto-cleared
│  (plan, artifacts, tools)  │               │
├─────────────────────────────────────────────┤
│  Conversation              │  Conversation │  Auto-cleared
│  (messages, context)       │  duration     │
└─────────────────────────────────────────────┘
```

Each layer up means: higher retention, more policy, more consent required.

### Memory write gates: when persistence happens

Not everything should be persisted. Memory writes should be gated.

**Implicit write triggers (system-determined):**
- Task outcomes (what was produced, whether it succeeded)
- Aggregated usage patterns (not individual content)
- System errors and performance metrics

**Explicit write triggers (user-determined):**
- User says "remember this for next time"
- User approves output as template
- User sets a preference ("always use this format")

**Prohibited writes (policy-determined):**
- Content marked confidential
- Personal data beyond what's necessary
- Specific incidents or examples unless explicitly approved

A simple framework:

| Content type | Can persist? | Requires |
|---|---|---|
| User preference | Yes | User consent |
| Approved template | Yes | User approval + org policy |
| Task outcome (success/fail) | Yes | Nothing (audit) |
| Content from confidential sources | No | Must not persist |
| Personal information | Minimal | Data minimization policy |
| Real incident details | No | Explicit exception |

### Memory retrieval: when remembering happens

Storing information is only half the problem. The other half is when (and whether) to retrieve it.

**Retrieval should be:**
- **Scoped**: Only retrieve memory relevant to the current task
- **Filtered**: Respect permissions—don't retrieve memory the current user shouldn't see
- **Transparent**: Make it clear when past context is influencing the current output

**A retrieval anti-pattern:**
> "Based on your previous work, I'm including example scenarios from past projects."

If the user doesn't know what "previous work" is being referenced, they can't verify whether it's appropriate.

**A better pattern:**
> "I found 2 relevant templates from your past approved work: [Module A] and [Module B]. Should I use elements from either?"

Transparency turns retrieval from magic into a controllable feature.

### The redaction problem

Some content should never be persisted, even briefly. Some content should be redacted before persistence.

**Never persist:**
- Credentials, tokens, API keys
- Personal health information (unless it's part of the system's purpose)
- Content explicitly marked for deletion

**Redact before persisting:**
- Names in incident examples → "an employee" or "Employee A"
- Specific dates in examples → "recently" or "last quarter"
- Dollar amounts in examples → "significant" or "above threshold"

**Implementation:**
```yaml
redaction_rules:
  - pattern: "SSN: [0-9]{3}-[0-9]{2}-[0-9]{4}"
    action: "block_persist"
    
  - pattern: "@company.com"
    action: "redact"
    replacement: "@[redacted]"
    
  - pattern: "incident on [0-9]{4}-[0-9]{2}-[0-9]{2}"
    action: "redact"
    replacement: "incident on [date redacted]"
```

Redaction happens at the write gate, before content enters persistent storage.

### Forgetting: the feature nobody builds

Memory systems focus on remembering. Forgetting is just as important.

**Why forgetting matters:**
- Policies change—old guidance becomes wrong guidance
- People leave—their preferences shouldn't persist indefinitely
- Incidents resolve—the details become irrelevant
- Consent can be withdrawn—"delete what you know about me"

**Forgetting mechanisms:**

**TTL (time-to-live):** Memory expires after a period.
```yaml
memory_entry:
  content: "User prefers bullet points"
  created: "2025-01-15"
  ttl_days: 365
  expires: "2026-01-15"
```

**Explicit deletion:** User requests removal.
```yaml
memory_action:
  type: "delete"
  scope: "user_preferences"
  user_id: "user_123"
  reason: "user_request"
```

**Policy-based expiry:** Content tied to outdated policies gets cleared.
```yaml
memory_entry:
  content: "PII retention is 180 days"
  source_policy: "POL-2024-089"
  valid_until: policy superseded
  # Automatically expired when POL-2025-001 was published
```

Build forgetting into the system from day one. Retrofitting it is painful.

### Context window vs. memory

One more distinction that trips people up: the context window is not memory.

**Context window:** What fits in a single model call. Token-limited. Ephemeral. The model has no memory beyond what you pass in.

**Memory (as designed here):** Persistent storage that you choose to inject into context. Persists across calls. Subject to policy.

The model "remembers" across a conversation because you keep passing the conversation history. It "remembers" user preferences because you retrieve them and include them in the prompt.

This matters because:
- Memory requires policy; the context window doesn't
- Memory requires storage and retrieval infrastructure
- Memory creates liability; the context window (mostly) doesn't

### Designing memory for your system

A practical framework:

**Step 1: Classify content types**
What kinds of information flow through your agent?
- Task content (documents, drafts, evidence)
- User preferences (style, role, constraints)
- Organizational context (policies, templates)
- Sensitive content (incidents, PII, confidential material)

**Step 2: Assign retention policies**
For each content type:
- Default persistence level (ephemeral, session, long-term)
- Consent requirements
- Redaction requirements
- TTL if applicable

**Step 3: Define write gates**
What triggers persistence?
- System-determined (always log task outcomes)
- User-determined (explicit "save this" actions)
- Prohibited (never persist incident details)

**Step 4: Define retrieval rules**
When does memory get injected into context?
- Automatic (always include user preferences)
- On-request (retrieve past templates when asked)
- Scoped (only retrieve memory relevant to current topic)

**Step 5: Build forgetting**
How does memory expire?
- TTL-based expiry
- Policy-change expiry
- User-initiated deletion
- Organizational purge (compliance events)

## Case study thread

### Research+Write (Policy change brief)

The policy brief agent handles sensitive content—internal policies, guidance documents, potentially confidential context.

#### What to remember

**Organizational memory (persist with org governance):**
- House style guide (tone, format, common phrasings)
- Approved template variations
- Glossary of internal terms

**User preferences (persist with consent):**
- Preferred output format (sections, length)
- Role and team (for permission filtering)
- Past approved briefs (as templates if user opts in)

#### What NOT to remember

**Never persist:**
- Specific policy content retrieved during tasks
- Quotes from confidential documents
- Details of policy decisions or internal deliberations

**Redact before any persistence:**
- Names of policy owners → "[policy owner]"
- Specific dates of incidents → "[date]"
- Internal meeting references → "[internal discussion]"

#### Memory rubric for Research+Write

| Content | Persist? | Retention | Consent | Redaction |
|---|---|---|---|---|
| House style guide | Yes | Indefinite | Org | None |
| User format preference | Yes | 1 year | User | None |
| Brief template (approved) | Yes | 1 year | User | None |
| Policy content retrieved | No | Task only | N/A | N/A |
| Quotes from docs | No | Task only | N/A | N/A |
| Confidential context | No | Never | N/A | Block |
| Task outcome (success/fail) | Yes | Audit | System | None |

#### Write gate examples

```yaml
write_gates:
  - trigger: "user approves brief"
    action: "persist brief as template"
    requires: "user_consent"
    redact: ["internal_doc_quotes", "policy_owner_names"]
    
  - trigger: "task completes"
    action: "log outcome"
    requires: nothing
    persists: ["task_id", "status", "artifact_types"]
    
  - trigger: "confidential content detected"
    action: "block_persist"
    log: "confidentiality_block"
```

### Instructional Design (Annual compliance training)

The training module agent creates content that will be seen by many employees. Its memory needs are different.

#### What to remember

**Organizational memory (persist with org governance):**
- Approved learning objectives library
- Scenario templates (anonymized)
- Assessment item patterns
- Accessibility standards
- Brand and compliance requirements

**User preferences (persist with consent):**
- Preferred module formats
- Role context (learning designer, SME, etc.)
- Past modules they've authored (if opted in)

#### What NOT to remember

**Never persist:**
- Real incident details used as scenario inspiration
- Names of employees from examples
- Specific internal failures or breaches
- Sensitive operational details

**Redact before any persistence:**
- Employee names → "[employee]" or role-based ("a manager")
- Incident dates → "[recently]" or "[last quarter]"
- Specific dollar amounts → "[significant amount]"

#### Memory rubric for Instructional Design

| Content | Persist? | Retention | Consent | Redaction |
|---|---|---|---|---|
| Objective library | Yes | Indefinite | Org | None |
| Scenario templates | Yes | Indefinite | Org | Anonymize |
| Assessment patterns | Yes | Indefinite | Org | None |
| User module history | Yes | 1 year | User | None |
| Real incident details | No | Never | N/A | Block |
| Employee names in examples | No | Never | N/A | Block |
| Policy content (current) | No | Task only | N/A | N/A |
| Approval records | Yes | 7 years | Audit | None |

#### Write gate examples

```yaml
write_gates:
  - trigger: "module approved and published"
    action: "persist module as template"
    requires: "org_approval"
    redact: ["incident_details", "employee_names", "specific_dates"]
    
  - trigger: "new scenario created"
    action: "check for persistence eligibility"
    requires: "no_pii_check_pass"
    redact: ["names", "dates", "amounts"]
    
  - trigger: "approval recorded"
    action: "persist approval record"
    requires: nothing
    retention: "7_years"
    persists: ["approver", "timestamp", "module_id", "approval_type"]
```

## Artifacts to produce

- A **memory stack diagram** for each case study
- A **memory rubric** (what to remember, what to forget, what requires consent)
- A **write gate specification** (triggers, consent requirements, redaction rules)
- A **retrieval policy** (when memory gets injected into context)

## Chapter exercise

### Part 1: Build a memory rubric

For each case study, create a memory rubric answering:

1. What content types flow through the agent?
2. For each type, what is the default persistence level?
3. What requires user consent to persist?
4. What requires organizational approval to persist?
5. What must never persist?
6. What must be redacted before persistence?

### Part 2: Design write gates

Pick three persistence events for your agent. For each:
- What triggers the write?
- What consent is required?
- What redaction happens?
- What gets logged?

### Part 3: Plan for forgetting

Design the forgetting mechanisms:
- What TTLs apply to different memory types?
- How does a user delete their preferences?
- How does policy change trigger memory expiry?
- What happens during a compliance-required purge?

## Notes / references

- GDPR right to erasure (right to be forgotten): https://gdpr.eu/right-to-be-forgotten/
- CCPA deletion rights: https://oag.ca.gov/privacy/ccpa
- Data minimization principle: https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/principles/data-minimisation/
- MemGPT (memory-augmented agents): https://arxiv.org/abs/2310.08560
- LangChain memory concepts: https://python.langchain.com/docs/concepts/memory/
- Anthropic on memory and personalization: https://www.anthropic.com/news/memory

