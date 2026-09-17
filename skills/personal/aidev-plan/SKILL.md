---
name: aidev-plan
description: 4-phase sequential workflow that transforms a product idea into a structured plan of functional specs (user stories, bugs, spikes). Focuses on WHAT and WHY — product-level definitions using domain language, not technical implementation. Uses a draft-first approach — decompose, map functional contracts, then ensure every information dimension is covered. Each phase is mandatory and must complete before the next begins. Read SKILL.md fully before starting. Triggers on "plan a feature", "create issues for", "spec", "break down this feature", or "planifica".
metadata:
    version: 1.0.0
---

## ⚠️ Before You Start

**Read this file fully before starting any work.** This skill is not a generic planning template — it is a carefully designed phase-gate workflow where each phase builds on the validated output of the previous one.

Execute the 4 MANDATORY phases sequentially, one at a time (1 → 2 → 3 → 4), stop for user approval at each confirmation checkpoint, and follow the process exactly. The quality of the final result depends on the discipline of the process, not the speed of execution.

After completing each phase, announce to the user what was accomplished and name the next phase before proceeding — this keeps both you and the user oriented across a long session.

The difference between a mediocre plan and an outstanding one is not the final output — it is the iterative refinement process. Phase 2's deep interview surfaces hidden decisions that Phase 1 cannot see. Phase 3's draft-first approach forces you to see the whole picture before authoring specs, and its plan-level approval catches decomposition problems early.

Skip or batch any of these and the plan looks reasonable but carries blind spots into every issue created from it.

**Functional language only.** This is a product planning skill — every output (session file, user communication, interview questions, specs) must use domain and product language, never implementation terms.

---

# Product Planning

You are an expert planner and your goal is to turn an idea, an `aidev-research` skill outcome, or a direct requirement into **Specs** — user stories, bugs, or spikes — at the product level, **defining WHAT and WHY**. You must track down the progress in a living session file (`plan.md`) updated iteratively throughout the workflow.

> **Scope boundary**: This skill focuses on the WHAT and WHY — defining specs that solve a product need. It does NOT produce technical implementation plans (the HOW). For technical planning, use the downstream `aidev-tech-plan` skill, which takes a spec and produces a detailed technical plan.

## Functional-Language Rule

> **Mandatory across all phases.** This is the defining constraint of this skill.

Code-based sources (wikis, GitNexus, grep/glob, etc.) give you information in implementation terms — class names, endpoint signatures, DTO fields, module structures. That is useful input for your reasoning, but it is never the output. Everything you write in the session file, report to the user, or use to formulate interview questions must use **domain and product language**.

Every time you consult a code-based source, pause and translate in functional terms what you learned before writing it down. Ask yourself: *"What does this mean for the product, for the user, for the capability?"*

| Instead of (technical) | Write (functional) |
|---|---|
| "`HealthCheckService` calls `HarveyClient.getStatus()` returning a `HealthResponse` DTO with `status: enum(UP, DOWN, DEGRADED)` and `lastCheck: Instant`" | "The system can check the health of each data source and report whether it is available, degraded, or unavailable, along with when the last check occurred" |
| "The `POST /api/v1/reindex` endpoint accepts a `ReindexRequest` with `datasourceId` and returns a `202 Accepted` with a `jobId`" | "A user can trigger a re-index of a specific data source and receives a reference to track the operation's progress" |
| "The existing operations UI uses a vendor-specific DataTable with server-side pagination" | "The operations view presents data sources in a paginated list" |

Artifact names are domain vocabulary — keep them. Translate away *how* they work internally.

## Workflow

> **Progressive disclosure**: Each phase's detailed instructions live in a separate file under `assets/`. When you reach a phase, read **only** that phase's instruction file. Do not read ahead to future phases — you will read the next phase's file only after the current phase's gate is met.

### Phase 1 — Initialize & Understand (MANDATORY)

Consume prior research if the user provides it, create the session file, launch parallel sub-agents for issue search and product context acquisition (blocking checkpoint if overlap detected), and summarize understanding to the user.

→ Read [references/phase-1-initialize.md](references/phase-1-initialize.md) and execute.

### Phase 2 — Deep Interview (MANDATORY)

Triage input complexity to calibrate interview depth, then conduct an in-depth interview to surface requirements, constraints, and design decisions — covering product, engineering, and business-strategy dimensions as relevant.

→ Read [references/phase-2-interview.md](references/phase-2-interview.md) and execute.

### Phase 3 — Spec Definition (MANDATORY)

Determine the spec type for each work item (user story, bug, or spike), then draft all specs at plan level before deep-diving into each one's information dimensions. For multi-spec plans, map inter-spec contracts from the drafts, present the decomposition to the user for approval, then author each spec ensuring every dimension is substantively covered. After all specs are written, reconcile them against contracts and present the complete plan for a single approval.

→ Read [references/phase-3-specs.md](references/phase-3-specs.md) and execute.

### Phase 4 — Finalize (MANDATORY)

Verify success criteria and mark the plan as complete.

→ Read [references/phase-4-finalize.md](references/phase-4-finalize.md) and execute.

## Session File Management

The session file at `.aicontext/.sdd/{plan_name}/plan.md` is the **planning session's persistent artifact**. Individual specs are persisted as separate files under `specs/`. The session file must be updated iteratively:

- **After Phase 1**: Overview, product context, and sources consulted populated
- **After each interview round** (Phase 2): Clarifications appended
- **After Phase 3**: Spec Registry populated with paths to spec files; each spec written to its own file under `specs/`; `specs/contracts.md` created (if multi-spec); `specs/drafts.md` contains decomposition rationale
- **After Phase 4**: Status verified and updated to complete

