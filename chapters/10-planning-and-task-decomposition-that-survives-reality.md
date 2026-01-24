# Chapter 10 — Planning and task decomposition that survives reality

## Purpose
Make plans useful, adaptable, and testable.

## Reader takeaway
Plans should be explicit artifacts with checkpoints and measurable completion criteria, not just prose lists.

## Key points
- Plans as artifacts: milestones, dependencies, measurable criteria
- Approaches: single-shot, rolling-wave replanning, hierarchical plans
- Uncertainty: exploration steps, branching/backtracking, budget-aware planning

## Draft

### The plan that didn't survive first contact

The agent had a beautiful plan.

Step 1: Search for the relevant policy. Step 2: Extract key changes. Step 3: Draft the brief. Step 4: Add citations. Step 5: Verify.

Clean, logical, linear. The kind of plan that looks great in a demo.

Then the search returned two policies with the same name—one current, one archived. The agent picked the archived one because it ranked slightly higher. It extracted "changes" that were actually three years old. It drafted a brief about policy that had been superseded. It added citations to the wrong document. The citations verified because the document existed.

The output was coherent, well-structured, and completely wrong.

The problem wasn't intelligence. The plan was sensible. The problem was rigidity. The plan had no checkpoints. No place where the agent asked "is this the right document?" No place where reality could push back.

This chapter is about building plans that survive contact with reality.

### What Chapter 7 set up

Chapter 7 established the agent loop: interpret → plan → act → observe → update → reflect → decide. The "plan" step generates the roadmap. The rest of the loop executes it.

But what makes a good plan? Not all plans are equal:

- A **bad plan** is a prose description that the model follows blindly
- A **good plan** is a structured artifact with checkpoints that can fail

The difference is testability. A good plan has points where you can ask "did this work?" and get a yes or no answer. A bad plan just describes steps and hopes.

### Plans are artifacts, not prose

The first shift: treat plans as first-class artifacts, not as text in a conversation.

A plan-as-artifact has structure:

**Steps.** What are the discrete actions to take?

**Dependencies.** What must complete before this step can start?

**Artifacts produced.** What does each step create that the next step consumes?

**Success criteria.** How do you know the step worked?

**Failure responses.** What do you do when the step fails?

When plans are artifacts, they become:
- **Inspectable.** You can review the plan before execution.
- **Debuggable.** You can see which step failed and why.
- **Resumable.** You can restart from a checkpoint instead of starting over.
- **Auditable.** You can explain what the agent was trying to do.

Compare:

**Plan as prose:**
> First I'll search for the policy, then I'll read it and extract the key changes, then I'll write a draft that cites those changes.

**Plan as artifact:**
```yaml
plan:
  goal: "Write policy change brief for PII retention update"
  steps:
    - id: 1
      action: "search"
      query: "PII retention policy current version"
      produces: ["candidate_doc_ids"]
      success: "at least 1 result with confidence > 0.8"
      failure: "expand query; if still empty, ask user"
      
    - id: 2
      action: "verify_document"
      inputs: ["candidate_doc_ids"]
      check: "confirm doc is current version, not archived"
      produces: ["verified_doc_id"]
      success: "doc.status == 'current'"
      failure: "reject doc; return to step 1 with exclusion"
      
    - id: 3
      action: "fetch"
      inputs: ["verified_doc_id"]
      produces: ["full_document"]
      success: "document retrieved with content"
      failure: "retry once; if failed, escalate"
```

The second version isn't just documentation. It's a control structure. Each step has a condition that can pass or fail. Each failure has a response.

### The checkpoint principle

The most important thing a plan can have is checkpoints—places where execution pauses to verify that things are on track.

Checkpoints answer the question: **"Should we continue?"**

Good checkpoint questions:
- Did we retrieve the right document? (not just *a* document)
- Does the evidence actually support the claims we're making?
- Are required fields present in the intermediate artifact?
- Have we consumed too much budget?

