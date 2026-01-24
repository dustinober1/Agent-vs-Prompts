# Chapter 9 — Grounding with retrieval: search, RAG, and citations

## Purpose
Replace "know things" with "find things and cite them."

## Reader takeaway
Grounded outputs come from retrieval + constraints + citation discipline, not from "being accurate" instructions.

## Key points
- When retrieval is necessary (dynamic knowledge, large corpora, auditability)
- Retrieval spectrum: keyword, semantic, hybrid, reranking, structured queries
- Patterns: retrieve-then-read, iterative search, cite-then-answer, contradiction checks
- Failure modes: irrelevant retrieval, missing docs, citation laundering


### The citation that looked perfect

The policy brief looked excellent. Professional formatting, clear structure, authoritative tone. Every claim had a citation. The stakeholder glanced at the sources—internal policy wiki pages, two SOPs, a recent guidance document—and approved it for distribution.

A week later, someone clicked a link.

The first citation went to a policy page that existed, but the quoted text wasn't there. The second citation went to an SOP that had been superseded three months ago. The third citation was to a guidance document that did exist and did contain similar language—but said the opposite of what the brief claimed.

This is **citation laundering**: citations that look valid but don't actually support the claims they're attached to. The model didn't lie, exactly. It produced text that *looked* cited. But the relationship between claim and source was surface-level pattern matching, not actual evidence.

Chapter 1 warned you that "include citations" is not a guarantee. Chapter 8 gave you tools to verify citations. This chapter is about the step that comes before verification: retrieval. How do you get the right information into the model's context so that citations can be real?

### Why retrieval changes everything

Consider the difference between these two prompts:

**Prompt A (no retrieval):**
> Write a policy change brief about our updated PII retention policy.

**Prompt B (with retrieval):**
> Based on the following policy documents, write a policy change brief about our updated PII retention policy.
> 
> [Document 1: Current PII Retention Policy, effective 2025-01-15]
> ...
> [Document 2: Previous PII Retention Policy, effective 2023-06-01]
> ...
> [Document 3: Data Privacy SOP, section 4.2]
> ...

Prompt A asks the model to know things. It will produce something—models are optimized to continue—but what it produces will be drawn from training data, from pattern matching, from "what sounds like a PII policy."

Prompt B asks the model to use things. The documents are right there. The model's job is interpretation, not invention.

This is the core shift: **from "know" to "find and use."**

Retrieval doesn't make models smarter. It makes them accountable. When you can point to the document that was in context, you can verify whether the model used it correctly. When the model invents information, there's nothing to check against.

### When do you need retrieval?

Not every task needs retrieval. Summarizing a document the user just pasted? No retrieval needed—the source is already there. Rewriting for tone? Same thing. Brainstorming ideas? The model's training data is the point.

But retrieval becomes necessary when:

**The knowledge is dynamic.** Policies change. Products update. Regulations evolve. If your answer depends on "the current version" of anything, you need to retrieve it. Models don't update themselves when your wiki changes.

**The corpus is large.** You can't paste your entire knowledge base into a prompt. Retrieval lets you find the relevant needle in a haystack of documents, then bring just that needle into context.

**Auditability matters.** When someone asks "where did this come from?", you need to point to a source. Retrieval creates a paper trail. The evidence set becomes an artifact you can review, version, and defend.

**Least privilege applies.** Not everyone should see everything. Retrieval with permission filtering lets you scope what the model can access based on who's asking.

Our two case studies both need retrieval:
- **Research+Write** needs current policies, may need external guidance, and must cite sources.
- **Instructional Design** needs current policies and SOPs as the source of truth for training content.

Let's look at how to do it well.

### The retrieval spectrum

"Retrieval" isn't one technique. It's a family of approaches, and choosing the right one matters.

#### Keyword search (BM25 and friends)

BM25 (Best Match 25) is the standard keyword retrieval algorithm.

The simplest approach: match query words to document words. Fast, interpretable, good when your users know the vocabulary.

