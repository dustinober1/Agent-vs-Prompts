# Project Structure: Stop Prompt Engineering

This document maps out the folder organization and the high-level content flow of the book.

## Folder Organization

```text
/
├── .planning/             # Internal project management and documentation
│   └── codebase/          # Technical and architectural documentation
├── chapters/              # Primary book content (Markdown)
│   ├── 01...22.md         # Sequential chapters (Parts I - VI)
│   ├── _chapter_TEMPLATE  # Standard template for all chapters
│   └── README.md          # Internal overview of the chapters directory
├── case_studies/          # Practical implementations used throughout the book
│   ├── MODULE_TEMPLATE    # Template for instructional design modules
│   ├── BRIEF_TEMPLATE     # Template for research/policy briefs
│   └── README.md          # Overview of the two core case studies
├── BOOK_OUTLINE.md        # Comprehensive outline and thesis of the book
└── README.md              # Project-level overview (if applicable)
```

## High-Level Content Flow (Book Outline)

The book follows a six-part logical progression, as defined in `BOOK_OUTLINE.md`:

### Part I: The Prompting Plateau (Chapters 1-4)
- Focus: Understanding why prompt engineering alone is a brittle strategy.
- Key concepts: Prompt debt, failure modes, and what belongs outside the prompt.

### Part II: The Agentic Mindset (Chapters 5-7)
- Focus: Shifting from text inputs to systems engineering.
- Key concepts: Agent loops (plan-act-observe-reflect) and degrees of agency.

### Part III: Core Building Blocks (Chapters 8-12)
- Focus: Technical components of an agentic system.
- Key concepts: Tool design, retrieval (RAG), planning, state/memory, and verification.

### Part IV: Agent Patterns and Architectures (Chapters 13-16)
- Focus: Organizing multiple agents and human-in-the-loop workflows.
- Key concepts: Multi-agent patterns (supervisor/worker), orchestration, and UX.

### Part V: Shipping and Operating Agents (Chapters 17-20)
- Focus: Production concerns and reliability.
- Key concepts: Reliability engineering, observability, security, and cost/latency.

### Part VI: Org and Future (Chapters 21-22)
- Focus: Organizational impact and future trends.
- Key concepts: New team roles and where agentic systems are heading.

### Appendices (A-D)
- Includes glossaries, checklists, templates, and "build logs" for the Research+Write and Instructional Design case studies.
