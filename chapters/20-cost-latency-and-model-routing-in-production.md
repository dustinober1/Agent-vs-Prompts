# Chapter 20 — Cost, latency, and model routing in production

## Purpose
Keep agentic systems economically viable.

## Reader takeaway
Agent costs are driven by context growth and multi-step loops; control them with routing, caching, and early exits.

## Key points
- Cost drivers: context growth, loops, retrieval/reranking, sampling
- Optimization: compaction, caching, smaller models for substeps, early exit, batching/async
- SLAs: interactive vs background; progressive disclosure

## Draft

### The invoice that stopped the pilot

The product team was thrilled. Their research agent had spent three months in beta, producing policy briefs that users loved. Leadership approved scaling from 50 pilot users to 2,000. The week after launch, the CFO scheduled an emergency meeting.

"Your AI feature cost more in one week than our entire customer support infrastructure costs in a month."

The numbers were stark: $47,000 in API costs for week one. Projected annual run rate: $2.4 million—for a single internal tool.

Engineering pulled the traces. The pattern was clear:
- Average context length had grown from 8K tokens in the pilot to 32K in production
- Users discovered that requesting "comprehensive research" triggered 15 search-then-fetch cycles instead of 5
- The self-revision loop averaged 3.2 iterations, each regenerating the full 2,000-word output
- Peak usage concentrated in the morning, causing retry storms that doubled token consumption

Nothing was broken. The system was working exactly as designed. It was just designed without cost constraints.

Chapter 17 covered reliability—keeping agents running when things go wrong. Chapter 18 covered observability—seeing what agents are doing. Chapter 19 covered security—preventing agents from doing what they shouldn't. This chapter addresses a different kind of failure: agents that work perfectly but cost too much to operate.

### Understanding cost drivers

Agent costs aren't just "API spend." They compound across multiple dimensions in ways that traditional software costs don't.

#### Context growth: the hidden multiplier

Every token in the context window costs money—twice. Once when sent (input tokens) and once in the attention computation that makes generation slower and more expensive.

**The compounding pattern:**

```yaml
context_growth_cascade:
  initial_request:
    system_prompt: 1500 tokens
    user_query: 200 tokens
    total: 1700 tokens
    
  after_research:
    system_prompt: 1500 tokens
    user_query: 200 tokens
    search_results: 3000 tokens
    fetched_documents: 8000 tokens
    extracted_quotes: 2000 tokens
    total: 14700 tokens  # 8.6x growth
    
  after_drafting:
    previous_context: 14700 tokens
    draft_1: 2500 tokens
    self_critique: 500 tokens
    total: 17700 tokens
    
  after_revision:
    previous_context: 17700 tokens
    draft_2: 2600 tokens
    total: 20300 tokens  # 12x original request
```

**Why this matters financially:**

With GPT-4o pricing at approximately $2.50 per million input tokens and $10 per million output tokens (note: pricing changes frequently—always check current rates), the cost difference is dramatic:

- First inference (1,700 input × $2.50/M): $0.004
- After research (14,700 input × $2.50/M): $0.037
- After revision (20,300 input × $2.50/M): $0.051

Each step carries all previous context. A 5-step agent workflow where each step builds on the last doesn't cost 5× the first step—it costs 1 + 2 + 3 + 4 + 5 = 15× in cumulative context processing.

#### Multi-step loops: token multiplication

Agent loops multiply costs because each iteration pays for all previous iterations' context.

**Self-revision cost analysis:**

```yaml
self_revision_cost:
  scenario: "3 revision iterations on a 2000-word brief"
  
  iteration_1:
    context: 15000  # Research + first draft
    output: 2500    # Full regeneration
    cost: $0.062
    
  iteration_2:
    context: 17500  # Previous + critique
    output: 2500
    cost: $0.069
    
  iteration_3:
    context: 20000
    output: 2500
    cost: $0.075
    
  total_revision_cost: $0.206
  
  comparison:
    single_pass_cost: $0.062
    cost_multiplier: 3.3x  # Not 3x because context grows
```

The multiplier exceeds the iteration count because context accumulates. This is why unlimited self-improvement loops are financially dangerous.

#### Retrieval and reranking: external API costs

Agents often combine LLM inference with external services: vector databases, search APIs, embedding models. Each adds cost.

**Full-stack retrieval costs:**

