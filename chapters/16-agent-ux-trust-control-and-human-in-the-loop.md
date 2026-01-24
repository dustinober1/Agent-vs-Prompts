# Chapter 16 — Agent UX: trust, control, and human-in-the-loop

## Purpose
Make agents usable and safe for real users.

## Reader takeaway
Trust comes from previews, sources, approvals, undo, and audit logs—especially when agents can take actions. The goal isn't minimal friction; it's calibrated control.

## Key points
- Trust: previews/confirmations, visible sources, explainable next steps, undo/audits
- Human-in-the-loop: approval gates, review queues, clarification questions
- UX anti-patterns: black-box autopilot, overconfidence, irreversible actions

## Draft

### The agent that deleted production

The compliance training agent had a bug. When it exported a lesson to the LMS, a malformed course ID caused the export to overwrite an existing course instead of creating a new one. The agent operated as designed: it completed its task, verified the upload succeeded, and reported success.

Three hundred employees lost their progress on the annual security training. The completion records—required for the upcoming audit—were gone. Restoring from backup took two days. The audit got delayed.

The postmortem was uncomfortable. The agent had done nothing wrong in the sense of violating its constraints. It received valid credentials, made a valid API call, got a success response, and moved on. The problem was that the humans in the loop—the instructional designer who requested the export, the LMS administrator who issued the credentials—never had a chance to catch the mistake.

No one saw the course ID before the API call happened.
No one was asked "Are you sure you want to overwrite 'SEC-2024-Q4'?"
No one could undo the action after it completed.

The agent had power without oversight.

This is the UX problem at the heart of agentic systems. Agents can take actions—real, consequential, sometimes irreversible actions. The interface between agent and user must account for this power. Getting it right isn't about adding more confirmation dialogs. It's about designing the right moments of control, the right information to surface, and the right recovery paths when things go wrong.

### The trust equation

Users trust agents when they understand what's happening, can verify claims, can intervene when needed, and can recover from mistakes. Each dimension contributes to trust:

**Transparency**: What is the agent doing right now? What will it do next?

**Verifiability**: Can I check the agent's claims? Are sources visible?

**Control**: Can I stop, modify, or redirect the agent's behavior?

**Recoverability**: If something goes wrong, can I undo it?

| Trust dimension | Low trust design | High trust design |
|-----------------|------------------|-------------------|
| Transparency | "Processing your request..." | "Searching 3 internal policy documents for approval thresholds..." |
| Verifiability | "Based on my analysis..." | "Based on Policy POL-2025-003, Section 4.2: [quote]" |
| Control | Agent runs to completion | Checkpoints where user can pause, edit, redirect |
| Recoverability | Actions are permanent | Drafts before publish; rollback available for 30 days |

These aren't abstract principles. Research consistently shows that users are more likely to adopt and trust AI systems when the logic is explained—59% more likely, according to recent industry surveys. Transparency directly contributes to adoption.

### Transparency through progressive disclosure

Users don't need to see everything the agent does. They need to see enough to trust that it's working correctly—and to catch it when it's not.

**Progressive disclosure** reveals information at the right moment:

1. **Summary level**: What did the agent accomplish? "Found 12 sources, drafted 4 sections, ready for review."

2. **Detail level**: What steps did it take? "Searched policy wiki (8 results), fetched external guidance (4 results), filtered by date..."

3. **Full trace level**: What was the raw input/output? Tool calls, API responses, intermediate reasoning.

Most users operate at the summary level. Experts and debuggers need detail and trace levels. Design interfaces that support all three without forcing the summary-level user through the trace.

```yaml
progressive_disclosure:
  summary:
    visible_by_default: true
    content:
      - current_step: "Drafting executive summary"
      - progress: "3 of 5 sections complete"
      - status: "On track"
      
  detail:
    visible_on_expand: true
    content:
      - steps_completed:
          - "Retrieved 8 policy documents"
          - "Extracted 12 relevant quotes"
          - "Generated outline (approved)"
      - steps_pending:
          - "Draft executive summary"
          - "Verify citations"
          
  trace:
    visible_in_debug_mode: true
    content:
      - tool_calls: [...]
      - api_responses: [...]
      - model_reasoning: [...]
```

#### Explaining next steps

The agent should announce what it's about to do, not just what it did. This gives users a chance to intervene before an action, not just react after.

**Anti-pattern**: "Done! Your brief has been published."

**Pattern**: "I'm about to publish this brief to the compliance portal. This will make it visible to all employees. [Publish now] [Let me review first]"