Without checkpoints, errors compound. The wrong document becomes the wrong quotes become the wrong claims become the wrong brief. Each step assumes the previous step succeeded. By the end, you're confidently wrong.

With checkpoints, errors surface early. "This document is archived, not current." The agent can backtrack, correct, and continue. Or it can stop and ask for help. Either way, it doesn't produce garbage with confidence.

### Where checkpoints belong

Not every step needs a checkpoint. Too many and you're just adding latency. Here's where they matter most:

**After retrieval.** Did you get the right sources? Is the document current? Is it the version you expected? Chapter 9's citation laundering starts with wrong retrieval.

**After extraction.** Does the evidence actually support the claims? Are quotes verbatim? Is coverage sufficient? Don't wait until drafting to discover you don't have what you need.

**After drafting.** Does the artifact match the template? Are required sections present? Do citations resolve? This is your last chance before delivery.

**At budget thresholds.** Have you consumed 50% of your tool-call budget? Time to check if you're making progress or spinning.

**Before effect actions.** About to create a ticket, send an email, or export a module? This is a natural gate for human approval.

### Three planning approaches

Different tasks call for different planning styles. Match the approach to the uncertainty.

#### Approach 1: Single-shot planning

Plan once at the start. Execute the plan. Done.

**When to use:**
- The task is well-understood and repeatable
- Inputs are complete (no exploration needed)
- The workflow is fixed (same steps every time)

**Example:** Generate a compliance training module for a well-defined role, with all policies already identified.

**Limitation:** No adaptability. If step 3 fails, you're starting over.

#### Approach 2: Rolling-wave planning

Plan the next few steps in detail. Execute them. Based on what you learn, plan the next few steps. Repeat.

**When to use:**
- The task involves research or exploration
- Early steps reveal information needed for later steps
- You can't fully specify the plan upfront

**Example:** Write a policy brief for a topic you need to research first. The search results determine what documents to fetch. The documents determine what claims to make.

**Implementation:**
```yaml
planning_approach: "rolling_wave"
horizon: 3  # plan 3 steps ahead
replan_triggers:
  - "checkpoint failed"
  - "new information changes assumptions"
  - "budget threshold reached"
```

**Advantage:** Adapts to reality. Each planning phase uses what you learned in execution.

#### Approach 3: Hierarchical planning

Plan at multiple levels of abstraction. High-level plan stays stable. Sub-plans can change.

**When to use:**
- Complex tasks with multiple phases
- Some phases are well-defined, others need exploration
- You need to track progress at different granularities

**Example:** The training module has fixed phases (objectives → content → assessments → QA) but each phase has variable sub-tasks depending on topic complexity.

**Implementation:**
```yaml
high_level_plan:
  phases:
    - name: "Define objectives"
      sub_plan: null  # to be generated
      done_when: "objectives artifact exists with >= 3 items"
    - name: "Generate content"
      sub_plan: null
      done_when: "content artifact covers all objectives"
    - name: "Create assessments"
      sub_plan: null
      done_when: "assessment artifact with alignment check passed"
```

The high-level plan provides structure. Sub-plans provide flexibility.

### Planning under uncertainty

The hardest plans are for tasks where you don't know what you'll find.

**Research tasks** are inherently uncertain. You don't know if the policy exists, what it says, or whether sources will agree.

**First-time tasks** are uncertain. You've never designed training for this role before. You don't know what edge cases exist.

**Ambiguous requests** are uncertain. The user said "write about the PII update" but there are three PII-related updates this quarter.

Uncertainty-aware planning uses three techniques:

#### Technique 1: Exploration steps

Before committing to a plan, explore. Understand what you're working with.

```yaml
step:
  action: "explore"
  description: "Survey available sources for PII policy"
  produces: ["source_inventory"]
  questions_to_answer:
    - "How many relevant policies exist?"
    - "Which is the current version?"
    - "Are there conflicting documents?"
  success: "questions answered with confidence"
  failure: "ask user for clarification"
```