**Works well when:**
- Users search for specific terms ("PII retention policy")
- Documents use consistent terminology
- You need deterministic, explainable results

**Fails when:**
- Users describe concepts without using the right words
- Documents use synonyms or jargon the user doesn't know
- You need semantic matching ("what's our rule about keeping customer data?")

#### Semantic search (embeddings)

Convert queries and documents into vectors. Find documents whose vectors are "close" to the query vector. Good at capturing meaning, not just words.

**Works well when:**
- Users describe what they want in natural language
- You need to match concepts across different phrasings
- The corpus uses varied terminology

**Fails when:**
- The query is ambiguous (semantic similarity might retrieve plausible but wrong documents)
- You need exact matches (product codes, policy numbers)
- You're debugging ("why did it retrieve *that*?")

#### Hybrid search

Combine keyword and semantic approaches. Use keyword matching for precision, semantic matching for recall. Weight and combine the results.

**This is usually what you want for enterprise knowledge.** Hybrid search handles users who know the exact term and users who describe what they need.

#### Reranking

After initial retrieval, use a more sophisticated model to reorder results by relevance. The initial search casts a wide net; the reranker picks the best catches.

**Useful when:**
- Initial retrieval returns many candidates (20-100)
- Precision at the top matters more than total recall
- You can afford the latency and cost of a second model

#### Structured queries

When your documents have metadata (date, author, policy area, confidentiality level, role), use it. Filter before or after retrieval. Combine with text search.

**Examples:**
- "Only policies effective after 2024-01-01"
- "Only SOPs tagged for the Engineering role"
- "Exclude documents marked confidential"

Structured filters are deterministic. They don't have false positives. Use them to enforce hard constraints that semantic search might miss.

### The retrieval pipeline (what runs when)

A production retrieval system isn't just "call the search API." It's a pipeline with multiple stages, each doing a specific job.

**Stage 1: Query understanding**
- What is the user actually asking for?
- Are there implicit constraints (role, region, date range)?
- Does the query need rewriting for better retrieval?

**Stage 2: Initial retrieval**
- Cast a wide net: 20-100 candidates
- Use hybrid search when possible
- Apply hard filters (permissions, date ranges)

**Stage 3: Reranking (optional)**
- Score candidates for relevance to the actual task
- Prioritize documents that directly answer the question
- Consider freshness, authority, and other signals

**Stage 4: Selection and truncation**
- Pick the top N documents that fit in context
- Decide how much of each document to include
- Preserve enough context for the model to cite accurately

**Stage 5: Formatting for the model**
- Clear document boundaries
- Metadata the model can reference (doc ID, title, date)
- Instructions on how to cite

Each stage is a potential failure point. Monitor all of them.

### Four retrieval patterns for agents

Here are four patterns for wiring retrieval into the agent loop, from simple to sophisticated.

#### Pattern 1: Retrieve-then-read (the RAG baseline)

Retrieve-then-read is the baseline for Retrieval-Augmented Generation (RAG)—the pattern that gave the field its name.

The simplest pattern:
1. User asks a question
2. Retrieve relevant documents
3. Pass documents + question to the model
4. Model answers based on documents

**When to use:** Single-turn questions, low ambiguity, trusted retrieval.

**Limitation:** One shot at retrieval. If you get the wrong documents, the answer will be wrong.

#### Pattern 2: Iterative search

The agent can search multiple times, refining queries based on what it finds:
1. Initial search with user's query
2. Examine results—are they sufficient?
3. If gaps exist, formulate a new query
4. Repeat until evidence set is complete (or budget exhausted)

**When to use:** Research tasks, complex questions, when you can't predict the right query upfront.

**Implementation:** The agent has a `search` tool (Chapter 8) and can call it multiple times within the loop budget.

**Risk:** Query drift. The agent might wander into tangentially related topics. Use budgets.

#### Pattern 3: Cite-then-answer

Flip the typical order:
1. Retrieve documents
2. Extract candidate claims/quotes from documents
3. Build a citation map: claim → source + excerpt
4. Draft the answer using only mapped claims
5. Every claim in the answer points to a citation