This is especially critical for:
- **Irreversible actions**: Publish, send, delete, approve
- **External communications**: Emails, messages, notifications
- **System changes**: Configuration updates, permission grants
- **Financial operations**: Payments, transfers, purchases

### Verifiability through visible sources

Chapter 9 established that agents should cite their sources. From a UX perspective, citations serve a trust function: they let users verify claims without re-doing the research.

**Visible sources** means:
- Claims link to their supporting evidence
- Users can click through to the original document
- The agent distinguishes between direct quotes and paraphrases
- Confidence is calibrated (more on this below)

For the Research+Write agent, this means every factual claim in the brief can be traced to a source:

```yaml
claim_source_map:
  - claim: "The expense threshold increased from $500 to $1000"
    source:
      doc_id: "POL-2025-003"
      section: "4.2 Approval Requirements"
      quote: "Effective January 1, 2025, expenses under $1,000 require only direct manager approval."
    confidence: "direct_quote"
    
  - claim: "This aligns with industry benchmarks"
    source:
      doc_id: "EXTERNAL-Gartner-2024"
      section: "Expense Management Trends"
      quote: "The median approval threshold for mid-size companies rose to $950 in 2024."
    confidence: "supporting_evidence"
```

For the Instructional Design agent, this means every learning objective traces to a policy requirement, and every assessment traces to an objective:

```yaml
alignment_map:
  - objective: "Recognize phishing attempts in email"
    policy_basis:
      doc_id: "SEC-POL-001"
      section: "3.1 Phishing Awareness"
    assessments:
      - "Knowledge check: Identify phishing indicators"
      - "Scenario: Rate these emails as safe or suspicious"
```

### Control through approval gates

Not every action needs approval. The cost of interruption is real—constant confirmations frustrate users and teach them to click "yes" without reading. The goal is **calibrated control**: approval gates at the right moments.

#### When to require approval

Approval gates are appropriate when:
- **The action is irreversible** (publish, send, delete)
- **The action has external impact** (emails, notifications, API calls to third parties)
- **The stakes are high** (financial, legal, compliance)
- **The agent's confidence is low** (uncertain interpretation, conflicting sources)
- **The user explicitly requested confirmation** (preference setting)

Approval gates are inappropriate when:
- **The action is easily reversible** (draft creation, internal state changes)
- **The stakes are low** (formatting, word choice)
- **Speed matters more than oversight** (real-time responses)
- **The interruption would be more costly than the error** (micro-decisions)

#### Designing approval flows

An approval flow has three components:

1. **What's being approved**: Clear description of the action and its effects
2. **What information helps the decision**: Context, previews, risk indicators
3. **What options exist**: Approve, reject, modify, defer

```yaml
approval_flow:
  action: "publish_to_lms"
  display_name: "Publish training module to LMS"
  
  context:
    - module_name: "Annual Security Training 2025"
    - target_audience: "All employees"
    - affected_users: 3400
    - replaces: "Annual Security Training 2024"
    
  preview:
    - diff_view: "Changes from previous version"
    - accessibility_report: "All checks passed"
    - estimated_completion_time: "45 minutes"
    
  risk_indicators:
    - level: "medium"
    - reasons:
        - "Replaces existing module"
        - "Will reset progress for 12 learners currently in progress"
        
  options:
    - action: "approve"
      label: "Publish now"
    - action: "approve_with_delay"
      label: "Schedule for tonight at midnight"
    - action: "reject"
      label: "Cancel publication"
    - action: "modify"
      label: "Make changes first"
```

#### Implementation patterns

LangGraph provides built-in support for human-in-the-loop via the `interrupt` primitive:

```python
from langgraph.types import interrupt, Command

def publish_approval_node(state: State) -> Command[Literal["publish", "cancel"]]:
    # Pause and present the approval request
    is_approved = interrupt({
        "question": "Ready to publish this training module?",
        "module_name": state["module_name"],
        "affected_users": state["affected_users"],
        "risk_level": state["risk_level"]
    })
    
    # Route based on the human's decision
    if is_approved:
        return Command(goto="publish")
    else:
        return Command(goto="cancel")
```

Anthropic's guidance for computer use (agents that control desktop environments) emphasizes requiring human confirmation for "decisions that may result in meaningful real-world consequences as well as any tasks requiring affirmative consent, such as accepting cookies, executing financial transactions, or agreeing to terms of service."

The principle applies broadly: **the more consequential the action, the more explicit the approval should be.**

### Confidence calibration: the language of uncertainty

