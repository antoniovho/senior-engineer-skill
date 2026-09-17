````markdown
# Plan Session Template

Use this template when creating `plan.md`. Copy the structure inside the inner code fence (```` ```markdown ```` to ```` ``` ````) and fill in each section incrementally as the planning progresses. Replace `[PENDING]` tags with actual content — no placeholders should remain when the plan is complete.

---

```markdown
# Plan: <Title>

## Metadata
- **Plan name**: {plan_name}
- **Status**: 🔄 Understanding
- **Created**: YYYY-MM-DD
- **Input source**: Research handoff / Idea / Direct requirement
- **Research file**: <path to research.md, or "N/A">
- **Target repository**: <owner/repo resolved during Phase 1, or "N/A">

## Overview

[PENDING]

<!-- What is being planned, why, and for whom. If coming from research, summarize the
     research objective and recommended direction. If from an idea or direct requirement,
     capture the problem statement and desired outcome. -->

## Research Context

[PENDING — or "N/A" if no research handoff exists]

<!-- If planning was triggered from an `aidev-research` skill handoff, summarize the binding context here:
     - Research Objective (problem, target users, success criteria)
     - Key Findings (3-5 bullet points)
     - Recommendations (chosen direction with justification)
     - Risks (from research, with impact levels)
     - Open Questions (items requiring decisions during planning)
     - Internal Capabilities (relevant Inditex products, APIs, artifacts, teams)

     This section is READ-ONLY after initial population — it captures the research state
     at the moment of handoff. Planning decisions that diverge from research recommendations
     must be documented in ## Clarifications with explicit justification. -->

## Product Context

[PENDING — or "N/A" if product context could not be resolved]

<!-- What the product does, who it serves, what capabilities each artifact contributes,
     and how they relate — all in domain/product language. Architecture and tech stack
     details are relevant only when they represent product-level constraints
     (e.g., "operates as two separate applications" is relevant; "uses Spring Boot
     with WebFlux" is not). Populated during context acquisition (Phase 1). -->

### Sources consulted

_No sources recorded yet._

<!-- As you consult wiki pages, API docs, GitNexus queries, code, and other sources
     during planning, record each significant source here with a brief note on what
     it revealed. Start during Phase 1 (context acquisition) and extend throughout
     later phases. This is the primary pool from which spec-level context refs
     are selected.

     For artifact repository sources, use commit-pinned GitHub URLs so references
     remain valid even if files change later. For GitNexus queries or tool results,
     record the query and key findings.

     - https://github.com/inditex/<repo>/blob/<commit-hash>/wiki/<path> — <what it revealed>
     - GitNexus: <query description> — <what it revealed>
     - <API doc or tool query> — <what it revealed>
-->

## Clarifications

<!-- This section records clarifications obtained during the Deep Interview phase.
     Format: - **[Dimension]**: Q: <question> → A: <answer>
     Primary: User Journey, Done Criteria, Scope Boundaries, Behavioral Contracts,
     Tradeoff Tensions
     Secondary: Integration Surface, Failure & Recovery, Data Lifecycle,
     Operational Needs -->

### Session [YYYY-MM-DD]

_No clarifications recorded yet._

## Spec Registry

[PENDING]

<!-- Populated during Phase 3 — Spec Definition.
     Each spec is written to its own file under specs/.
     specs/drafts.md contains the agent's decomposition rationale (private scratchpad).
     This registry tracks all specs with their paths.

     | # | Type | Title | File |
     |---|------|-------|------|
     | 1 | 🧩 | Descriptive Name | specs/spec-1-kebab-name.md |
     | 2 | 🐞 | Descriptive Name | specs/spec-2-kebab-name.md |
     | 3 | 🔍 | Descriptive Name | specs/spec-3-kebab-name.md |
-->

## Planning Notes

<!-- Record significant discoveries, surprises, or connections as they emerge during
     any phase. Keep notes brief (1-3 sentences each) and prefix with the phase:
     - [Phase 1] ...
     - [Phase 3] ...
     - [Phase 3] ... (spec authoring may surface new insights)
     These notes capture reasoning that would otherwise be lost between phases. -->

## Risks & Considerations

[PENDING]

<!-- Identified risks with impact level and mitigations.

     | Risk | Impact | Mitigation |
     |------|--------|------------|
     | ... | High/Medium/Low | ... |

     Include:
     - Technical risks (complexity, unknowns, dependencies)
     - Organizational risks (team availability, skill gaps)
     - Timeline risks (blockers, external dependencies)
     - Risks inherited from research (if applicable)
-->

## Session Info

- **File path**: <absolute path to this plan.md>
- **Plan name**: {plan_name}
- **Research file**: <absolute path to research.md, or "N/A">
- **Target repository**: <owner/repo resolved during Phase 1, or "N/A">
```

## Section Guidelines

### Metadata
- Update **Status** as planning progresses through phases:
  - `🔄 Understanding` → Phase 1
  - `🔄 Interview` → Phase 2
  - `🔄 Spec Definition` → Phase 3
  - `✅ Complete` → Phase 4 (finalization)
- Use actual dates.
- **Input source** must reflect how the plan was triggered.

### Research Context
- Only populate if a research handoff exists.
- Copy binding context verbatim from the research session file — do not reinterpret.
- Mark as read-only after initial population. Any divergence from research recommendations must be explicitly justified in ## Clarifications.

### Product Context
- Write in domain/product language — describe what the product does and what each artifact contributes, not how it is implemented internally. Code-based sources (wikis, GitNexus, code analysis) are input to your reasoning; translate every insight into functional terms before writing it here.
- Architecture and tech stack details belong only when they represent product-level constraints visible to the user or stakeholder (e.g., "operates across two separate applications" is relevant context; "uses Spring Boot with WebFlux" is not).
- `### Sources consulted` paths/links are references and can be technical, but the descriptions next to them should explain what each source revealed in product terms.

### Clarifications
- Group by session date.
- Every answer must reference the interview dimension.
- Clarifications that change prior decisions should note what changed and why.

### Planning Notes
- A living section — add notes throughout Phases 1-3 whenever you encounter something worth remembering.
- Each note should be 1-3 sentences, prefixed with the phase where it was captured.
- Focus on insights that would be lost if not written down: surprises, connections, rejected alternatives, non-obvious conventions.
- This is NOT a work log. Skip routine observations. Capture only what matters for understanding the plan.

### Spec Registry
- Each spec is written to its own file under `specs/` — the registry is an index, not the spec content.
- Every spec must follow the section structure defined for its type.
- Never leave a spec partially specified — if information is missing, record it in ## Clarifications as pending.

### Risks & Considerations
- Include risks from all sources: research, interview, and context acquisition.
- Every risk must have a proposed mitigation, even if the mitigation is "Accept and monitor".

````
