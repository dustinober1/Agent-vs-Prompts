# Chapter 22 — Where agentic systems are going next

## Purpose
Close with a realistic future-facing view.

## Reader takeaway
Expect better tool use and stronger evaluation norms; the hard parts remain intent alignment, security, and long-horizon reliability.

## Key points
- Trends: better tool reasoning, multimodal agents, private execution, standardized evals, regulation/audit defaults
- What stays hard: intent alignment, long-horizon reliability, security, grounding in messy data
- Closing framework: tools + contracts, evals + observability, security + governance

## Draft

### The deployment that changed everything (and nothing)

Six months after deploying their first production agent, the team gathered for a retrospective. The brief-writing agent they'd built—following the patterns in this book—was processing hundreds of requests daily. Citations resolved. Outputs passed quality gates. Users stopped complaining about hallucinated sources.

"So we're done?" the product manager asked.

The senior engineer laughed. "We just got started."

She pulled up the roadmap: multimodal inputs, because users wanted to attach screenshots. Private execution, because the legal team was nervous about cloud-based inference. Stronger evals, because "passes our tests" wasn't good enough when the stakes increased. Compliance documentation, because auditors were asking questions no one had thought to answer.

The agent worked. But working agents create new demands—and the landscape around them keeps shifting.

This chapter maps where agentic systems are headed: five trends shaping the next several years, four challenges that remain stubbornly hard, and a framework for prioritizing your own continued learning.

### Trend 1: Better tool use and structured control

The most immediate improvements in agentic systems come from the models themselves getting better at tool use. Early agents struggled to select the right tool, format calls correctly, and interpret results reliably. That's changing.

**What's improving:**

```yaml
tool_use_evolution:
  2023_baseline:
    selection: "Frequent wrong tool selection, especially with > 5 tools"
    formatting: "JSON schema violations common"
    error_handling: "Agent often ignored tool errors or hallucinated responses"
    
  2024_improvements:
    selection: "Reliable selection across 10-20 tools with clear descriptions"
    formatting: "Constrained decoding and function-calling APIs reduce errors"
    error_handling: "Models increasingly recognize and respond to tool failures"
    
  emerging_patterns:
    structured_outputs: "Schema-validated JSON generation with guaranteed compliance"
    parallel_calls: "Multiple tool calls in single turn when dependencies allow"
    tool_learning: "Few-shot tool usage from documentation + examples"
```

**Why it matters:**

Better native tool use reduces the scaffolding you need. Where early agents required extensive prompt engineering to format calls correctly and retry failures, newer models handle more of this automatically. The orchestration layer becomes thinner—but doesn't disappear.

**What you should do:**

- Re-evaluate your tool surface area. As models improve, you may be able to expose more granular tools without overwhelming the agent.
- Invest in tool documentation. Models increasingly learn tool usage from descriptions; better docs mean better selection.
- Test structured output modes. Constrained decoding (where available) can eliminate entire classes of formatting bugs.

### Trend 2: Multimodal agents

Agents are gaining eyes, ears, and voices. Multimodal capabilities—processing images, documents, audio, and video alongside text—unlock new categories of agentic work.

**Current state:**

```yaml
multimodal_capabilities_2024:
  vision:
    status: "Production-ready for many use cases"
    examples:
      - "Screenshot understanding for UI automation"
      - "Document parsing (invoices, forms, charts)"
      - "Image-based quality control in manufacturing"
    limitations:
      - "Precise spatial reasoning still inconsistent"
      - "Small text and dense layouts challenging"
      - "Hallucination of visual details remains a risk"
      
  audio:
    status: "Improving rapidly"
    examples:
      - "Voice-to-action for conversational agents"
      - "Meeting transcription with speaker identification"
      - "Audio analysis for customer service QA"
    limitations:
      - "Accent and noise handling varies"
      - "Real-time processing adds latency constraints"
      
  video:
    status: "Emerging"
    examples:
      - "Video summarization and key moment extraction"
      - "Instruction videos to step-by-step procedures"
    limitations:
      - "Long videos exceed context limits"
      - "Temporal reasoning still weak"
```

Nearly 65% of enterprises are testing or deploying multimodal AI solutions as of late 2024, with the global multimodal AI market projected to grow from $12.5 billion in 2024 to $65 billion by 2030. The capability is moving fast.

**Case study implication (Research+Write):**

The brief-writing agent could accept screenshot attachments—policy documents, regulatory tables, competitor product pages—and extract structured information directly. Instead of requiring users to copy-paste text, the agent understands the source in its native format.

**Case study implication (Instructional Design):**