```yaml
retrieval_stack_costs:
  per_query:
    embedding_generation: $0.0001  # Embed the query
    vector_search: $0.0002        # Pinecone/Weaviate query
    reranking: $0.002             # Cohere rerank API
    total_retrieval: $0.0023
    
  for_research_task:
    queries_issued: 8
    documents_retrieved: 40
    documents_after_rerank: 10
    
    retrieval_cost: $0.018
    document_fetching: $0.00       # In-house, but compute cost
    llm_inference: $0.15
    
    total_task_cost: $0.168
    retrieval_percentage: 11%
```

Retrieval is often a small fraction of total cost—but it adds up across volume, and more importantly, retrieval quality determines whether the LLM inference that follows is wasted.

#### Parallel sampling: when N > 1 costs N×

Some agent patterns generate multiple candidates and select the best. Each candidate costs.

```yaml
parallel_sampling_cost:
  scenario: "Generate 3 outline candidates, evaluate, select best"
  
  generation:
    candidates: 3
    tokens_per_candidate: 1000
    generation_cost: $0.03  # 3x single generation
    
  evaluation:
    evaluator_model: "gpt-4o"
    tokens_per_evaluation: 500
    evaluations: 3
    evaluation_cost: $0.015
    
  total: $0.045
  
  vs_single_pass: $0.01
  multiplier: 4.5x
```

Tree search and majority voting multiply this further. A tree of depth 3 with branching factor 3 evaluates 27 leaf nodes—27× the cost of a single path.

### Cost optimization strategies

Cost optimization isn't about spending less—it's about spending efficiently. The goal is maximum value per dollar, not minimum dollars.

#### Strategy 1: Context compaction

Reduce context size without losing essential information.

**Summarization before accumulation:**

Instead of appending full documents to context, summarize them first:

```yaml
context_compaction:
  unoptimized:
    document_1: 3000 tokens (full text)
    document_2: 4000 tokens (full text)
    document_3: 2500 tokens (full text)
    total_context: 9500 tokens
    
  optimized:
    document_1_summary: 300 tokens
    document_2_summary: 400 tokens
    document_3_summary: 250 tokens
    key_quotes: 500 tokens
    total_context: 1450 tokens
    
  savings: 85%
  
  implementation:
    summarization_cost: $0.01 (one-time)
    context_savings_per_step: $0.02
    break_even: after 1 step
```

**Rolling context windows:**

For long conversations or multi-step tasks, maintain a fixed-size context with oldest content summarized or dropped:

```yaml
rolling_context:
  strategy: "sliding_window_with_summary"
  
  window_size: 8000 tokens
  
  when_exceeded:
    - summarize_oldest_turns: 500 tokens
    - keep_system_prompt: always
    - keep_recent_turns: 5
    - keep_key_artifacts: [plan, current_draft]
    
  example:
    before: 12000 tokens (exceeds window)
    after: 7500 tokens
    lost: oldest 3 turns → replaced with 200-token summary
```

**Structured extraction before context inclusion:**

Don't include raw data—extract what matters:

```yaml
structured_extraction:
  raw_document:
    size: 5000 tokens
    content: "Expense policy full text with formatting, headers, metadata..."
    
  extracted_facts:
    size: 300 tokens
    content:
      - approval_thresholds: {tier_1: 500, tier_2: 2500, tier_3: 10000}
      - effective_date: "2025-02-01"
      - key_changes: ["threshold_increase", "new_category"]
      
  for_agent_use: "extracted_facts"
  raw_document: "stored, retrievable on demand"
```

#### Strategy 2: Prompt caching

Major providers now offer prompt caching—storing the processed context prefix to avoid recomputation.

**How prompt caching works:**

When the same prefix appears in multiple requests, the provider can reuse the computed key-value (KV) cache from the first request. Subsequent requests pay only for processing new tokens.

```yaml
prompt_caching:
  providers:
    anthropic:
      feature: "Prompt caching"
      discount: "90% on cached prefix"
      min_cacheable: 1024 tokens
      ttl: "5 minutes"
      
    openai:
      feature: "Cached prompts (automatic)"
      discount: "50% on cached prefix"
      automatic: true  # No explicit API needed
      ttl: "~1 hour"
      
    google:
      feature: "Context caching"
      discount: "Variable, up to 75%"
      explicit_api: true
      
  usage_pattern:
    # Requests sharing the same system prompt + few examples
    request_1: [system_prompt + examples] + [user_query_1]
    request_2: [system_prompt + examples] + [user_query_2]
    
    # Cached portion: system_prompt + examples
    # Paid full price: user_query_1, user_query_2
```