**When to use:** High-stakes outputs where traceability matters. Policy briefs, compliance content, anything that needs audit trails.

**Advantage:** Makes citation laundering much harder. The claim-source relationship is built before the prose is written.

#### Pattern 4: Contradiction and confidence checks

After retrieval and before answering:
1. Check if sources agree or contradict
2. Surface conflicts explicitly ("Source A says X; Source B says Y")
3. Estimate confidence based on source coverage

**When to use:** Topics where multiple policies might apply, evolving guidance, anything where "the answer" might not be singular.

**Implementation:** After retrieval, run a comparison step. If contradictions exist, either resolve them (which source is authoritative?) or surface them to the user.

### Retrieval failure modes (and how to detect them)

Retrieval is the first place things go wrong in a grounded system. Here are the failures to watch for:

#### Failure 1: Irrelevant retrieval

The search returned documents, but they don't actually answer the question.

**Detection:**
- Low reranker scores
- Model output says "Based on the documents, I cannot find..."
- Human review catches off-topic sources

**Response:**
- Query rewriting (automatic or with model help)
- Expand search to additional corpora
- Report "insufficient sources" and ask user for guidance

#### Failure 2: Missing documents

The relevant document exists, but retrieval didn't find it.

**Detection:**
- User reports "but it's in document X"
- Audit review finds unmapped claims
- Coverage metrics show gaps

**Response:**
- Improve indexing (is the document actually indexed?)
- Improve query understanding (is the query hitting the right terms?)
- Expand initial retrieval (cast a wider net, then rerank)

#### Failure 3: Stale documents

Retrieval found a document, but it's been superseded.

**Detection:**
- Document metadata shows old dates
- Cross-reference check finds newer versions
- Policy owner flags outdated content

**Response:**
- Include freshness signals in ranking
- Return `last_updated` metadata with every document
- Apply freshness filters ("only documents updated in last 6 months")
- Verify current status before citing

#### Failure 4: Citation laundering

The classic problem from our opening story: citations exist but don't support the claims.