The training agent could analyze existing course materials (slides, videos, PDFs) and suggest improvements, identify accessibility gaps, or generate alternative formats. Multimodal understanding turns it from a generator into an analyst.

### Trend 3: On-device and private execution

Not all inference should happen in the cloud. Privacy requirements, latency constraints, and cost pressures are driving a shift toward on-device and private execution.

**What's happening:**

```yaml
private_execution_landscape:
  on_device_models:
    apple_intelligence:
      description: "3-billion-parameter on-device model with 2-bit quantization"
      capabilities:
        - "Writing assistance (rewrite, summarize, proofread)"
        - "Notification summarization"
        - "Enhanced Siri natural language understanding"
      hybrid_approach: "Private Cloud Compute for complex tasks, no data retained"
      reach: "Available on 1+ billion devices (iOS 18.1+, macOS Sequoia 15.1+)"
      
    open_source_small_models:
      examples: ["Phi-3", "Gemma 2", "Llama 3.2", "Mistral 7B"]
      use_cases:
        - "Edge inference for latency-critical applications"
        - "Air-gapped environments (defense, healthcare)"
        - "Cost reduction for high-volume, simple tasks"
        
  frameworks:
    mlx:
      description: "Apple's framework for efficient ML on Apple silicon"
      features:
        - "Unified memory CPU/GPU execution"
        - "PyTorch-like API for developer familiarity"
        - "Fine-tuning and inference on consumer hardware"
        
    inference_engines:
      examples: ["llama.cpp", "vLLM", "text-generation-inference"]
      pattern: "Run capable models on modest hardware with quantization"
```

**Why it matters for agents:**

On-device execution changes the trust model. Sensitive tools (reading local files, accessing personal data) become safer when the model runs locally. Latency-sensitive interactions (real-time assistants, coding copilots) benefit from eliminating network round trips.

**What you should do:**

- Identify which agent steps can run on smaller models. Tool selection, simple formatting, and classification often don't need frontier-scale models.
- Build hybrid architectures. Local models handle latency-critical preliminary steps; cloud models handle complex reasoning.
- Watch the model-routing space. Automated routing between models (by cost, capability, or privacy requirements) is maturing.

### Trend 4: Standardized evals and benchmarks

The evaluation landscape is professionalizing. Ad-hoc "vibes-based" assessment is giving way to standardized benchmarks, reproducible pipelines, and public leaderboards.

**Current benchmarks:**

```yaml
agent_evaluation_benchmarks_2024:
  swe_bench:
    purpose: "Real-world software engineering tasks from GitHub issues"
    variants:
      full: "Original 2294 tasks, challenging and noisy"
      lite: "300 tasks, reduced evaluation cost"
      verified: "500 human-validated solvable tasks (August 2024)"
      multimodal: "Tasks with visual elements (October 2024)"
    significance: "De facto standard for coding agents"
    
  webarena:
    purpose: "Realistic web environment tasks requiring multi-step planning"
    scale: "812 tasks, median 13.2 hours per full run"
    progress: "From ~14% success (2023) to >60% with planners + memory (2025)"
    extensions:
      st_webarena: "Safety and trust templates for enterprise readiness"
      workarena: "682 knowledge work and business-oriented tasks"
      
  lmsys_chatbot_arena:
    purpose: "Human pairwise preference comparison"
    scale: "91+ models, 800,000+ human comparisons (as of April 2024)"
    method: "Elo-like ranking from blind A/B votes"
    limitation: "Measures preference, not task completion"
```

**Why standardization matters:**

Benchmarks create shared baselines. When everyone measures on the same tasks, you can compare approaches, track progress over time, and identify genuine advances vs. noise. For agent developers, benchmarks also reveal gaps: if your system fails SWE-bench problems differently than other systems, you learn something specific.

**What you should do:**

- Use public benchmarks for sanity checks. Even if your domain is specialized, testing on standard benchmarks reveals baseline capability.
- Build your own golden sets. Public benchmarks don't cover your business logic—you still need domain-specific evals.
- Watch for benchmark saturation. When models approach 100% on a benchmark, it stops being informative. Stay current on new benchmarks that challenge frontier capabilities.

### Trend 5: Regulation and compliance as defaults

Regulation is arriving. The EU AI Act, which entered force in August 2024, is the most comprehensive example, but it won't be the last. Agents that operate in regulated domains—hiring, lending, healthcare, education—face increasing compliance requirements.

**EU AI Act timeline:**