**Designing for cache hits:**

```yaml
cache_optimization:
  principle: "Static content first, dynamic content last"
  
  bad_order:
    - "User query: {query}"        # Dynamic - breaks cache
    - "System instructions..."
    - "Few-shot examples..."
    
  good_order:
    - "System instructions..."      # Static - cached
    - "Few-shot examples..."        # Static - cached
    - "User query: {query}"         # Dynamic - only this is new
    
  implementation:
    cache_breakpoint: "after examples, before query"
    cache_prefix_size: 3500 tokens
    per_request_cost_savings: "~$0.007 per request"
```

#### Strategy 3: Model routing

Use expensive models only when needed. Route simple tasks to cheap, fast models.

**The cascade pattern:**

Research from Berkeley (RouteLLM, 2024) and others demonstrates that intelligent routing between models can reduce costs by 40-80% while maintaining quality.

```yaml
model_cascade:
  tiers:
    tier_1:
      model: "gpt-4o-mini"
      cost_per_1m_tokens: $0.15 / $0.60
      use_when:
        - "simple_classification"
        - "short_extraction"
        - "format_conversion"
        
    tier_2:
      model: "gpt-4o"
      cost_per_1m_tokens: $2.50 / $10.00
      use_when:
        - "complex_reasoning"
        - "long_form_generation"
        - "nuanced_judgment"
        
    tier_3:
      model: "o1" or "claude-3-opus"
      cost_per_1m_tokens: $15.00 / $60.00
      use_when:
        - "multi_step_reasoning_chains"
        - "novel_problem_solving"
        - "high_stakes_decisions"
        
  routing:
    method: "classifier_with_deferral"
    
    classifier:
      model: "gpt-4o-mini"  # Cheap model makes routing decision
      prompt: "Given this task, rate complexity 1-10..."
      
    deferral:
      if_tier_1_confidence_low: "escalate_to_tier_2"
      if_tier_2_produces_low_quality: "retry_with_tier_3"
```

**Task-step routing:**

Within a single workflow, different steps need different capabilities:

```yaml
step_routing:
  policy_brief_workflow:
    search_query_generation:
      model: "gpt-4o-mini"
      reason: "Simple expansion of user query into search terms"
      cost: "$0.001"
      
    document_extraction:
      model: "gpt-4o-mini"
      reason: "Structured extraction from clear text"
      cost: "$0.003"
      
    source_synthesis:
      model: "gpt-4o"
      reason: "Complex reasoning across multiple sources"
      cost: "$0.025"
      
    draft_generation:
      model: "gpt-4o"
      reason: "Long-form coherent generation"
      cost: "$0.035"
      
    citation_verification:
      model: "gpt-4o-mini"
      reason: "Matching claims to sources (lookup-like)"
      cost: "$0.002"
      
  total_routed_cost: $0.066
  total_if_all_gpt4o: $0.12
  savings: 45%
```

#### Strategy 4: Early exit and confidence thresholds

Stop processing when confident. Don't refine what's already good enough.

```yaml
early_exit:
  self_revision_loop:
    max_iterations: 5
    
    exit_conditions:
      - quality_score >= 0.9: "exit with current output"
      - improvement_from_last_iteration < 0.02: "exit (diminishing returns)"
      - iterations >= 2 AND quality_score >= 0.8: "exit (good enough)"
      
    cost_impact:
      without_early_exit:
        average_iterations: 4.1
        average_cost: $0.28
        
      with_early_exit:
        average_iterations: 2.4
        average_cost: $0.16
        savings: 43%
        
  search_loop:
    max_queries: 10
    
    exit_conditions:
      - sources_found >= target_count: "exit"
      - last_3_queries_returned_same_sources: "exit (saturated)"
      - all_required_topics_covered: "exit"
```

**Confidence-based routing:**

When the smaller model is uncertain, escalate before generating the full output:

```yaml
confidence_routing:
  flow:
    1. "route_with_small_model"
    2. "if confidence < 0.7: escalate BEFORE full generation"
    3. "generate_with_selected_model"
    
  implementation:
    step_1:
      model: "gpt-4o-mini"
      prompt: "Can you answer this question well? Rate 1-10."
      cost: "$0.0005"
      
    step_2:
      if_rating >= 7: "continue_with_mini"
      if_rating < 7: "escalate_to_4o"
      
  benefit: "Avoid paying for low-quality full generation from small model"
```

