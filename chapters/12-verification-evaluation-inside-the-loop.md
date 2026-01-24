# Chapter 12 — Verification: evaluation inside the loop

## Purpose
Replace "sounds right" with "passes checks."

## Reader takeaway
Agents become reliable when they can prove constraints (format, factuality, alignment) via checks that live outside the model.

## Key points
- Why self-checks aren't enough
- Verification layers: schema, deterministic checks, cross-validation, second-model critique, human review
- Evaluators: rubric-based, test-case based, property-based

## Draft

### The agent that verified itself

The request seemed straightforward: summarize the changes to the expense policy and list the action items for managers.

The agent searched, retrieved the policy document, drafted the summary, and—being well-designed—ran its own verification step.

"Let me verify this summary is accurate," the agent wrote in its thinking. "I'll compare each claim to the source document." It then produced a verification report: "All claims verified. Summary accurately reflects the policy document. Ready for delivery."

The summary went out to 200 managers.

The policy document the agent retrieved was from 2023. The current policy—updated six months ago—had significantly higher approval thresholds. The agent had compared its summary to the wrong document and verified that the comparison was perfect.

The agent didn't lie. It did exactly what it said: it verified claims against the source it had. The problem was that verification happened inside the same context that contained the error. The agent couldn't verify what it couldn't see.

This is why self-checks fail: **the model can't verify facts it doesn't have access to.**

### Why self-verification fails

Throughout this book, we've built up the argument that prompts can't enforce constraints. "Be accurate" is not accuracy. "Verify your claims" is not verification.

Self-verification is the same trap, just more sophisticated. The model goes through the motions of checking, but it's checking against its own context—which may be incomplete, outdated, or wrong.

Three fundamental problems:

#### Problem 1: No access to ground truth

The model only knows what's in its context window plus its training data. If the correct information wasn't retrieved, the model has nothing to verify against.

Asking the model to verify is like asking someone to proofread a document using only the document itself. They can check for internal consistency, but they can't catch factual errors.

#### Problem 2: Bias toward its own outputs

Models are trained to produce coherent, confident text. When asked to evaluate their own work, they exhibit confirmation bias—they're predisposed to find that the work is good.

This isn't malice. It's the same statistical tendency that made the output plausible in the first place. The model generated text that "sounds right." When asked if it's right, the same patterns fire: "yes, this sounds right."

#### Problem 3: Inability to run deterministic operations

Some verifications require deterministic checks:
- Does this URL resolve?
- Does this date fall on a weekday?
- Does this JSON parse?
- Does this quote appear in this document?

Models can approximate these checks, but they can't reliably execute them. A model might "check" that a citation resolves by reasoning that "this looks like a valid policy URL format." That's not the same as actually fetching the URL.

### The verification principle

Here's the principle that makes agents reliable:

> **Verification must happen outside the model's reasoning process.**

This means:
- Deterministic checks run as code
- Fact checks use retrieved sources
- Compliance checks consult authoritative data
- Human judgment gets routed to humans

The model can participate in verification—interpreting results, deciding what to do next—but the actual checking happens in systems that have access to ground truth.

### The verification stack

Think of verification as a stack, ordered from cheapest/fastest to most expensive/thorough:

```
┌─────────────────────────────────────────────────────────┐
│  Human review      │  Highest cost, highest reliability │
├─────────────────────────────────────────────────────────┤
│  Second-model      │  Different perspective, catches    │
│  critique          │  different failures                │
├─────────────────────────────────────────────────────────┤
│  Tool-based        │  Citation resolution, policy       │
│  verification      │  lookup, freshness checks          │
├─────────────────────────────────────────────────────────┤
│  Cross-validation  │  Multiple sources agree,           │
│                    │  consistency checks                │
├─────────────────────────────────────────────────────────┤
│  Deterministic     │  Schema, dates, math, required     │
│  checks            │  fields, format                    │
├─────────────────────────────────────────────────────────┤
│  Structural        │  Parse success, template match,    │
│  validation        │  section presence                  │
└─────────────────────────────────────────────────────────┘
```

Use lower layers for every request. Add higher layers as stakes increase.

#### Layer 1: Structural validation

Does the output have the right shape?

- JSON/YAML/XML parses successfully
- Required sections are present
- Template structure is followed
- No malformed data types

**Implementation:** Schema validators, parsers, regex checks.

**What it catches:** Broken outputs that downstream systems can't process.

**What it misses:** Content errors. A perfectly structured output with wrong content passes structural validation.

#### Layer 2: Deterministic checks

Are the mechanical facts correct?

- Dates are valid and in expected ranges
- Numbers add up correctly
- Required fields have values
- URLs/IDs match expected patterns