Agents often sound more confident than they should. This is a UX problem because it teaches users to over-trust agent outputs.

#### The overconfidence problem

Models are trained to produce fluent, confident text. This creates a mismatch between epistemic state and linguistic expression:

| Agent's actual state | What the agent says |
|----------------------|---------------------|
| "I found one source that mentions this" | "Research clearly shows..." |
| "This might be relevant but I'm not sure" | "The key insight is..." |
| "I'm extrapolating from partial data" | "Based on my analysis..." |

Users can't distinguish high-confidence claims from low-confidence guesses because both sound equally certain.

#### Calibrating confidence language

Design a confidence vocabulary that maps uncertainty to language:

```yaml
confidence_language:
  high:
    threshold: 0.9
    phrases:
      - "The policy states..."
      - "[Source] directly confirms..."
      - "This is explicitly documented in..."
    when: "Direct quote or unambiguous policy statement"
    
  medium:
    threshold: 0.7
    phrases:
      - "Based on [source], it appears that..."
      - "The evidence suggests..."
      - "Multiple sources indicate..."
    when: "Inference from clear evidence"
    
  low:
    threshold: 0.5
    phrases:
      - "It's possible that..."
      - "One interpretation is..."
      - "I wasn't able to find definitive guidance, but..."
    when: "Limited evidence or ambiguous sources"
    
  uncertain:
    threshold: 0.0
    phrases:
      - "I don't have enough information to determine..."
      - "This falls outside what I can verify..."
      - "You may want to consult [expert/source] for..."
    when: "Insufficient evidence or outside scope"
```

The goal isn't to hedge everything—that creates its own trust problem. The goal is **calibration**: confidence language that matches actual confidence.

### Review queues and async approval

Not all approvals can be synchronous. Some decisions need time, expertise, or authority that isn't immediately available.

#### Review queue patterns

```yaml
review_queue:
  name: "policy_brief_reviews"
  
  item:
    id: "brief-2025-001"
    type: "policy_brief"
    status: "pending_review"
    submitted_at: "2025-01-23T10:00:00Z"
    
    created_by: "research_write_agent"
    requested_reviewer: "policy_owner"
    
    context:
      - brief_summary: "Expense policy changes for Q2"
      - word_count: 1200
      - citations: 8
      
    review_type: "approval_required"
    sla: "24 hours"
    
  workflow:
    on_approve: "publish_to_portal"
    on_reject: "return_to_drafting"
    on_timeout: "escalate_to_manager"
```

Review queues enable:
- **Asynchronous approval**: Reviewers work on their schedule
- **Expertise routing**: Send to the right person for the decision
- **SLA enforcement**: Escalate if decisions take too long
- **Audit trail**: Record who approved what, when

### Interactive clarification

When the agent is uncertain, it should ask rather than guess. But clarification questions have UX costs: every question is an interruption.

#### Good clarification questions

- **Specific**: "Should I include the pending policy changes or only finalized ones?"
- **Actionable**: "I found conflicting dates. Is the correct deadline January 15 or January 30?"
- **Minimized**: Ask one question that unblocks multiple steps, not multiple questions for the same issue

#### Bad clarification questions

- **Vague**: "What would you like me to do?"
- **Lazy**: "Should I continue?" (when the answer is obviously yes)
- **Premature**: Asking before attempting to find the answer
- **Redundant**: Asking the same question in different words

The design goal: **ask when it matters, assume when it doesn't.**

```yaml
clarification_decision:
  situation: "Found two policies with potentially conflicting guidance"
  
  options:
    1_ask:
      question: "POL-001 says X, but POL-002 says Y. Which should I follow?"
      when: "Conflict is material to the output"
      
    2_assume:
      assumption: "Use the more recent policy (POL-002)"
      when: "Clear recency hierarchy exists"
      note_in_output: "Note: Using POL-002 as it supersedes POL-001"
      
    3_include_both:
      action: "Present both interpretations"
      when: "Both are valid depending on context"
```

### Recoverability: undo and rollback

Errors happen. Good UX provides recovery paths.

#### Types of recovery

| Recovery type | When it applies | Implementation |
|---------------|-----------------|----------------|
| Undo | Action just completed | Reverse the last action |
| Rollback | Multiple actions to revert | Restore to previous checkpoint |
| Draft | Before final action | Preview without committing |
| Archive | After deletion | Soft delete with retrieval |

#### Drafts before publish

The most important recovery pattern: **never go directly to the final destination.**

- Research+Write: Draft the brief, review, then publish
- Instructional Design: Draft the module, review, then export to LMS