#### Strategy 5: Caching at every layer

Cache aggressively, but cache smart.

**Multi-layer caching:**

```yaml
caching_layers:
  embedding_cache:
    what: "Query and document embeddings"
    storage: "Redis or local disk"
    ttl: "24 hours (queries), 7 days (documents)"
    hit_rate_target: ">90%"
    savings: "~$0.0001/query"
    
  search_result_cache:
    what: "Search API responses"
    key: "normalized_query_hash"
    ttl: "1 hour (web), 24 hours (internal docs)"
    invalidation: "on_document_update"
    savings: "$0.01-0.05/query avoided"
    
  document_extraction_cache:
    what: "Extracted facts from documents"
    key: "document_id + extraction_schema_version"
    ttl: "until_document_updated"
    savings: "$0.02-0.10/document"
    
  llm_response_cache:
    what: "Identical prompt → response pairs"
    scope: "within_task only"  # Don't cache across tasks
    key: "prompt_hash + model + temperature"
    hit_rate: "~20% within complex tasks"
    savings: "variable"
```

**What NOT to cache:**

- Responses to creative/diverse queries (caching defeats the purpose)
- High-temperature outputs (not reproducible)
- Time-sensitive queries (outdated answers are wrong)
- User-specific responses (privacy and personalization)

#### Strategy 6: Batching and async

Some operations don't need real-time responses. Batch them.

```yaml
batching_strategy:
  embedding_batches:
    instead_of: "1 API call per document"
    do: "batch 100 documents per call"
    savings: "latency and often cost per document"
    
  background_tasks:
    examples:
      - "daily_cache_refresh"
      - "bulk_document_reprocessing"
      - "training_module_exports"
      
    scheduling:
      timing: "off-peak hours (nights, weekends)"
      priority: "low"
      rate_limit: "10 requests/second"
      
    cost_benefit:
      peak_api_pricing: "often higher (demand-based)"
      off_peak_reliability: "better (less contention)"
```

### Latency optimization

Cost and latency are deeply intertwined. Bigger contexts cost more and take longer to process—you're paying twice: once in dollars and once in user wait time. But latency has its own optimization surface beyond context size. The strategies below focus specifically on reducing time-to-response, some of which also reduce cost, and some of which trade cost for speed.

#### Streaming responses

Don't wait for complete generation. Stream tokens as they're produced.

```yaml
streaming:
  user_experience:
    without_streaming:
      wait_time: "15 seconds of blank screen"
      perceived_latency: "very slow"
      
    with_streaming:
      first_token: "1 second"
      perceived_latency: "fast and responsive"
      
  implementation:
    api_call: "stream=True"
    frontend: "render tokens incrementally"
    
  caveats:
    - "Cannot cache partial responses"
    - "Error handling more complex (mid-stream failures)"
    - "Tool calls may not stream (depends on provider)"
```

#### Progressive disclosure

Show intermediate results while computing final answer.

```yaml
progressive_disclosure:
  research_task:
    phase_1:
      show: "Searching for relevant documents..."
      then: "[list of 5 source titles found]"
      
    phase_2:
      show: "Reading and extracting key points..."
      then: "[bullet points appearing one by one]"
      
    phase_3:
      show: "Drafting summary..."
      then: "[streaming draft text]"
      
  benefit: "User sees progress, can intervene early if wrong direction"
```

#### Parallel tool execution

When tools are independent, run them in parallel.

```yaml
parallel_tools:
  scenario: "Research requires searching 3 different sources"
  
  sequential:
    search_internal: "2 seconds"
    search_web: "3 seconds"
    search_academic: "4 seconds"
    total: "9 seconds"
    
  parallel:
    all_three_started: "0 seconds"
    slowest_completes: "4 seconds"
    total: "4 seconds"
    speedup: "2.25x"
    
  implementation:
    orchestrator: "asyncio / concurrent.futures"
    dependency_check: "only parallel if no data dependency"
```

#### Edge caching and pre-computation

For predictable queries, pre-compute and cache at the edge.

```yaml
pre_computation:
  use_case: "Common queries with stable answers"
  
  examples:
    - "What's our vacation policy?" → cached
    - "Expense report submission deadline?" → cached
    - "Who approves purchases over $10K?" → cached
    
  refresh_strategy:
    trigger: "policy_document_updated"
    refresh: "regenerate_cached_answers"
    
  latency:
    cache_hit: "10ms"
    cache_miss: "3-10 seconds"
```