**Detection:**
- Citation verification tool (Chapter 8's `cite_verify`)
- Quote matching: does the cited excerpt actually appear in the document?
- Claim-source relevance: does the excerpt support the claim?

**Response:**
- Build citation maps before drafting (Pattern 3)
- Require verbatim quotes, not paraphrases
- Verify citations before publishing (make it a gate)

#### Failure 5: Permission violations

Retrieval returned documents the user shouldn't see.

**Detection:**
- Permission check at retrieval time (before returning results)
- Audit log review
- User reports seeing content they shouldn't

**Response:**
- Filter by permission at retrieval time, not after
- Never return full documents without permission checks
- Scope retrieval to allowed corpora based on user context

### Building a citation discipline

Retrieval is only half the problem. The other half is what you do with what you retrieve. That's citation discipline.

A citation is a claim about the relationship between your output and your sources. It says: "This assertion is supported by this source." That claim can be true or false.

Good citation discipline makes the claim verifiable:

**Every claim references a source.** Not just "we retrieved some documents," but "claim X is supported by document Y, section Z."

**Citations include locators.** Document ID, section heading, page number, paragraph anchor—whatever lets a reader find the exact text.

**Citations include excerpts.** A quote or close paraphrase that shows what the source actually says. This makes verification possible without re-reading the whole document.

**Unsupported claims are marked.** When a claim isn't supported by retrieved sources, mark it. "NEEDS SOURCE" or "UNVERIFIED" or a similar flag. Don't pretend coverage you don't have.

**Citations are verified before publishing.** The `cite_verify` tool from Chapter 8: check that document IDs resolve, that quoted text exists, that excerpts support claims.

### Source trust tiers

Not all sources are equal. A citation to your official policy wiki is different from a citation to an external blog post.

Define trust tiers for your sources:

**Tier 1: Authoritative internal**
- Official policies and SOPs
- Approved guidance documents
- Legal/compliance-reviewed content

**Tier 2: Internal working documents**
- Draft policies
- Team documentation
- Internal wikis (unofficial)

**Tier 3: Verified external**
- Regulatory body publications
- Industry standards (ISO, NIST)
- Cited academic papers

**Tier 4: General external**
- News articles
- Blog posts
- General web content

Your citation policy should specify:
- Which tiers are allowed for which use cases
- Whether external sources require approval
- How conflicts between tiers are resolved

For compliance-sensitive content like our case studies, Tier 1 should be required for any claim that drives action. Lower tiers can inform background context but shouldn't be cited as authority.

Retrieval gives you the sources. Citation discipline makes them traceable. But both assume you know what to retrieve—which brings us to planning. Chapter 10 addresses how agents decompose tasks and decide what information they need before they start searching.

## Case study thread

### Research+Write (Policy change brief)

The policy brief agent needs retrieval that's both thorough and auditable.

#### What needs retrieving

**Always retrieve:**
- The current version of the policy being discussed
- The previous version (for comparison—what changed?)
- Related SOPs that implement the policy
- Any pending guidance that affects interpretation

**Optionally retrieve (when allowed):**
- External regulatory guidance (Tier 3)
- Industry best practices
- Comparison to similar organizations' approaches

**Never retrieve without explicit permission:**
- Confidential executive summaries
- Draft policies not yet approved
- External content for Tier 1 claims

#### The retrieval flow

```
1. Parse request → identify policy topic and scope
2. Structured query → find official policy by name/ID
3. Semantic search → find related SOPs and guidance
4. Freshness filter → exclude documents older than threshold
5. Permission filter → scope to user's allowed corpora
6. Rerank → prioritize by relevance and authority
7. Select top N → fit within context budget
8. Format with metadata → doc ID, title, date, section
```

#### Citation policy for Research+Write

Every policy brief must follow these citation rules:

**Key claims require Tier 1 sources.** Any statement about what policy requires must cite the official policy document by ID, section, and include a verbatim quote.

**Background context can use Tier 2-3.** Context about why a policy exists or how it compares to industry practice can cite lower-tier sources, clearly marked.

**External sources require approval.** If `external_allowed = false`, retrieval must skip external corpora. This is enforced at the tool level (Chapter 8).

**Unsupported claims must be flagged.** If the agent cannot find a source for a key claim, it must mark the claim as "NEEDS SOURCE" rather than inventing a citation.

**Citation verification is a gate.** Before the brief can be delivered, `cite_verify` must confirm that all citations resolve and quotes match. Failures block publishing.

#### Example evidence set structure

```yaml
evidence_set:
  topic: "PII Retention Policy Update"
  as_of_date: "2025-01-15"
  
  sources:
    - doc_id: "POL-2025-0012"
      title: "PII Retention Policy v3.0"
      tier: 1
      last_updated: "2025-01-10"
      relevance_score: 0.95
      excerpts:
        - claim_id: "claim_001"
          quote: "Personal data must be deleted within 90 days of..."
          section: "3.2 Retention Limits"
          
    - doc_id: "POL-2024-0089"
      title: "PII Retention Policy v2.0"
      tier: 1
      last_updated: "2024-03-15"
      relevance_score: 0.88
      excerpts:
        - claim_id: "claim_002"
          quote: "Personal data must be deleted within 180 days..."
          section: "3.2 Retention Limits"
          note: "Previous version - for comparison"

  gaps:
    - claim: "Impact on third-party processors"
      status: "NEEDS SOURCE"
      search_attempted: ["third party processor PII", "vendor data retention"]
```

### Instructional Design (Annual compliance training)

The training module agent needs retrieval that ensures accuracy and avoids licensing issues.

#### What needs retrieving

**Always retrieve:**
- Current policies for all topics covered
- SOPs that describe required procedures
- Existing approved training templates
- Role-specific variations (if applicable)

**Carefully retrieve:**
- Examples and scenarios from existing training (avoid outdated examples)
- Assessment item banks (check for current accuracy)

**Never retrieve:**
- Copyrighted external training content
- Unlicensed images or media
- Policies from other organizations (even as examples)

#### The retrieval flow

```
1. Parse request → identify compliance topics and learner role
2. Topic mapping → find policies for each required topic
3. Freshness check → verify policies are current versions
4. SOP lookup → find procedures that implement each policy
5. Template search → find existing training templates for format
6. Permission filter → scope to licensed/approved content only
7. Select and format → include version dates for every source
```

#### Source and licensing policy for Instructional Design

Training content must follow these sourcing rules:

**All policy claims cite internal Tier 1 sources.** Every statement about what employees must do references the current policy with version date.

**"Last verified" dates are required.** Every policy reference includes when it was last confirmed current. Staleness threshold: 30 days for annual training.

**Only licensed content in deliverables.** No external content copied into training. If external examples are needed, describe them; don't reproduce them.

**Scenarios must be original or approved.** Real-world scenarios should be generated fresh, not copied from other training programs.

**Assessment items must match current policy.** If a policy changes, assessments referencing old policy must be flagged for review.

#### Example policy map structure

```yaml
policy_map:
  module: "Annual Security Awareness Training"
  role: "All Employees"
  verified_date: "2025-01-10"
  
  topics:
    - topic: "Phishing Recognition"
      policy_ref:
        doc_id: "POL-SEC-001"
        title: "Email Security Policy"
        version: "4.2"
        last_verified: "2025-01-10"
        sections: ["2.1", "2.2", "2.3"]
      sop_ref:
        doc_id: "SOP-SEC-015"
        title: "Reporting Suspicious Emails"
        version: "2.0"
      coverage: "complete"
      
    - topic: "Password Management"
      policy_ref:
        doc_id: "POL-SEC-003"
        title: "Authentication Policy"
        version: "5.1"
        last_verified: "2025-01-08"
        sections: ["3.1", "4.1", "4.2"]
      sop_ref: null
      coverage: "partial"
      gap: "No SOP for password manager usage"
```

## Artifacts to produce

- A **retrieval pipeline spec** for each case study (stages, filters, ranking)
- A **citation policy** for Research+Write (what must be cited, how, verification gates)
- A **source trust tier** definition (what counts as authoritative)
- A **source/licensing policy** for Instructional Design (what's allowed, what's not)
- An **evidence set schema** showing how retrieved sources are stored and referenced

## Chapter exercise

### Part 1: Define your citation policy

For the Research+Write case study, write a citation policy that answers:

1. What claims require citations? (All claims? Only factual claims? Key claims?)
2. What sources are acceptable? (Define your trust tiers)
3. What must a citation include? (Doc ID, section, quote, date?)
4. How are unsupported claims handled?
5. What verification must pass before publishing?

### Part 2: Design your retrieval pipeline

For either case study, sketch the retrieval pipeline:

1. **Query stage:** How do you understand what to search for?
2. **Retrieval stage:** What search approach? What filters?
3. **Reranking stage:** How do you prioritize results?
4. **Selection stage:** How do you choose what fits in context?
5. **Formatting stage:** How do you present sources to the model?

### Part 3: Failure mode analysis

Pick two retrieval failure modes from this chapter. For each:

1. How would you detect it in production?
2. What metric or signal would you monitor?
3. What's the recovery path when it occurs?

## Notes / references

- Retrieval-Augmented Generation (RAG): https://arxiv.org/abs/2005.11401
- BM25 (keyword retrieval): https://en.wikipedia.org/wiki/Okapi_BM25
- Dense retrieval (embeddings): https://arxiv.org/abs/2004.04906
- ColBERT (late interaction reranking): https://arxiv.org/abs/2004.12832
- Lost in the Middle (position effects): https://arxiv.org/abs/2307.03172
- Self-RAG (self-reflective retrieval): https://arxiv.org/abs/2310.11511
- Corrective RAG (verification patterns): https://arxiv.org/abs/2401.15884
- NIST AI RMF on data quality: https://www.nist.gov/itl/ai-risk-management-framework