The draft stage is where humans catch errors. Agents should default to drafts, not final outputs.

```yaml
artifact_pipeline:
  stages:
    - name: "draft"
      visibility: "author only"
      actions: [edit, delete, promote]
      
    - name: "review"
      visibility: "reviewers"
      actions: [comment, approve, reject, request_changes]
      
    - name: "published"
      visibility: "public"
      actions: [archive, update_with_new_version]
```

#### Audit logs

Every action should be logged with enough detail to:
- **Understand what happened**: Action, actor, timestamp, parameters
- **Reproduce the decision**: What did the agent see? What choices did it consider?
- **Attribute responsibility**: Who approved? Who could have intervened?

```yaml
audit_entry:
  action_id: "act-2025-001-42"
  timestamp: "2025-01-23T15:30:00Z"
  
  action:
    type: "publish_to_lms"
    target: "course-SEC-2025-Q1"
    parameters:
      replace_existing: true
      
  agent:
    id: "instructional_design_agent"
    version: "2.3.1"
    
  approval:
    required: true
    approved_by: "user@company.com"
    approved_at: "2025-01-23T15:29:55Z"
    approval_context:
      - "Reviewed preview"
      - "Acknowledged 12 learners in progress"
      
  reversibility:
    undo_available: true
    undo_deadline: "2025-02-23T15:30:00Z"
    rollback_point: "checkpoint-2025-001-41"
```

### UX anti-patterns

These patterns erode trust. Avoid them.

#### Anti-pattern 1: Black-box autopilot

The agent runs to completion without visibility into what it's doing or opportunities to intervene.

**What it looks like**: "Your training module is ready!" with no intermediate steps visible.

**Why it's bad**: Users can't catch errors until it's too late. They learn to not trust the output.

**Fix**: Show progress, allow checkpoints, provide previews before final actions.

#### Anti-pattern 2: Overconfident tone

The agent expresses certainty it doesn't have.

**What it looks like**: "The policy clearly states..." when the policy is ambiguous.

**Why it's bad**: Users trust claims that don't deserve trust. When they discover errors, they stop trusting anything.

**Fix**: Calibrate confidence language. Cite sources. Flag uncertainty explicitly.

#### Anti-pattern 3: Irreversible actions without confirmation

The agent takes permanent actions without explicit approval.

**What it looks like**: Publishing, sending, deleting without a confirmation step.

**Why it's bad**: Recovery is impossible or costly. Users fear using the agent.

**Fix**: Require approval for irreversible actions. Provide undo where possible.

#### Anti-pattern 4: Confirmation fatigue

The agent asks for approval so often that users stop reading and just click "yes."

**What it looks like**: "Confirm?" after every minor step.

**Why it's bad**: Users become blind to the approval dialogs. Critical confirmations get ignored.

**Fix**: Reserve confirmation for high-stakes actions. Batch low-stakes decisions.

#### Anti-pattern 5: Hidden errors

The agent encounters problems but doesn't surface them to the user.

**What it looks like**: "Complete!" when actually several steps failed silently.

**Why it's bad**: Users trust an output that has known issues.

**Fix**: Surface errors clearly. Distinguish complete success from partial success.

### Designing for trust levels

Different users have different trust relationships with agents. Design for the spectrum:

| Trust level | User behavior | UX design |
|-------------|---------------|-----------|
| Skeptical | Verifies everything, prefers to see all steps | Full transparency mode, detailed citations, approval gates |
| Calibrated | Spot-checks, trusts but verifies | Progressive disclosure, summary-first, approval for high-stakes |
| Trusting | Accepts most output, reviews when flagged | Minimal friction, surface issues only, auto-approve low-stakes |

Let users choose their trust level. Some want oversight; others want speed.

```yaml
trust_settings:
  user_id: "user@company.com"
  
  preferences:
    approval_mode: "high_stakes_only"  # or "always" or "never"
    show_sources: "on_expand"  # or "always" or "on_request"
    explain_steps: "summary"  # or "detail" or "trace"
    
  overrides:
    - context: "financial_actions"
      approval_mode: "always"
    - context: "external_communications"
      approval_mode: "always"
```

## Case study thread

### Research+Write (Policy change brief)

The brief workflow implements trust patterns at each stage.

#### UX gates and transparency