Exploration steps are cheap. They're searches, quick reads, inventory-building. They don't commit you to a direction—they inform the direction.

#### Technique 2: Branching and backtracking

Build the ability to change course into the plan itself.

```yaml
step:
  action: "verify_source"
  inputs: ["candidate_doc"]
  branches:
    - condition: "doc is current and relevant"
      next: "proceed to extraction"
    - condition: "doc is archived"
      next: "return to search with exclusion filter"
    - condition: "doc is ambiguous"
      next: "ask user which version to use"
```

This isn't failure handling—it's expected variance. Different conditions lead to different paths. The plan anticipates them.

#### Technique 3: Budget-aware planning

Uncertainty costs resources. You might need more searches, more iterations, more verification. The plan should know its budget and adapt.

```yaml
budget_awareness:
  tool_calls:
    total: 15
    current: 0
    at_50_pct: "evaluate progress; compress remaining steps if behind"
    at_80_pct: "must have draft artifact; skip optional refinements"
  latency:
    max_seconds: 90
    at_75_pct: "use faster/simpler retrieval; skip reranking"
```

When you're running out of budget, the plan should simplify. Cut optional steps. Use faster tools. Deliver what you have instead of nothing.

### The replan decision

When do you change the plan? Not every difficulty requires replanning. Sometimes you just retry.

**Replan when assumptions change:**
- You expected one document; there are three
- The document you needed doesn't exist
- User clarifies that the scope is different than assumed

**Replan when the current path is blocked:**
- A required tool is unavailable
- Permissions prevent access to needed sources
- The checkpoint reveals fundamental gaps

**Don't replan for normal variance:**
- A search returned 8 results instead of 10
- One fetch timed out (retry it)
- The draft needs minor revisions

The key question: **"Does continuing with the current plan still make sense?"** If yes, continue. If no, replan.

### What plans produce

Every step in a plan should produce something. These intermediate artifacts are how you:
- Verify progress (the artifact exists and meets criteria)
- Resume after interruption (pick up from the last artifact)
- Debug failures (see what each step produced)
- Build trust (show your work)

Common intermediate artifacts:

**Source inventory:** What documents did exploration find?
```yaml
sources:
  - doc_id: "POL-2025-001"
    title: "PII Retention Policy v3"
    status: "current"
    relevance: 0.95
  - doc_id: "POL-2024-089"
    title: "PII Retention Policy v2"
    status: "archived"
    relevance: 0.82
    note: "superseded by POL-2025-001"
```

**Evidence set:** What did you extract from sources?
```yaml
evidence:
  - claim: "Retention period reduced from 180 to 90 days"
    source: "POL-2025-001"
    section: "3.2"
    quote: "Personal data must be deleted within 90 days..."
    previous: "POL-2024-089: ...within 180 days..."
```

**Draft with annotations:** The working output with notes.
```yaml
draft:
  sections:
    - title: "Summary"
      content: "The updated PII Retention Policy reduces..."
      citations: ["claim_001", "claim_002"]
    - title: "Key Changes"
      content: "..."
      citations: ["claim_003"]
    - title: "Required Actions"
      content: "..."
      citations: []
      note: "NEEDS SOURCES for action items"
```

**Validation results:** What checks passed or failed?
```yaml
validation:
  citation_check:
    status: "passed"
    coverage: 0.85
    gaps: ["Required Actions section has no citations"]
  template_check:
    status: "passed"
    required_sections: ["Summary", "Key Changes", "Required Actions", "Timeline"]
    present: ["Summary", "Key Changes", "Required Actions", "Timeline"]
```

Each artifact is stored, timestamped, and linked to the step that produced it.

## Case study thread

### Research+Write (Policy change brief)

Let's build a plan for the policy brief that survives reality.

#### The task graph

```
[clarify] → [research_plan] → [gather] → [extract] → [outline] → [draft] → [verify] → [revise] → [deliver]
     ↓              ↓             ↓           ↓           ↓          ↓           ↓
  (inputs)      (sources      (evidence)  (citations)  (structure)  (draft)   (validation)
              inventory)
```