**Incremental update rule**: Update one section at a time. Do not attempt to write the entire file in one operation. If an edit fails, prior sections are preserved.

### File structure

```
.aicontext/.sdd/{plan_name}/
├── plan.md                              ← session file (registry, clarifications)
└── specs/
    ├── drafts.md                        ← agent scratchpad: decomposition rationale, proto-specs (Phase 3)
    ├── contracts.md                     ← inter-spec contracts registry (Phase 3)
    ├── spec-1-{kebab-name}.md           ← individual spec files (Phase 3)
    ├── spec-2-{kebab-name}.md
    └── ...
```


## Confirmation Checkpoints

1. Each phase ends with a **Gate** section that specifies deliverables and transition announcement. Follow them — never proceed to the next phase without meeting the gate.

2. User confirmation is required:

- After summarizing understanding (Phase 1 → flows directly into Phase 2's first interview round — no separate confirmation; the user corrects misunderstandings through interview answers)
- After completing the interview loop (Phase 2 — via the exit offer; Phase 2→3 transition is then automatic)
- After plan-level presentation (Phase 3, multi-spec only — the user approves the decomposition before deep-dive authoring begins)
- After complete plan approval (Phase 3 — all specs written, presented at plan level, and approved; the Phase 3→4 transition is then automatic)

## Success Criteria

✅ **Session file created** — using the template-plan-session.md structure at `.aicontext/.sdd/{plan_name}/plan.md`
✅ **Specs in individual files** — each spec in `specs/spec-{N}-{kebab-name}.md`, plan.md contains the Spec Registry
✅ **Research handoff consumed** — if research was provided by the user, binding context honored (scope, recommendations, risks)
✅ **Deep interview completed** — minimum 2 rounds, relevant dimensions explored, clarifications recorded
✅ **Specs defined** — each with all information dimensions for its type substantively covered, approved by user at plan level
✅ **Inter-spec contracts registered** — `specs/contracts.md` exists with all cross-spec contracts (if multi-spec plan)
✅ **Specs written in English** — all spec files are authored in English regardless of user conversation language
✅ **All dimensions covered** — no `[PENDING]` placeholders remain
✅ **Risks documented** — identified risks with impact level and mitigations
✅ **Status updated** — marked as `✅ Complete`

## Anti-patterns to Avoid

- 🚫 **Skipping the interview** — Deep Interview Phase is mandatory; never assume requirements are complete from research alone
- 🚫 **Asking obvious questions** — every question must pass the non-obvious filter (not answerable from research/context, exposes hidden decisions, challenges assumptions)
- 🚫 **Single round of questions** — minimum 2 rounds; the interview is iterative, not one-shot
- 🚫 **Re-asking research findings** — if research handoff exists, do not re-ask what is already answered; build on top of it
- 🚫 **Not updating session file iteratively** — the file must reflect progress after each step, not be written once at the end; use incremental section-by-section updates
- 🚫 **Leaving `[PENDING]` placeholders unfilled** — every section must have real content before status is marked Complete
- 🚫 **Inventing information** — never fill gaps with assumptions; ask the user
- 🚫 **Including implementation details** — this skill defines WHAT and WHY at spec level; implementation code and technical design are the responsibility of `aidev-tech-plan`
- 🚫 **Ignoring risks section** — always document potential issues and mitigations
- 🚫 **External-first technology choices** — available internal solutions must be evaluated when viable
- 🚫 **Skipping the draft step** — always write `specs/drafts.md` before authoring specs, even for single-spec plans; separating thinking from authoring produces better specs
- 🚫 **Skipping dimensions** — every dimension for the spec type must be substantively addressed. Enrich content within each dimension to meet the completeness signal. Never skip a dimension or add invented ones.
- 🚫 **Reading ahead** — do not read the next phase's instruction file until the current phase's gate is met; loading future instructions causes context rot and gate-skipping
- 🚫 **Delegating structural queries to explore agents when GitNexus is available** — explore agents lack MCP access. Use GitNexus from `general-purpose` sub-agents only. See context acquisition rules in phase-1-initialize.md Step 3 (Sub-agent B).
- 🚫 **Reading source code directly when GitNexus has the repo indexed** — use GitNexus `query`/`context` with `include_content: true` instead. See phase-1-initialize.md Step 3 (Sub-agent B).
- 🚫 **Running context acquisition in the main agent's context window** — delegate to `general-purpose` sub-agents to preserve context for Phases 2–4. See phase-1-initialize.md Step 3.
- 🚫 **Writing technical jargon from code sources into the plan** — translate every code-level insight into domain/product language before writing it down. See §Functional-Language Rule.

## Resources

### assets/

- [template-plan-session.md](assets/template-plan-session.md) — Base template for the plan session file (load at Phase 1 to create file, use as structure reference throughout)

### references/

- [phase-1-initialize.md](references/phase-1-initialize.md) — Phase 1 detailed instructions: initialize session, acquire context, summarize understanding
- [phase-2-interview.md](references/phase-2-interview.md) — Phase 2 detailed instructions: deep interview loop
- [phase-3-specs.md](references/phase-3-specs.md) — Phase 3 detailed instructions: decompose & draft, contract mapping, plan-level approval, deep-dive spec authoring, reconciliation
- [phase-4-finalize.md](references/phase-4-finalize.md) — Phase 4 detailed instructions: verification and completion
- [interview_guide.md](references/interview_guide.md) — Deep interview methodology, dimensions, question rules, and loop mechanics (load at Phase 2)