```yaml
brief_ux_flow:
  stages:
    - name: "research"
      transparency:
        - "Searching internal policy wiki..."
        - "Found 8 relevant documents"
        - "Searching external regulatory sources..."
        - "Found 4 external references"
      user_action: "View source list"
      
    - name: "outline"
      transparency:
        - "Proposed outline based on sources"
        - sections_preview: [...]
      user_action: "Approve outline or suggest changes"
      approval_required: true
      
    - name: "draft"
      transparency:
        - "Drafting section 1 of 4..."
        - word_count: 450
        - citations: 6
      user_action: "View draft in progress"
      
    - name: "verify"
      transparency:
        - "Verifying 6 citations..."
        - "All citations resolved"
        - redaction_check: "Passed"
      user_action: "View verification report"
      
    - name: "publish"
      transparency:
        - "Ready to publish to compliance portal"
        - visibility: "All employees"
        - replaces: "None (new brief)"
      user_action: "Approve or cancel publication"
      approval_required: true
```

#### What to show the user

The claim-to-source map and redaction summary are the key artifacts for user review:

**Claim-source map**:
- Every factual claim in the brief
- The source supporting that claim
- Direct quotes where applicable
- Confidence level

**Redaction summary**:
- Categories of sensitive content checked
- Any flagged content (even if ultimately included)
- Handling decision for each flag

### Instructional Design (Annual compliance training)

The training module workflow has more approval gates because it involves multiple stakeholders.

#### UX gates and transparency

```yaml
training_ux_flow:
  stages:
    - name: "constraints"
      transparency:
        - audience: "All employees"
        - time_limit: "45 minutes"
        - policies: ["SEC-POL-001", "PRIV-POL-003"]
      user_action: "Confirm constraints"
      approval_required: true
      
    - name: "objectives"
      transparency:
        - objectives_count: 5
        - policy_mapping: "All objectives trace to policy requirements"
        - measurable: "All objectives have observable outcomes"
      user_action: "Approve objectives"
      review_routing: "SME"
      approval_required: true
      
    - name: "assessments"
      transparency:
        - assessment_count: 12
        - coverage: "All objectives assessed"
        - rubrics: "Defined for all items"
      user_action: "Approve assessments before activities"
      approval_required: true
      
    - name: "activities"
      transparency:
        - activity_count: 8
        - scenarios: 3
        - alignment_check: "Passed"
      user_action: "Review activities"
      
    - name: "accessibility"
      transparency:
        - accessibility_report: "All checks passed"
        - reading_level: "Grade 8"
        - captions: "Present for all video"
      user_action: "View accessibility report"
      
    - name: "export"
      transparency:
        - target_lms: "Internal LMS"
        - package_format: "SCORM 2004"
        - affected_learners: 3400
      user_action: "Approve export"
      review_routing: "Compliance"
      approval_required: true
```

#### What to show the user

**Alignment rubric results**:
- Matrix of objectives × assessments × activities
- Gaps highlighted
- Coverage percentage

**Accessibility checklist**:
- Each check performed
- Pass/fail status
- Remediation suggestions for any issues

## Artifacts to produce

- **Approval flow specifications**: What gets approved, by whom, when
- **Transparency templates**: What to show at each stage
- **Confidence language guide**: How to express uncertainty
- **Audit log schema**: What to record for each action

## Chapter exercise

Design an approval flow for a tool that can publish a draft (CMS/repo) or push a lesson into an LMS.

### Part 1: Identify the action

1. What exactly does the tool do?
2. What is the scope of impact? (Who sees it? What changes?)
3. Is the action reversible? How?
4. What are the failure modes?

### Part 2: Design the approval interface

1. What information does the approver need to make a decision?
2. What preview or diff should be shown?
3. What risk indicators should be surfaced?
4. What options exist beyond approve/reject?

### Part 3: Define the workflow

1. Who can approve?
2. What's the escalation path if approval is delayed?
3. What happens on approval? On rejection?
4. What gets logged for audit?

### Part 4: Handle recovery

1. What undo capability exists?
2. How long is undo available?
3. What rollback mechanism exists?
4. How are errors surfaced to users?

## Notes / references

- LangGraph interrupts (human-in-the-loop patterns): https://docs.langchain.com/oss/python/langgraph/interrupts
- Anthropic computer use security considerations: https://docs.anthropic.com/en/docs/build-with-claude/computer-use
- Progressive disclosure in UX: https://www.interaction-design.org/literature/topics/progressive-disclosure
- XAI and transparency in AI systems: https://www.researchgate.net/publication/transparency-explainability-ai
- Trust calibration in AI agents: Salesforce research showing 59% adoption increase when logic is explained
- UK Government AI regulation framework: https://www.gov.uk/government/publications/ai-regulation-a-pro-innovation-approach
