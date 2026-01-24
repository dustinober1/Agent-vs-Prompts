# Chapter 13 — Single-agent patterns: ReAct, Reflexion, tree search

## Purpose
Provide a toolbox of patterns and when to use them.

## Reader takeaway
Single-agent patterns can increase quality when bounded by evaluators; uncontrolled reflection loops waste budget and add risk.

## Key points
- ReAct loops (reasoning + tool use)
- Reflexion with guardrails
- Branching/tree search: generate → score → select
- Sampling/self-consistency: when it helps vs when it wastes money

## Draft

### The outline that almost shipped

The agent had a clear task: draft an executive summary of Q3 security incidents for the board. It searched internal logs, extracted the key incidents, and produced a crisp two-page outline. The outline looked professional. The structure was logical. The citations were formatted correctly.

One problem: the outline buried the most severe incident—a data exposure affecting 50,000 customer records—in a bullet point under "Other Items." It led with a phishing campaign that affected three employees.

When the security team caught it, they were puzzled. "Why would it lead with the small incident?"

The agent hadn't done anything wrong. It processed incidents in the order they appeared in the query results. The phishing campaign was logged first because it happened earlier in the quarter. The agent didn't evaluate whether the outline made sense for the audience—it just produced *an* outline and delivered it.

Now imagine a different approach: generate three outlines with different organizational principles (by severity, by timeline, by remediation status), score each against explicit criteria (executive audience, severity prominence, action-item clarity), and select the highest-scoring version. The data exposure would have been the lead in at least the severity-based version, and the evaluator would have flagged that as the strongest draft.

This is the difference between single-pass generation and **deliberate generation with evaluation**. The first approach produces output. The second produces *good* output.

### Why single-pass fails at scale

Throughout Parts I–III, we built up the case that prompts alone can't enforce constraints, tools provide grounding, and verification catches errors. But even with all those pieces, there's a fundamental problem: **a single generation is a sample from a distribution, not a guaranteed best answer.**

Language models are probabilistic. Given the same input, they produce different outputs with different token sequences. Sometimes the first sample is excellent. Sometimes it's mediocre. You don't know which you got until you evaluate it.

Three consequences:

#### High variance on important decisions

When the agent generates a plan, an outline, or a draft, it's making many small decisions: what to emphasize, how to structure, which sources to cite first. Each decision could reasonably go multiple ways. Multiply those decisions together, and the final output has substantial variance.

For low-stakes tasks, variance doesn't matter. For board-level summaries, training curricula, or policy briefs, variance can mean missing the point entirely.

#### No opportunity for comparison

If you only generate one option, you can't compare it to alternatives. You're stuck asking "is this good?" rather than "is this better than the alternatives?"

Comparison is a more tractable problem. People (and models) are better at ranking options than rating them in isolation. By generating multiple candidates, you transform an absolute judgment into a relative one.

#### Self-evaluation is weak without contrast

As Chapter 12 established, models struggle to evaluate their own work objectively. But when you give a model two options and ask "which better satisfies these criteria?", it has an easier job. The contrast makes differences visible.

### ReAct: reasoning with tools in the loop

The first pattern addresses the problem of reasoning and action being separated.

**The pattern:** Interleave reasoning traces ("I should search for the incident log") with tool actions (actually calling the search tool) within a single generation. The model thinks, acts, observes the result, and thinks again before acting further.

This is the ReAct pattern, introduced by Yao et al. (2022). The name comes from "Reasoning + Acting."

#### How it works

```
Thought: I need to find the Q3 security incidents. Let me search the incident log.
Action: search_incidents(quarter="Q3", year="2025")
Observation: [3 incidents found: INC-001 phishing, INC-002 data exposure, INC-003 malware]
Thought: INC-002 is a data exposure affecting 50,000 records. This is the most severe. 
         I should get details on this one first.
Action: get_incident_details(incident_id="INC-002")
Observation: [Details: breach discovered Oct 15, remediated Oct 18, 50,000 customer records exposed...]
Thought: This needs to be the lead item in my summary. Now let me get details on the others...
```

The key insight: **reasoning traces make the agent's decisions visible and auditable**, while tool actions ground those decisions in real data.

#### When to use ReAct