### Service Level Agreements (SLAs)

A Service Level Agreement (SLA) defines the performance expectations for a feature: how fast it responds, how much it can cost, and what quality guarantees it provides. Different use cases have different requirements—a quick lookup and a comprehensive research report shouldn't share the same constraints. Design for these differences explicitly.

#### Interactive vs. background

```yaml
sla_tiers:
  interactive:
    latency_target: "< 5 seconds to first token"
    cost_tolerance: "higher (user waiting)"
    model_preference: "faster, possibly smaller"
    retry_budget: "1 quick retry"
    
  nearline:
    latency_target: "< 2 minutes"
    cost_tolerance: "moderate"
    model_preference: "quality over speed"
    retry_budget: "3 retries with backoff"
    
  background:
    latency_target: "< 1 hour"
    cost_tolerance: "low (optimize for cost)"
    model_preference: "cheapest sufficient model"
    retry_budget: "unlimited with long backoff"
    scheduling: "off-peak when possible"
```

**Policy brief examples:**

```yaml
brief_sla_mapping:
  quick_question:
    type: "interactive"
    example: "What's the current travel policy?"
    budget: "$0.05"
    latency: "5 seconds"
    
  standard_brief:
    type: "nearline"
    example: "Summarize the Q4 expense policy changes"
    budget: "$0.25"
    latency: "2 minutes"
    
  comprehensive_research:
    type: "background"
    example: "Compare our leave policies to industry benchmarks"
    budget: "$1.00"
    latency: "1 hour"
    notification: "email when complete"
```

#### Budget guards by tier

```yaml
budget_guards:
  per_request:
    interactive: "$0.10 hard limit"
    nearline: "$0.50 hard limit"
    background: "$2.00 hard limit"
    
  per_user_per_day:
    standard_tier: "$5.00"
    premium_tier: "$25.00"
    
  enforcement:
    on_approaching_limit:
      at_80%: "warn user"
      at_100%: "block request, suggest waiting or upgrading"
      
  exceptions:
    - "admin override"
    - "critical business process flag"
```

### Cost modeling and monitoring

You can't optimize what you don't measure.

#### Cost attribution

Track costs by user, feature, and step.

```yaml
cost_attribution:
  dimensions:
    - user_id
    - team
    - feature
    - workflow
    - step
    - model
    
  example_report:
    feature: "policy_brief"
    period: "week"
    
    by_step:
      research: "$4,200 (35%)"
      drafting: "$6,100 (51%)"
      verification: "$1,700 (14%)"
      
    by_model:
      gpt-4o: "$9,500 (79%)"
      gpt-4o-mini: "$2,500 (21%)"
      
    by_user_tier:
      power_users_top_10%: "$5,400 (45%)"
      regular_users: "$6,600 (55%)"
```

#### Anomaly detection

Catch runaway costs before the invoice arrives.

```yaml
anomaly_detection:
  real_time:
    metric: "cost_per_minute"
    threshold: "3x average"
    action: "alert_oncall"
    
  per_request:
    metric: "request_cost"
    threshold: "$1.00"
    action: "log_and_review"
    
  per_user:
    metric: "daily_cost"
    threshold: "2x user's historical average"
    action: "rate_limit_warning"
    
  alerts:
    channels: ["slack", "pagerduty"]
    escalation:
      first: "on_call_engineer"
      if_unack_30m: "eng_lead"
      if_unack_2h: "product_lead"
```

### Cost model exercise

Putting it together: a cost model template.

```yaml
cost_model_template:
  feature: "[Feature name]"
  version: "[Date]"
  
  assumptions:
    daily_users: 500
    requests_per_user_per_day: 5
    average_context_tokens: 15000
    average_output_tokens: 2000
    average_tool_calls: 8
    model_mix: 
      gpt-4o-mini: "40%"
      gpt-4o: "60%"
    cache_hit_rate: "30%"
    
  cost_breakdown:
    llm_inference:
      input: "$X"
      output: "$Y"
      cache_discount: "-$Z"
      subtotal: "$A"
      
    retrieval:
      embeddings: "$B"
      vector_search: "$C"
      reranking: "$D"
      subtotal: "$E"
      
    infrastructure:
      compute: "$F"
      storage: "$G"
      subtotal: "$H"
      
  total_daily_cost: "$I"
  total_monthly_cost: "$I × 30"
  cost_per_request: "$J"
  cost_per_user_per_month: "$K"
  
  optimization_targets:
    - "Reduce context size 20% via compaction"
    - "Increase cache hit rate to 50%"
    - "Route 60% of requests to mini model"
    
  projected_savings: "40%"
```