#### Step-by-step with checkpoints

**Step 1: Clarify**
- Action: Parse request and identify missing information
- Produces: `requirements` artifact (scope, audience, "as-of" date, allowed sources)
- Checkpoint: All required fields present?
- Failure: Ask user clarifying questions (max 5)

**Step 2: Research plan**
- Action: Survey what's available, identify search strategy
- Produces: `source_inventory` artifact (candidate docs, their status, relevance)
- Checkpoint: At least 1 current, relevant source found?
- Failure: Expand search; if still empty, report "insufficient sources"

**Step 3: Gather**
- Action: Fetch full documents for top candidates
- Produces: `retrieved_docs` artifact (full content with metadata)
- Checkpoint: Primary source retrieved and verified current?
- Failure: Backtrack to research plan with exclusions

**Step 4: Extract**
- Action: Pull quotes and evidence for each key claim
- Produces: `evidence_set` artifact (claims → sources → quotes)
- Checkpoint: Claim coverage ≥ 80%? No unsourced claims for key sections?
- Failure: Additional targeted search; mark remaining gaps

**Step 5: Outline**
- Action: Structure the brief per template
- Produces: `outline` artifact (sections with evidence assignments)
- Checkpoint: All required sections present? Each section has evidence?
- Failure: Revise section assignments; flag gaps to user

**Step 6: Draft**
- Action: Write the brief using outline and evidence
- Produces: `draft` artifact (full text with inline citation markers)
- Checkpoint: Draft renders? All citation markers have evidence?
- Failure: Revise draft; ensure citation markers resolve

**Step 7: Verify**
- Action: Run citation verification, redaction check, template compliance
- Produces: `validation_report` artifact (pass/fail per check)
- Checkpoint: All verifications pass?
- Failure: Route to revise step with specific issues

**Step 8: Revise (conditional)**
- Action: Address verification failures
- Produces: Updated `draft` artifact
- Checkpoint: Re-verify passes?
- Failure: Max 2 revisions; then escalate to human

**Step 9: Deliver**
- Action: Package final brief
- Produces: `final_brief` artifact
- Gate: Human approval (if required by policy)

#### Budget allocation

| Phase | Tool calls | Latency target |
|---|---|---|
| Clarify | 0-1 | 5s |
| Research plan | 2-3 | 15s |
| Gather | 2-4 | 20s |
| Extract | 1-2 | 10s |
| Outline + Draft | 1-2 | 20s |
| Verify | 2-3 | 10s |
| Revise (if needed) | 1-2 | 15s |
| **Total** | **9-17** | **<90s** |

### Instructional Design (Annual compliance training)

The training module requires a more hierarchical plan because each phase has significant sub-work.

#### The task graph

```
[clarify] → [policy_mapping] → [objectives] → [content_flow] → [scenarios] → [assessments] → [qa_checks] → [approval] → [export]
     ↓             ↓               ↓              ↓               ↓              ↓              ↓            ↓
 (constraints)  (policy_map)  (objectives)    (outline)      (scenarios)   (items_bank)   (validation)  (approval)
                                                                                                          (export)
```

#### Phase-level plan with sub-phases

**Phase 1: Clarify and scope**
- Understand: role, region, modality, time budget, topics required
- Produces: `module_requirements` artifact
- Done when: All required constraints specified

**Phase 2: Policy mapping**
- Retrieve current policies for each required topic
- Produces: `policy_map` artifact (topic → policy → section → last verified)
- Checkpoint: Every topic has at least one policy reference?
- Failure: Flag missing policy coverage; ask user if required

**Phase 3: Learning objectives**
- Generate performance-based objectives for each topic
- Produces: `objectives` artifact (structured list with verbs, conditions, criteria)
- Checkpoint: Objectives are measurable? Cover all mapped policies?
- Failure: Revise objectives to meet criteria