**Implementation:** Code-based validation functions.

**What it catches:** Mechanical errors that the model approximated incorrectly.

**What it misses:** Semantic errors. The date might be valid but still be the wrong date.

#### Layer 3: Cross-validation

Do different parts of the output agree with each other?

- Claims in the summary match claims in the detail
- Cited sources align with claim content
- Totals match the sum of line items
- Objectives match assessments

**Implementation:** Comparison logic, consistency checks.

**What it catches:** Internal contradictions, drift between sections.

**What it misses:** Errors where the whole output is consistently wrong.

#### Layer 4: Tool-based verification

Does the output align with external sources of truth?

- Citations resolve (the documents exist)
- Quotes appear in cited sources
- Policies referenced are current
- Facts match retrieved documents

**Implementation:** Verification tools (Chapter 8's `cite_verify`, `policy_lookup`, etc.).

**What it catches:** Hallucinations, stale data, citation laundering.

**What it misses:** Errors in authoritative sources themselves, nuanced interpretation issues.

#### Layer 5: Second-model critique

Does a different perspective find problems?

- A separate model reviews the output for issues
- Different prompt, potentially different model
- Specifically trained or prompted to find errors

**Implementation:** Critic prompts, adversarial review, error-detection models.

**What it catches:** Subtle errors that pass mechanical checks, tone issues, clarity problems.

**What it misses:** Errors both models would make (shared blind spots), ground-truth issues.

**When to use:** High-stakes outputs where human review isn't feasible for every item. Use sparingly—it's expensive.

#### Layer 6: Human review

Does a knowledgeable person approve it?

- Subject matter expert reviews content
- Policy owner approves interpretation
- Legal/security signs off on sensitive content

**Implementation:** Approval workflows, review queues, sign-off gates.

**What it catches:** Everything, in theory. Humans can apply judgment and context.

**What it misses:** Whatever humans miss under time pressure. Human review is not infallible.

**When to use:** High-stakes decisions, novel situations, regulatory requirements, final sign-off.

### Choosing your verification strategy

Not every output needs every layer. Match the verification depth to the stakes.

**Low stakes (internal draft, brainstorming, first attempt):**
- Structural validation
- Basic deterministic checks
- Maybe cross-validation

**Medium stakes (shared internally, informs decisions):**
- All of the above
- Tool-based verification (citations resolve, sources current)
- Cross-validation with sources

**High stakes (external-facing, compliance-relevant, action-driving):**
- All of the above
- Second-model critique OR
- Human review (or both)

The cost model matters. A verification that takes 5 seconds and costs $0.001 can run on every output. A verification that requires a human queue and 24-hour turnaround should run only when necessary.

### Verifiers vs. evaluators

Two related but different concepts:

**Verifiers** produce binary outcomes: pass or fail.
- Did the output parse? Yes/no
- Does the citation resolve? Yes/no
- Is the policy current? Yes/no

Verifiers are gates. Failure blocks progress.

**Evaluators** produce scores or grades.
- Clarity: 7/10
- Coverage: 85%
- Tone alignment: B+

Evaluators inform decisions but don't necessarily block.

In the agent loop:
- Verifiers decide whether to continue, retry, or escalate
- Evaluators provide signal for improvement and monitoring

Many checks can be framed either way:
- "Does the alignment rubric pass?" → Verifier (binary)
- "What's the alignment score?" → Evaluator (continuous)

For in-loop decisions, verifiers are usually more useful. For offline improvement, evaluators provide richer signal.

### Building verification into the loop

Chapter 7 established the agent loop. The "reflect" step is where verification happens.

```
interpret → plan → act → observe → update → reflect → decide
                                              ↑
                                    verification happens here
```

Here's how verification results drive loop decisions:

**Verification passes → continue or deliver**
```yaml
verification_result:
  checks:
    - name: "schema_valid"
      passed: true
    - name: "citations_resolve"
      passed: true
    - name: "policy_current"
      passed: true
  decision: "deliver"
```

**Verification fails with recoverable error → retry or revise**
```yaml
verification_result:
  checks:
    - name: "schema_valid"
      passed: true
    - name: "citations_resolve"
      passed: false
      details: "2 of 5 citations failed to resolve"
  decision: "revise"
  action: "re-retrieve missing sources, update citations"
  budget_remaining: 2 retries
```

**Verification fails with blocking error → escalate or stop**
```yaml
verification_result:
  checks:
    - name: "policy_current"
      passed: false
      details: "Referenced policy POL-2023-045 superseded by POL-2025-012"
    - name: "redaction_check"
      passed: false
      details: "Confidential content detected"
  decision: "stop"
  reason: "blocking failures require human review"
  escalate_to: "policy_owner"
```

Key principle: **verification results are data that flow back into the loop**, not just pass/fail signals.

### Verification as tools

Chapter 8 established that tools are contracts. Verifiers are tools with specific contracts:

```yaml
tool:
  name: "citation_verify"
  purpose: "Verify that a citation resolves and supports the claim"
  type: "compute"

inputs:
  required:
    - name: "doc_id"
      type: "string"
    - name: "quote"
      type: "string"
    - name: "claim"
      type: "string"

outputs:
  success:
    shape: |
      {
        doc_exists: boolean,
        quote_found: boolean,
        quote_supports_claim: confidence_score,
        verification_status: "passed" | "failed" | "uncertain"
      }
  error:
    types: ["DOC_NOT_FOUND", "FETCH_FAILED", "TIMEOUT"]

behavior:
  deterministic: true (for doc_exists, quote_found)
                 false (for quote_supports_claim - uses judgment)
```

Verification tools follow the same design principles from Chapter 8:
- Narrow scope (one verification per tool)
- Structured outputs (clear pass/fail plus details)
- Composable (can chain multiple verifications)
- Deterministic where possible

### The verification report artifact

Verification results should be stored as artifacts, not just logged.

```yaml
verification_report:
  artifact_id: "draft_v1"
  timestamp: "2025-01-15T10:30:00Z"
  status: "failed"
  
  checks:
    - name: "structural_validation"
      type: "schema"
      status: "passed"
      details: "All required sections present"
      
    - name: "citation_check"
      type: "tool"
      status: "failed"
      details:
        total_citations: 5
        resolved: 3
        failed: 2
        failed_citations:
          - id: "cite_003"
            doc_id: "POL-2023-045"
            error: "DOC_SUPERSEDED"
          - id: "cite_005"
            doc_id: "SOP-2024-012"
            error: "DOC_NOT_FOUND"
            
    - name: "redaction_check"
      type: "deterministic"
      status: "passed"
      details: "No confidential patterns detected"
      
    - name: "freshness_check"
      type: "tool"
      status: "warning"
      details: "1 source older than 6 months (still valid)"
  
  decision: "revise"
  next_action: "re-retrieve failed citations, update draft"
  retry_budget_remaining: 2
```

This artifact enables:
- **Debugging**: What failed and why?
- **Audit**: What was checked before delivery?
- **Improvement**: Which checks fail most often?

### Stop-ship thresholds

Some verification failures should block delivery absolutely. Define your stop-ship criteria:

**Research+Write stop-ship failures:**
- Any key claim with no supporting citation
- Any citation that doesn't resolve
- Redaction check failure (confidential content detected)
- Policy referenced is superseded (wrong version)

**Instructional Design stop-ship failures:**
- Any objective without assessment coverage (alignment gap)
- Policy reference to wrong version
- Accessibility check failure
- Missing required approval

Stop-ship failures don't retry. They escalate to humans or block entirely. The agent cannot fix them autonomously.

## Case study thread

### Research+Write (Policy change brief)

The policy brief has specific verification requirements tied to its purpose: accurate, citable, current, confidential-appropriate.

#### Verification suite

| Check | Type | Layer | Stop-ship? |
|---|---|---|---|
| Brief parses (valid markdown) | Structural | 1 | No (retry) |
| Required sections present | Structural | 1 | No (retry) |
| All citations resolve | Tool | 4 | Yes |
| Quotes appear in cited docs | Tool | 4 | Yes |
| Policy versions are current | Tool | 4 | Yes |
| Redaction check passes | Deterministic | 2 | Yes |
| Claims map to sources | Cross-validation | 3 | Yes (for key claims) |
| Tone appropriate for audience | Evaluator | 5 | No (score only) |

#### Verification flow

```yaml
verification_steps:
  - step: 1
    name: "structural"
    checks: ["markdown_valid", "sections_present"]
    on_fail: "retry draft generation"
    
  - step: 2
    name: "citation_resolution"
    checks: ["citations_resolve", "quotes_found"]
    on_fail: "identify failed citations, re-retrieve or mark gaps"
    
  - step: 3
    name: "freshness"
    checks: ["policy_versions_current"]
    on_fail: "stop-ship: escalate to policy owner"
    
  - step: 4
    name: "confidentiality"
    checks: ["redaction_check"]
    on_fail: "stop-ship: cannot deliver with confidential content"
    
  - step: 5
    name: "coverage"
    checks: ["claim_source_mapping"]
    on_fail: "flag unsupported claims, revise or mark NEEDS SOURCE"
```

#### Example verification report

```yaml
verification_report:
  brief_id: "brief_2025_001"
  version: "draft_v2"
  
  structural:
    status: "passed"
    
  citation_resolution:
    status: "passed"
    citations_checked: 6
    citations_resolved: 6
    
  freshness:
    status: "passed"
    policies_checked: 2
    all_current: true
    
  confidentiality:
    status: "passed"
    patterns_checked: ["SSN", "internal_only", "confidential"]
    matches: 0
    
  coverage:
    status: "passed"
    key_claims: 8
    claims_with_sources: 8
    coverage_ratio: 1.0
    
  overall: "passed"
  decision: "ready for delivery"
```

### Instructional Design (Annual compliance training)

The training module has verification requirements focused on alignment, accuracy, and accessibility.

#### Verification suite

| Check | Type | Layer | Stop-ship? |
|---|---|---|---|
| Module structure valid | Structural | 1 | No (retry) |
| All objectives measurable | Deterministic | 2 | No (warning) |
| Objective↔assessment alignment | Tool | 4 | Yes |
| Policy references current | Tool | 4 | Yes |
| Accessibility checklist passes | Tool | 4 | Yes |
| Time estimates plausible | Deterministic | 2 | No (warning) |
| Reading level appropriate | Evaluator | 5 | No (score only) |
| Required approvals obtained | Human | 6 | Yes |

#### Verification flow

```yaml
verification_steps:
  - step: 1
    name: "structural"
    checks: ["module_structure_valid", "objectives_present"]
    on_fail: "retry generation"
    
  - step: 2
    name: "alignment"
    tool: "alignment_check"
    checks: ["every_objective_has_practice", "every_objective_has_assessment"]
    on_fail: "stop-ship: generate missing practice/assessment items"
    
  - step: 3
    name: "policy_accuracy"
    checks: ["policy_versions_current", "policy_citations_resolve"]
    on_fail: "stop-ship: escalate to SME for policy clarification"
    
  - step: 4
    name: "accessibility"
    tool: "accessibility_check"
    checks: ["captions_present", "alt_text_present", "contrast_ok", "reading_level_ok"]
    on_fail: "remediate specific failures, re-check"
    
  - step: 5
    name: "approvals"
    checks: ["security_approved", "legal_approved", "sme_approved"]
    on_fail: "stop-ship: cannot publish without required approvals"
```

#### Example alignment verification

```yaml
alignment_check_result:
  module_id: "compliance_2025_all_employees"
  
  objectives:
    - id: "obj_001"
      text: "Recognize phishing attempts in email"
      has_practice: true
      practice_ids: ["scenario_001", "scenario_002"]
      has_assessment: true
      assessment_ids: ["item_001", "item_002", "item_003"]
      status: "aligned"
      
    - id: "obj_002"
      text: "Report suspicious emails using proper procedure"
      has_practice: true
      practice_ids: ["scenario_003"]
      has_assessment: false
      assessment_ids: []
      status: "gap"
      gap_type: "missing_assessment"
      
  summary:
    total_objectives: 5
    fully_aligned: 4
    gaps: 1
    status: "failed"
    
  decision: "revise"
  action: "generate assessment item for obj_002"
```

## Artifacts to produce

- A **verification stack** for each case study (which layers, which checks)
- A **verification suite specification** (check name, type, stop-ship status)
- A **verification report schema** (what gets logged and stored)
- **Stop-ship criteria** (which failures block delivery absolutely)

## Chapter exercise

### Part 1: Design your verification stack

For each case study, identify:

1. What structural checks are needed? (schema, sections, format)
2. What deterministic checks are needed? (dates, math, required fields)
3. What tool-based verification is needed? (citation resolution, policy lookup)
4. When is human review required?

### Part 2: Define stop-ship criteria

For each case study, list:

1. Which failures should stop delivery absolutely?
2. Which failures can be retried within the loop?
3. Which failures produce warnings but allow delivery?
4. How many retries are allowed before escalation?

### Part 3: Build a verification report

Design the verification report artifact for one case study:

1. What fields does it contain?
2. What status values are possible?
3. How does verification status drive loop decisions?
4. What gets logged for audit purposes?

## Notes / references

- LLM self-correction limits: https://arxiv.org/abs/2310.01798
- Constitutional AI (critique patterns): https://arxiv.org/abs/2212.08073
- Self-RAG (verification in retrieval): https://arxiv.org/abs/2310.11511
- CRITIC (tool-based verification): https://arxiv.org/abs/2305.11738
- LLM-as-judge patterns: https://arxiv.org/abs/2306.05685
- Factuality evaluation methods: https://arxiv.org/abs/2311.08401