```yaml
eu_ai_act_timeline:
  august_2024:
    event: "Act enters into force"
    
  february_2025:
    requirements:
      - "Prohibited AI practices enforceable"
      - "AI literacy requirements for staff mandatory"
      
  august_2025:
    requirements:
      - "General-Purpose AI (GPAI) transparency obligations"
      - "Documentation requirements for foundation models"
      
  august_2026:
    requirements:
      - "High-risk AI system requirements fully enforceable"
      - "Conformity assessments required before market placement"
      - "Continuous risk management and documentation"
      
  august_2027:
    requirements:
      - "Extended transition for high-risk AI in regulated products"
```

**What this means for agents:**

```yaml
compliance_implications:
  high_risk_classification:
    examples:
      - "AI in employment (screening, evaluation)"
      - "AI in education (assessment, admissions)"
      - "AI affecting access to essential services"
    requirements:
      - "Conformity assessments before deployment"
      - "Continuous risk management documentation"
      - "Human oversight mechanisms"
      - "Technical documentation auditable over time"
      - "Post-market monitoring"
      
  transparency_requirements:
    - "Users must know they're interacting with AI"
    - "AI-generated content must be disclosable"
    - "Decision explanations for consequential outputs"
    
  audit_readiness:
    - "Maintain registry of all AI systems and risk classifications"
    - "Versioned documentation of model behavior and changes"
    - "Logs sufficient to reconstruct system behavior"
```

**What you should do:**

- Build compliance into the architecture, not as an afterthought. The observability and documentation practices from Chapters 17-19 position you well.
- Classify your agents by risk level now. Don't wait for enforcement deadlines to discover you're operating high-risk systems.
- Create audit trails that persist. Logs, traces, and evaluation results should be retained long enough to satisfy regulatory review periods.

### What stays hard

Not everything improves with better models and clearer regulations. Some challenges are structural and will persist even as capabilities advance.

#### Intent alignment

The gap between what users say and what they mean remains the hardest problem in agentic systems.

```yaml
intent_alignment_challenges:
  ambiguity:
    example: "'Make it better' provides no actionable direction"
    pattern: "Underspecified goals lead to unsatisfying outputs"
    
  implicit_constraints:
    example: "User assumes 'write a report' means 'in our house style with our data sources'"
    pattern: "Shared context isn't shared with the agent"
    
  changing_intent:
    example: "User realizes what they wanted after seeing the wrong output"
    pattern: "Intent clarifies through iteration, but early steps are wasted"
    
  conflicting_stakeholders:
    example: "Requestor wants bold claims; compliance wants conservative language"
    pattern: "The 'right' output depends on whose intent you optimize for"
```

Better models don't solve this. They might ask better clarifying questions, but the fundamental problem—humans don't fully know what they want until they see it—is human, not computational.

#### Long-horizon reliability

The longer an agent runs, the more errors compound.

```yaml
long_horizon_challenges:
  error_accumulation:
    pattern: "Each step has some error rate; over N steps, errors multiply"
    example: "95% accuracy per step → ~60% accuracy after 10 steps"
    
  context_degradation:
    pattern: "Important early context gets lost in long sessions"
    example: "Agent forgets constraints stated at the beginning"
    
  state_drift:
    pattern: "Agent's model of the environment diverges from reality"
    example: "Agent assumes file still exists after external deletion"
    
  recovery_difficulty:
    pattern: "Deep into a workflow, recovery from errors is expensive"
    example: "Realizing step 3 was wrong after completing step 8"
```

Gartner predicts that by 2028, agentic AI will autonomously make 15% of daily work decisions—up from essentially none in 2024. This projection depends on solving (or working around) long-horizon reliability. We're not there yet.

#### Security against adaptive attacks

Prompt injection and related attacks evolve faster than defenses.

```yaml
security_challenges:
  indirect_injection:
    pattern: "Malicious instructions embedded in retrieved content"
    example: "Web page contains hidden text: 'Ignore previous instructions...'"
    defense_status: "Partial: input sanitization helps, but no complete solution"
    
  adaptive_adversaries:
    pattern: "Attackers learn from defenses and adjust"
    example: "New jailbreaks appear within days of patches"
    defense_status: "Ongoing arms race; layered defenses required"
    
  tool_chain_escalation:
    pattern: "Benign tool access used to gain unauthorized capabilities"
    example: "Code execution tool used to exfiltrate data"
    defense_status: "Sandbox and permission models help, but not foolproof"
    
  trust_boundary_confusion:
    pattern: "Agent trusts content it shouldn't"
    example: "Treating user-uploaded document as authoritative instructions"
    defense_status: "Architectural separation required; model-level filtering insufficient"
```