**Phase 4: Content flow**
- Design module structure and flow
- Produces: `module_outline` artifact (sections, sequence, time allocations)
- Checkpoint: Flow covers all objectives? Time budget realistic?
- Failure: Adjust sequence or scope

**Phase 5: Scenarios and activities**
- Generate practice scenarios for each objective
- Produces: `scenarios` artifact (context, decision points, feedback)
- Checkpoint: Every objective has practice? Scenarios are role-appropriate?
- Failure: Generate additional scenarios for gaps

**Phase 6: Assessments**
- Generate assessment items for each objective
- Produces: `items_bank` artifact (items with rationales, objective mapping)
- Checkpoint: Every objective assessed? Item quality criteria met?
- Failure: Generate additional items; revise weak items

**Phase 7: QA checks**
- Run alignment check, accessibility check, policy freshness check
- Produces: `qa_report` artifact (pass/fail per check with details)
- Checkpoint: All checks pass?
- Failure: Route to specific remediation; flag blockers

**Phase 8: Approval (human gate)**
- Package for review: Security, Legal/Privacy, SME sign-off
- Produces: `approval_log` artifact (approver, timestamp, notes)
- Gate: Required approvals obtained
- Failure: Cannot proceed without approval

**Phase 9: Export**
- Package for LMS import
- Produces: `export_package` artifact
- Effect tool with confirmation

#### Checkpoint examples

**After objectives:**
```yaml
checkpoint:
  name: "objectives_quality"
  checks:
    - each objective uses action verb from Bloom's taxonomy
    - each objective has measurable criterion
    - objectives cover all policies in policy_map
  pass: all checks true
  fail: return to objective generation with specific gaps
```

**After assessments:**
```yaml
checkpoint:
  name: "alignment_complete"
  checks:
    - alignment_check tool returns pass: true
    - gaps array is empty
  pass: proceed to QA
  fail: generate additional items for uncovered objectives
```

## Artifacts to produce

- A **plan template** for multi-step agent tasks
- **Task graphs** for both case studies showing steps, artifacts, and checkpoints
- A **checkpoint design guideline** (where checkpoints belong, what they verify)
- A **replanning trigger taxonomy** (when to replan vs. retry vs. escalate)

## Chapter exercise

### Part 1: Task decomposition

Take a vague request and convert it into a task graph with checkpoints.

**For Research+Write:** "Write about the recent changes to our data handling."

1. What clarifications do you need?
2. What are the steps from request to deliverable?
3. Where do checkpoints belong?
4. What artifacts does each step produce?
5. What triggers replanning vs. normal retry?

**For Instructional Design:** "We need training for the new managers."

Same questions. Notice how ambiguity creates more exploration steps.

### Part 2: Checkpoint design

For your task graph, design three checkpoints:

1. **Early checkpoint (after exploration):** What verifies you're on the right track?
2. **Mid checkpoint (after core work):** What verifies the substance is correct?
3. **Late checkpoint (before delivery):** What verifies the output is usable?

For each, specify:
- What is checked
- How to check it (tool, heuristic, model judgment, human review)
- What happens on failure

### Part 3: Budget stress test

Your task has budget: 15 tool calls, 90 seconds, $0.10.

Design your plan to:
- Have a viable output path within 50% of budget
- Degrade gracefully if budget runs low
- Know when to stop and deliver partial results vs. fail completely

## Notes / references

- Hierarchical planning (HTN): https://en.wikipedia.org/wiki/Hierarchical_task_network
- Plan-Do-Check-Act cycle: https://en.wikipedia.org/wiki/PDCA
- ReAct (planning + acting with tools): https://arxiv.org/abs/2210.03629
- Tree of Thoughts (branching exploration): https://arxiv.org/abs/2305.10601
- LLM+P (LLM with classical planners): https://arxiv.org/abs/2304.11477
- "Reasoning is Planning" on LLM task decomposition: https://arxiv.org/abs/2305.04091