## Case study thread

### Research+Write (Policy change brief)

The brief agent applies cost optimization at every step.

#### Model routing policy

```yaml
brief_routing:
  query_expansion:
    model: "gpt-4o-mini"
    cost: "$0.001"
    
  search_and_extract:
    model: "gpt-4o-mini"
    cost: "$0.005"
    
  synthesis_and_draft:
    model: "gpt-4o"
    cost: "$0.045"
    
  self_revision:
    model: "gpt-4o"
    iterations: "max 2"
    early_exit: "quality >= 0.85"
    cost: "$0.03 average"
    
  citation_check:
    model: "gpt-4o-mini"
    cost: "$0.002"
    
  total_routed: "$0.083"
  total_unrouted: "$0.150"
  savings: "45%"
```

#### Caching strategy

```yaml
brief_caching:
  document_extraction:
    scope: "organization-wide"
    ttl: "until document updated"
    invalidation: "webhook from doc system"
    
  prompt_prefix:
    includes: ["system_prompt", "output_format", "examples"]
    size: "3,500 tokens"
    cache_hit_discount: "50%"
    
  search_results:
    scope: "per-user, 1 hour"
    key: "query_hash + source_scope"
```

#### SLA mapping

```yaml
brief_slas:
  quick_answer:
    trigger: "< 50 words, simple lookup"
    model: "gpt-4o-mini only"
    budget: "$0.02"
    latency: "3 seconds"
    
  standard_brief:
    trigger: "default"
    models: "routed"
    budget: "$0.15"
    latency: "45 seconds"
    
  comprehensive:
    trigger: "user selects 'thorough research'"
    models: "gpt-4o for all synthesis"
    budget: "$0.50"
    latency: "5 minutes"
    warning: "Show estimated cost before starting"
```

### Instructional Design (Annual compliance training)

The training agent faces different cost dynamics: large template-based outputs with high reuse.

#### Template-based generation

```yaml
training_cost_optimization:
  principle: "Templates reduce generation; regenerate only deltas"
  
  template_coverage:
    standard_structures: "80% templated"
    custom_scenarios: "20% generated"
    
  cost_comparison:
    full_generation:
      tokens: 25000
      cost: "$0.35"
      
    template_plus_delta:
      template_fill: "5000 tokens"
      custom_generation: "5000 tokens"
      cost: "$0.10"
      savings: "71%"
      
  delta_detection:
    on_policy_update:
      - diff: "old_policy vs new_policy"
      - affected_sections: ["section_3", "quiz_question_7"]
      - regenerate: "only affected sections"
```

#### Background processing

```yaml
training_scheduling:
  interactive:
    use_case: "Preview outline, review assessments"
    latency: "< 10 seconds"
    
  background:
    use_case: "Full module generation, LMS export"
    latency: "< 30 minutes"
    scheduling: "off-peak"
    
    notification:
      on_complete: "email with preview link"
      
  batch_operations:
    use_case: "Annual policy refresh across all modules"
    scheduling: "weekend"
    parallelism: "10 concurrent"
```

## Artifacts to produce
- Cost model spreadsheet outline (assumptions + budgets + guards)

## Chapter exercise
Create a cost model for either Research+Write or Instructional Design. Include:
1. List all cost drivers (LLM inference, retrieval, external APIs)
2. Estimate token consumption per step
3. Apply routing to assign models per step
4. Calculate expected cost per request
5. Set budget guards at 80% and 100% of target
6. Identify three optimization opportunities and project savings

## Notes / references
- RouteLLM (Berkeley, 2024): Demonstrated 40-80% cost savings through intelligent model routing
- Anthropic prompt caching (2024): Up to 90% discount on cached prompt prefixes
- OpenAI structured outputs (2024): 100% schema compliance enabling reliable parsing
- Context caching is provider-specific; check current documentation for TTL and pricing
- All pricing figures in this chapter are approximate and subject to change; consult provider documentation for current rates
- Cost optimization should never compromise core quality metrics—measure both