The security chapter (Chapter 19) covered current best practices, but those practices are defensive. Attackers have structural advantages: they only need to find one way in, defenders must close them all.

#### Grounding in messy real-world data

Real data is inconsistent, incomplete, contradictory, and often wrong.

```yaml
grounding_challenges:
  data_quality:
    pattern: "Source data contains errors the agent can't detect"
    example: "Internal wiki has outdated policy that contradicts current practice"
    
  version_conflicts:
    pattern: "Multiple sources give different answers"
    example: "Three policy documents, three different approval thresholds"
    
  implicit_knowledge:
    pattern: "Correct behavior requires unstated context"
    example: "'Ask Legal' means ask the general counsel, not the contracts team"
    
  freshness_decay:
    pattern: "Information goes stale faster than it's updated"
    example: "Pricing doc reflects last quarter's rates"
```

Better retrieval helps—but retrieval assumes the right information exists and is findable. For many real-world tasks, it doesn't.

### A framework for continued learning

As the landscape evolves, where should you focus your learning?

```yaml
learning_priorities:
  tier_1_foundation:
    focus: "Tools + Contracts"
    why: "Every agent improvement depends on reliable tool integration"
    skills:
      - "API design and schema definition"
      - "Error handling and retry patterns"
      - "Tool security and permission models"
    indicator: "You can add a new tool to an agent without breaking existing behavior"
    
  tier_2_essential:
    focus: "Evals + Observability"
    why: "You can't improve what you can't measure"
    skills:
      - "Golden set design and maintenance"
      - "Automated regression detection"
      - "Trace-based debugging"
      - "Cost and latency attribution"
    indicator: "You know within an hour when a change degrades quality"
    
  tier_3_scaling:
    focus: "Security + Governance"
    why: "Stakes increase as agents do more"
    skills:
      - "Threat modeling for AI systems"
      - "Prompt injection defense patterns"
      - "Compliance documentation"
      - "Audit trail design"
    indicator: "You can explain your agent's security posture to an auditor"
```

The pattern: start with the mechanics (tools), add the feedback loops (evals), layer on the constraints (security). Each level depends on the ones below.

### The closing argument

This book began with a provocation: prompts, by themselves, don't scale.

We've covered what does: tools that extend capability, retrieval that grounds in facts, planning that survives contact with reality, memory that persists appropriately, verification that catches errors before users do.

We've explored patterns: single-agent loops, multi-agent coordination, orchestration that turns agents into software.

We've addressed operations: reliability engineering, observability, security, cost control.

And we've considered the human side: teams, roles, the end of the "prompt engineer" job description.

What remains is to keep building.

The systems you ship today will need to evolve. Models will improve—and break your assumptions. Regulations will tighten. Users will demand more. New vulnerabilities will emerge. The standards that seem aspirational now will become table stakes.

But the fundamentals in this book—the shift from prompts to systems, from artisanal tweaking to engineering discipline—will remain relevant.

Build agents that do useful work. Measure whether they actually do it. Keep them secure. Iterate.

That's the job. And it's a good one.

## Case study thread

### Research+Write (Policy change brief)

**What improves over the next 12-18 months:**

```yaml
brief_agent_evolution:
  near_term:
    multimodal_input:
      change: "Accept screenshot attachments of source documents"
      value: "Users stop manually copy-pasting text; faster workflow"
      requirement: "Update tool pipeline to handle image inputs"
      
    better_citation_verification:
      change: "Automated link checking and source freshness validation"
      value: "Reduce stale or broken citation complaints to near-zero"
      requirement: "Add verification tool; integrate with CI/CD"
      
    model_routing:
      change: "Use smaller models for outline generation, frontier model for synthesis"
      value: "Cut costs 30-50% without quality degradation"
      requirement: "Build routing logic; eval across model combinations"
      
  medium_term:
    regulatory_compliance:
      change: "Document generation with audit trails for EU AI Act"
      value: "Legal can demonstrate compliance for high-risk use cases"
      requirement: "Enhanced logging, documentation templates, review workflows"
```

**What stays hard:**

- Policy ambiguity: when the source documents contradict, the agent can't always know which to trust.
- Confidentiality: ensuring internal-only material never leaks into external-facing briefs requires ongoing vigilance.
- Injection resilience: web sources remain a vector for adversarial content.

### Instructional Design (Annual compliance training)

**What improves over the next 12-18 months:**

