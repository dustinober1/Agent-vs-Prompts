# Project Architecture: Stop Prompt Engineering

This project is structured as a technical book focused on the transition from prompt engineering to building robust agentic systems. The architecture reflects a modular, pedagogical approach where theoretical concepts are immediately grounded in practical, evolving case studies.

## Core Components

### 1. The Narrative Core (`chapters/`)
The book is organized into six logical parts, moving from the limitations of current paradigms to the engineering requirements of production-ready agents:
- **Foundational Critique (Part I):** Establishes the "Prompting Plateau" and the necessity of a systems-oriented approach.
- **Conceptual Framework (Part II):** Defines "The Agentic Mindset" and the core "Plan-Act-Observe-Reflect" loop.
- **Technical Primitives (Part III):** Deep dives into the "Building Blocks" (Tools, Retrieval, Planning, State, Verification).
- **System Design (Part IV):** Explores "Patterns and Architectures," including multi-agent orchestration and UX.
- **Operational Excellence (Part V):** Addresses "Shipping and Operating" concerns like reliability, observability, and security.
- **Strategic Outlook (Part VI):** Discusses the organizational impact and future trends.

### 2. Practical Grounding (`case_studies/`)
Two primary case studies are woven throughout the chapters to provide continuity and concrete examples:
- **Case Study A: Research+Write Agent:** Focuses on information retrieval, grounding, and document generation.
- **Case Study B: Instructional Design Agent:** Focuses on alignment, policy compliance, and structured output.

These case studies are not isolated; they are used in chapter exercises and "build logs" to demonstrate how each technical block (e.g., Tool Use in Chapter 8, Planning in Chapter 10) is implemented in a real-world scenario.

### 3. Structural Templates and Standards
- **`_chapter_TEMPLATE.md`:** Ensures consistency in chapter delivery, including purpose, case study integration, and exercises.
- **`case_studies/` templates:** Provide standardized formats for defining agent goals, tools, and success criteria.

## Information Flow
The project follows a "layered" information flow:
1. **Strategic Intent:** Defined in `BOOK_OUTLINE.md`.
2. **Theoretical Instruction:** Detailed in the `chapters/` files.
3. **Applied Verification:** Demonstrated through the case study templates and appendices.
4. **Project Metadata:** Managed within the `.planning/` directory for development tracking.