ReAct shines when:
- The task requires dynamic information gathering (you don't know what to retrieve until you start)
- Tool calls should be informed by intermediate reasoning
- You need an audit trail of *why* the agent did what it did

ReAct struggles when:
- The task is straightforward retrieval followed by synthesis (overkill)
- Tool calls are expensive and you want to batch them (ReAct tends to call tools one at a time)
- The reasoning traces add latency without improving outcomes

#### Implementation guardrails

ReAct loops can spiral. The model keeps "thinking" and calling tools without making progress. Protect yourself:

| Guardrail | Implementation |
|---|---|
| Max reasoning steps | Cap at N thought/action cycles |
| Repetition detection | Detect repeated tool calls with same arguments |
| Progress checks | Require advancing toward goal, not just "exploring" |
| Budget enforcement | Track tool calls against budget from Chapter 7 |

### Reflexion: bounded learning from errors

The second pattern addresses what happens when the first attempt fails.

**The pattern:** When an attempt fails evaluation, generate a reflection on *why* it failed, then use that reflection to inform the next attempt. Repeat until success or budget exhaustion.

This is the Reflexion pattern, introduced by Shinn et al. (2023). It's "verbal reinforcement learning"—the agent learns from its mistakes within a single task, using natural language rather than gradient updates.

#### How it works

```yaml
attempt_1:
  output: [outline with data exposure buried]
  evaluation:
    severity_prominence: 2/10
    feedback: "Most severe incident not prominently featured"
  
reflection:
  what_went_wrong: "I organized by chronological order, not severity"
  what_to_try_next: "Lead with the highest-severity incident regardless of timing"

attempt_2:
  output: [outline leading with data exposure]
  evaluation:
    severity_prominence: 9/10
    feedback: "Severity order correct"
  
result: attempt_2 selected
```

The reflection is the critical piece. Without it, the agent just generates another sample and hopes for better luck. With reflection, it *reasons about the failure* and adjusts its approach.

#### When to use Reflexion

Reflexion shines when:
- Failures are informative (you can diagnose what went wrong)
- The task allows multiple attempts within acceptable latency
- Evaluation is cheap relative to generation
- The failure modes are correctable (not random noise)

Reflexion struggles when:
- Failures are arbitrary or random (nothing to learn from)
- Latency constraints are tight (no time for retries)
- The agent can't actually diagnose failures (reflection becomes "try harder")
- Attempts are expensive (better to invest in one careful attempt)

#### The critical guardrail: bounded retries

Reflexion without limits is dangerous. The agent can:
- Generate increasingly elaborate "reflections" that don't actually change behavior
- Overcorrect and swing to the opposite failure mode
- Burn budget on a fundamentally impossible task

**Always bound Reflexion:**

```yaml
reflexion_config:
  max_attempts: 3
  required_improvement: true  # must score higher than previous attempt
  reflection_limit: 100 tokens  # force concise diagnosis
  escalate_after: 2 failed attempts  # human review if stuck
```

If attempt N+1 doesn't score better than attempt N, stop. Either the evaluator is broken, the task is too hard, or you've hit diminishing returns.

### Tree search: generate, evaluate, select

The third pattern abandons sequential attempts entirely. Instead: **generate multiple candidates in parallel, evaluate all of them, and select the best.**

This is tree search, popularized by approaches like Tree-of-Thoughts (Yao et al., 2023). It trades compute for quality by exploring multiple paths and keeping the best.

#### How it works

```yaml
generation:
  prompt: "Create an outline for the Q3 security incident executive summary"
  candidates: 3
  variation_instructions:
    - candidate_1: "Organize by severity (most to least serious)"
    - candidate_2: "Organize by timeline (chronological)"
    - candidate_3: "Organize by remediation status (resolved vs open)"

evaluation:
  criteria:
    - name: "Executive audience fit"
      weight: 0.4
    - name: "Severity prominence"
      weight: 0.4
    - name: "Actionability"
      weight: 0.2
  
  scores:
    candidate_1: 8.2
    candidate_2: 5.6
    candidate_3: 7.1

selection:
  winner: candidate_1
  reason: "Highest weighted score; severity-based structure most appropriate for board audience"
```

#### Breadth-first vs. depth-first

Two flavors of tree search:

**Breadth-first (generate many, pick one):**
- Generate N complete candidates
- Score all of them
- Select the best
- Simpler to implement, parallelizable
- Good when candidates are cheap and evaluation is reliable

**Depth-first with backtracking:**
- Generate options at each decision point
- Expand the most promising path
- Backtrack if you hit a dead end
- More complex, harder to parallelize
- Good when early decisions constrain later ones (e.g., choosing a structure commits you to a style)

For most agent work, breadth-first is easier and sufficient. Use depth-first when you need fine-grained control over intermediate decisions.

#### Evaluation is everything

Tree search is only as good as your evaluator. If the evaluator is weak, you're picking randomly from your candidates—expensive random sampling.

Design your evaluator with:

| Criterion | Type | Measurement |
|---|---|---|
| Must-haves | Binary | Missing any critical element? |
| Quality dimensions | Scalar | Score 1-10 on each |
| Comparative | Ranking | Which is better on dimension X? |

For the executive summary:
- **Must-have**: All high-severity incidents mentioned
- **Quality**: Clarity (does the structure guide the reader?), actionability (are next steps clear?)
- **Comparative**: "Which outline presents severity most prominently?"

#### Tie-breaking rules

When candidates score similarly, you need tie-break rules:

1. **Prefer the conservative option**: Less creative, more predictable
2. **Prefer the shorter option**: Conciseness is usually a virtue
3. **Ask for human input**: If genuinely equal, surface both for selection
4. **Random selection**: If all else fails (but log this for debugging)

Explicit tie-break rules prevent the agent from being stuck in indecision.

### Self-consistency: when diversity pays off

A related pattern: generate the same output multiple times and aggregate the results.

**The pattern:** Run the same prompt N times, collect the outputs, and determine the "consensus" answer. Originally proposed for arithmetic and reasoning tasks (Wang et al., 2022), it applies to any task where you can aggregate outputs.

#### How it works for factual questions

```yaml
prompt: "What date was the data exposure incident discovered?"

samples:
  - "October 15, 2025"
  - "October 15, 2025"
  - "October 14, 2025"
  - "October 15, 2025"
  - "October 15, 2025"

consensus: "October 15, 2025" (4/5 agreement)
confidence: 0.80
```

The intuition: random errors don't correlate. If most samples agree, you can trust the consensus more than any single sample.

#### When self-consistency helps

- **Factual extraction**: Dates, names, numbers pulled from documents
- **Classification**: When you're categorizing something ambiguous
- **Simple reasoning**: Multi-step arithmetic, logic puzzles

#### When self-consistency wastes money

- **Creative tasks**: Generating multiple outlines and picking "the consensus outline" doesn't make sense
- **Complex tasks**: Long-form generation has too many degrees of freedom for meaningful consensus
- **Cheap verification**: If you can verify correctness directly, verifying is cheaper than sampling

Self-consistency is most valuable when you *can't* easily verify correctness but *can* recognize agreement.

### The cost equation

All three patterns cost more than single-pass generation. Is it worth it?

**ReAct cost:**
- More LLM calls (reasoning traces between tool calls)
- More latency (sequential by nature)
- More tool calls (potentially)

**Reflexion cost:**
- Multiple full generations (attempts)
- Multiple evaluations
- Latency multiplied by attempts

**Tree search cost:**
- N generations (candidates)
- N or 1 evaluations (depending on approach)
- Parallelizable, so latency may not multiply

**Self-consistency cost:**
- N generations (for N samples)
- Aggregation (cheap)
- Parallelizable

**Decision framework:**

| Pattern | Use when | Avoid when |
|---|---|---|
| ReAct | Dynamic tasks, audit trails, complex reasoning | Simple retrieval, tight latency |
| Reflexion | Learnable failures, sufficient retry budget | Random failures, tight latency, expensive attempts |
| Tree search | High stakes, reliable evaluator, parallelizable | Low stakes, weak evaluator, extreme cost pressure |
| Self-consistency | Factual extraction, consensus-friendly tasks | Creative tasks, verifiable tasks |

For many production tasks, **tree search with 3 candidates** is the sweet spot: enough diversity to catch bad samples, not so much that you're burning money.

## Case study thread

### Research+Write (Policy change brief)

The brief writer uses tree search to generate high-quality outlines grounded in sources.

#### The "generate 3 → evaluate → pick 1" workflow

**Step 1: Generate 3 outline candidates**

Each candidate uses a different organizational principle:

```yaml
candidates:
  - name: "structure_by_impact"
    instruction: "Organize by business impact: highest-impact changes first"
    
  - name: "structure_by_department"
    instruction: "Organize by department affected: each major section is a department"
    
  - name: "structure_by_timeline"
    instruction: "Organize by effective date: what changes now, what changes later"
```

**Step 2: Evaluate each candidate**

The evaluator scores on three dimensions:

| Criterion | Weight | Measurement |
|---|---|---|
| Coverage | 0.4 | Are all policy changes mentioned? (binary per change, averaged) |
| Citation feasibility | 0.3 | Can each claim be grounded in a retrievable source? (check against available docs) |
| Audience fit | 0.3 | Does the structure serve the stated audience? (heuristic + rubric) |

```yaml
evaluation_results:
  structure_by_impact:
    coverage: 1.0  # all changes mentioned
    citation_feasibility: 0.9  # one claim may need SME input
    audience_fit: 0.85
    weighted_score: 0.92
    
  structure_by_department:
    coverage: 0.8  # missed one cross-cutting change
    citation_feasibility: 1.0
    audience_fit: 0.7  # less clear for executive audience
    weighted_score: 0.82
    
  structure_by_timeline:
    coverage: 1.0
    citation_feasibility: 0.9
    audience_fit: 0.6  # timeline less useful for decision-makers
    weighted_score: 0.81
```

**Step 3: Select and proceed**

```yaml
selection:
  winner: "structure_by_impact"
  reason: "Highest weighted score; impact-based structure most appropriate for executive audience"
  
next_step: "Draft brief using selected outline"
```

#### Fallback behavior

If all candidates score below a threshold (e.g., coverage < 0.8), escalate rather than proceeding:

```yaml
escalation:
  trigger: "All candidates below threshold"
  action: "Ask user to clarify scope or provide missing policy documents"
  message: "I generated three outlines, but none achieve good coverage. 
           The following changes may be missing from available sources: [LIST]"
```

### Instructional Design (Annual compliance training)

The training designer uses tree search to generate aligned module flows.

#### The "generate 3 → evaluate → pick 1" workflow

**Step 1: Generate 3 module flow candidates**

Each candidate uses a different pedagogical approach:

```yaml
candidates:
  - name: "scenario_first"
    instruction: "Lead each section with a realistic scenario, then teach the principle"
    
  - name: "principle_first"
    instruction: "State the policy/rule first, then provide examples and practice"
    
  - name: "assessment_driven"
    instruction: "Backward-design: start from what learners must demonstrate, build toward it"
```

**Step 2: Evaluate each candidate**

| Criterion | Weight | Measurement |
|---|---|---|
| Alignment | 0.4 | Every objective has practice + assessment? (alignment rubric from Ch 12) |
| Time fit | 0.3 | Total time within target duration? (time estimator tool) |
| Accessibility risk | 0.3 | Any flagged accessibility issues? (accessibility checker tool) |

```yaml
evaluation_results:
  scenario_first:
    alignment: 1.0
    time_fit: 0.8  # slightly over target duration
    accessibility_risk: 0.9  # scenarios need alt-text for images
    weighted_score: 0.89
    
  principle_first:
    alignment: 0.9  # one objective missing practice activity
    time_fit: 1.0  # within target
    accessibility_risk: 1.0
    weighted_score: 0.93
    
  assessment_driven:
    alignment: 1.0
    time_fit: 0.7  # over target duration
    accessibility_risk: 0.95
    weighted_score: 0.86
```

**Step 3: Select and proceed**

```yaml
selection:
  winner: "principle_first"
  reason: "Highest weighted score; within time target, minimal accessibility risk"
  
remediation:
  action: "Add practice activity for objective OBJ-003 before proceeding"
  
next_step: "Generate activities and assessments using selected flow"
```

#### Combining patterns

For complex modules, combine patterns:

1. **Tree search** for module flow selection (generate 3 → pick 1)
2. **ReAct** for content development (interleave reasoning with policy lookups)
3. **Reflexion** for assessment quality (if alignment check fails, reflect and revise)

The patterns compose. Use the right pattern for each sub-task.

## Artifacts to produce

- A bounded "generate 3 → evaluate → pick 1" workflow spec for each case study
- Evaluator scoring rubrics (criteria, weights, thresholds)
- Tie-break rules document
- Pattern selection decision tree

## Chapter exercise

Implement a "generate 3 → evaluate → pick 1" workflow for either 3 Research+Write outlines or 3 Instructional Design lesson flows.

### Part 1: Define your candidates

Specify 3 candidate variations:
- What organizational principle or approach does each use?
- What instructions would you give to generate each?

### Part 2: Define your evaluator

For each criterion:
- What is the criterion name?
- What is its weight?
- How is it measured (tool, rubric, heuristic)?
- What's the minimum acceptable score?

### Part 3: Define your selection rules

- How do you pick the winner?
- What are your tie-break rules?
- Under what conditions do you escalate instead of selecting?

### Part 4: Implement (optional)

If you have access to an LLM API:
1. Generate 3 candidates for a sample request
2. Score each using your evaluator
3. Select and explain the choice
4. Reflect: Did the evaluator pick what you would have picked?

## Notes / references

- ReAct (reasoning + acting): Yao et al., "ReAct: Synergizing Reasoning and Acting in Language Models" (2022) — https://arxiv.org/abs/2210.03629
- Reflexion (verbal reinforcement learning): Shinn et al., "Reflexion: Language Agents with Verbal Reinforcement Learning" (2023) — https://arxiv.org/abs/2303.11366
- Tree-of-Thoughts (deliberate problem solving): Yao et al., "Tree of Thoughts: Deliberate Problem Solving with Large Language Models" (2023) — https://arxiv.org/abs/2305.10601
- Self-Consistency (chain-of-thought sampling): Wang et al., "Self-Consistency Improves Chain of Thought Reasoning in Language Models" (2022) — https://arxiv.org/abs/2203.11171
- Graph of Thoughts (extending tree search): Besta et al., "Graph of Thoughts: Solving Elaborate Problems with Large Language Models" (2023) — https://arxiv.org/abs/2308.09687