```yaml
training_agent_evolution:
  near_term:
    multimodal_analysis:
      change: "Analyze existing course materials (slides, videos) for improvement suggestions"
      value: "Faster gap analysis; less manual review"
      requirement: "Integrate vision and audio processing capabilities"
      
    accessibility_automation:
      change: "Auto-generate alt text, captions, and accessibility reports"
      value: "WCAG compliance becomes default, not extra effort"
      requirement: "Enhanced accessibility tooling; integration with LMS export"
      
    alignment_evals:
      change: "Automated rubric for objectives↔assessment alignment"
      value: "Catch misalignment before SME review; faster iteration"
      requirement: "Custom eval pipeline with instructional design criteria"
      
  medium_term:
    learning_outcome_measurement:
      change: "Integration with LMS analytics to correlate training with behavior change"
      value: "Prove training effectiveness, not just completion"
      requirement: "Data pipeline from LMS; privacy-preserving analytics"
```

**What stays hard:**

- Behavior change: knowing whether training actually changed job performance requires data the agent may never have.
- Policy currency: when org policies change, training materials must update—but knowing *when* policies changed is a human coordination problem.
- Cross-functional ownership: training spans L&D, compliance, IT, and subject matter experts; coordination remains human work.

## Artifacts to produce
- A "next bets" roadmap for iterating on the two agents

## Chapter exercise

Write a 1-page roadmap for extending one of the case studies (Research+Write or Instructional Design) over the next 6 months. Your roadmap should cover:

1. **Capabilities**: What new abilities will you add? (e.g., multimodal input, new tools, better routing)

2. **Evals**: What new evaluation criteria will you introduce? How will you know the new capabilities work?

3. **Guardrails**: What new security, compliance, or reliability measures does the expanded capability require?

Use this template:

```yaml
six_month_roadmap:
  agent_name: "[Research+Write or Instructional Design]"
  
  month_1_2:
    capability_focus: "[primary capability addition]"
    eval_additions: "[new tests]"
    guardrail_changes: "[new constraints]"
    success_criteria: "[how you'll know it worked]"
    
  month_3_4:
    capability_focus: "[next capability]"
    eval_additions: "[...]"
    guardrail_changes: "[...]"
    success_criteria: "[...]"
    
  month_5_6:
    capability_focus: "[...]"
    eval_additions: "[...]"
    guardrail_changes: "[...]"
    success_criteria: "[...]"
    
  risks_and_dependencies:
    - "[what could go wrong]"
    - "[what you need from elsewhere]"
```

## Notes / references

- McKinsey research (2024): 62% of organizations experimenting with AI agents, 23% scaling at least one agentic system.
- Gartner prediction: By 2028, agentic AI will autonomously make 15% of daily work decisions (from ~0% in 2024).
- Multimodal AI market: projected growth from $12.5B (2024) to $65B (2030).
- SWE-bench benchmarks: SWE-bench Verified (August 2024) introduced 500 human-validated software engineering tasks.
- WebArena: performance improved from ~14% (2023 baseline) to >60% (2025) with strategic planners and memory modules.
- LMSYS Chatbot Arena: 91+ models, 800,000+ human pairwise comparisons as of April 2024.
- EU AI Act: entered force August 2024; prohibited practices enforced February 2025; high-risk requirements August 2026.
- Apple Intelligence: 3B-parameter on-device model with 2-bit quantization; available on 1B+ devices (October 2024).
- MLX framework: Apple's array framework for efficient ML on Apple silicon with unified memory architecture.

### Recommended learning path

```yaml
continued_learning:
  fundamentals:
    - "API design for AI systems (tool contracts)"
    - "Distributed systems basics (state, retries, queues)"
    - "Evaluation methodology (metrics, sampling, experimental design)"
    
  intermediate:
    - "Observability for ML systems (OpenTelemetry, tracing)"
    - "Security threat modeling for AI"
    - "Cost optimization and model routing"
    
  advanced:
    - "Multi-agent coordination patterns"
    - "Compliance frameworks (EU AI Act, NIST AI RMF)"
    - "Benchmark design and contribution"
    
  resources:
    communities:
      - "LangChain/LangGraph documentation and Discord"
      - "Anthropic and OpenAI developer forums"
      - "LMSYS and SWE-bench GitHub discussions"
    papers:
      - "ReAct (Yao et al., 2022)"
      - "Reflexion (Shinn et al., 2023)"
      - "SWE-bench (Jimenez et al., 2024)"
      - "WebArena (Zhou et al., 2024)"
    practice:
      - "Contribute to open-source agent frameworks"
      - "Build agents for your own workflows, then evaluate rigorously"
      - "Participate in benchmark evaluations and share results"
```

