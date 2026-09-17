# Phase 3 — Spec Definition

> This file contains the complete instructions for Phase 3. Do not read other phase instruction files until this phase's gate is met.

## Spec type determination

Before writing any spec, determine the **type** of each work item that emerged from Phases 1-2. Each work item maps to exactly one spec type:

| Spec type        | Icon | When to use                                                                 |
|------------------|------|-----------------------------------------------------------------------------|
| **User Story**   | 🧩   | A new capability, behaviour, or enhancement to be built                     |
| **Bug**          | 🐞   | A defect to be corrected — something that is broken or behaves incorrectly  |
| **Spike**        | 🔍   | A research task to reduce uncertainty before committing to implementation   |

### Required information dimensions per spec type

Each spec MUST cover all dimensions listed below for its type. Every dimension must be substantively addressed — the **completeness signal** tells you when a dimension has been adequately covered.

**User Story** (🧩):

| Dimension | What it must cover | Completeness signal |
|-----------|--------------------|---------------------|
| **Persona & Intent** | Who the user is and what action/outcome they seek | Expressible as "As a ___, I want to ___" |
| **Value Proposition** | What problem this solves, how the user's experience improves | A stakeholder understands the "why" without asking |
| **Narrative Summary** | Concise description (2-3 sentences) focused on user value | Readable in <15 seconds, communicates scope |
| **Verifiable Outcomes** | Testable acceptance criteria as observable product behaviors | Each criterion is verifiable without knowing the implementation |
| **Scope Boundaries** | Explicit exclusions that prevent scope creep | Someone unfamiliar knows what is NOT included |
| **Supporting Context** | Research, screenshots, prior art, or notes informing the spec | Whoever executes has all background they need |

**Bug** (🐞):

| Dimension | What it must cover | Completeness signal |
|-----------|--------------------|---------------------|
| **Problem Statement** | What is broken (1-2 sentences) | Anyone understands the defect immediately |
| **Defect Characterization** | Scope (which capabilities affected), root cause (if known), impact (who, how severely) | Bug can be prioritized without further investigation |
| **Reproduction Path** | Numbered steps to reproduce the problem | A QA/dev can reproduce on first attempt |
| **Expected Behavior** | What should happen — concrete and verifiable | Not "should work correctly" but a specific observable outcome |
| **Verifiable Resolution** | Acceptance criteria confirming the fix works (When/Then pattern) | A test can be written from each criterion |
| **Dependencies** | Other work required before this can be fixed | Team knows whether to start or wait |
| **Evidence** | Screenshots, logs, stack traces, reproduction data | Enough to diagnose without requesting more info |
| **Related Work** | Related issues, PRs, or epics | Broader context of the defect is understood |

**Spike** (🔍):

| Dimension | What it must cover | Completeness signal |
|-----------|--------------------|---------------------|
| **Knowledge Gap** | What we don't know (1-2 sentences) | The gap is concrete, not generic "investigate X" |
| **Context & Motivation** | Why research is needed and what it unblocks | A PM understands the value of investing time |
| **Research Questions** | Specific questions with success criteria per question | Each question has a definable answer (not open-ended exploration) |
| **Investigation Plan** | Concrete investigation activities | Someone can start without asking "what do I do?" |
| **Expected Deliverables** | What the spike delivers (recommendation, prototype, decision log) and what decision it unblocks | Outcome is tangible and reviewable |
| **Verifiable Completion** | How to know the spike succeeded | Not "when time runs out" but clear criteria |
| **Dependencies** | Tools, data, systems, or people required | Can be provisioned before starting |
| **Scope Boundaries** | What will explicitly NOT be researched | Prevents rabbit holes and investigative scope creep |
| **Supporting Context** | Notes, diagrams, links, prior research | Researcher doesn't start from zero |
| **Related Work** | Parent Story/Epic or related research | Spike's place in the larger plan is clear |

Classification rules:
1. Derive the type from the interview clarifications and context gathered in Phases 1-2. Most work items will have a clear type.
2. If a work item is ambiguous (e.g., it could be a user story or a spike), **ask the user** — do not guess.
3. A single planning session may produce specs of mixed types (e.g., two user stories and one spike). This is expected.

---

## Step 1 — Decompose & Draft

Before diving into dimensions, step back and think about the plan as a whole. Write your thinking to `specs/drafts.md` — this is your private scratchpad. No format constraints.

For each spec, capture:
- **Scope**: what it covers, what it doesn't
- **Functional outcomes**: what must this spec deliver? Plain-language outcomes, not formal requirements — but specific enough that each outcome names what happens and what it touches. E.g., “Health status computed from Harvey data”, “Health status visible in operations view”, “Harvey-unreachable preserves stale data.” They’ll be refined into the spec’s dimensions in Step 4 (bugs: Defect Characterization; spikes: Research Questions; user stories: Persona & Intent, Narrative Summary, and Verifiable Outcomes).
- **Affected artifacts**: which repositories or components are touched
- **Edge cases and open questions**: anything unresolved

For single-spec plans, the draft is lighter — but still write it. Separating “what is this spec about?” from “how do I cover each dimension thoroughly?” produces better specs.

Set status to `🔄 Spec Definition`.

---

## Step 2 — Map Contracts (multi-spec only)

From the drafts, identify every data flow, shared model, or capability that crosses a spec boundary. Create `specs/contracts.md` — the **single source of truth** for inter-spec contracts.

Initial contracts may be provisional — field names get refined during deep-dive authoring. What matters is that **ownership and direction are established before specs define shared concepts**.

For single-spec plans: skip this step — do not create the file.

Column definitions:
- **Producer**: The spec that provides the capability
- **Consumer**: The spec that depends on the capability
- **Contract**: Brief name for what is exchanged
- **Information exchanged**: What information flows across the boundary, described in domain language — not technical types or field names. Name the concepts the consuming capability depends on for correctness (e.g., "datasource identifier, job status with values: pending/running/done/error"). Do not prescribe types, schemas, or serialization — those are implementation decisions for tech-plan.
- **Nature**: The kind of interaction from a user/product perspective (e.g., "user-initiated action with status tracking", "background data refresh", "on-demand query"). Do not prescribe exchange mechanisms (REST, events, etc.) — those are tech-plan decisions.

Format:

```markdown
# Spec Contracts

| Producer | Consumer | Contract | Information exchanged | Nature |
|----------|----------|----------|-----------------------|--------|
| Spec 1 — Datasource health | Spec 2 — Re-index action | Re-index trigger | Datasource identifier, job identifier, job status (pending/running/done/error) | User-initiated action with status tracking |
| Spec 1 — Datasource health | Spec 3 — Operations view | Job listing | List of jobs with: datasource identifier, status, creation time, error detail (if any) | On-demand query |
```

---

## Step 3 — Present Plan to User (multi-spec only)

Present the decomposition at plan level. The user validates the **logic and structure**, not template details. Keep it concise — the goal is a view the user can evaluate in under 2 minutes:

1. **Why this decomposition** — 2-3 sentences on why you drew the boundaries this way
2. **Spec overview** — one line per spec: name, type icon, scope in plain language
3. **Key relationships** — which specs depend on which, what flows between them
4. **Affected artifacts** — per spec, which artifacts are touched (one line each)
5. **Key decisions** — anything non-obvious the user should validate (tradeoffs, scope boundaries)

Ask for approval using the assistant's native interactive question tool:

*"Does this decomposition match what you need? If any boundaries are wrong, I'll adjust before writing the full specs."*
- "Looks good — proceed"
- "I have changes"

If the user requests changes (different boundaries, missing specs, wrong scope), adjust drafts.md and contracts.md before proceeding.

For single-spec plans: skip this step — proceed directly to Step 4.

---

## Step 4 — Deep-Dive Spec Authoring

Now fill the full specs. The structural decisions are settled — which specs exist, what each covers, and how they connect. But the detail work happens here: the spec’s dimensions are authored during this step, not copied from the draft. Each spec type has different information dimensions — refer to the §Required information dimensions per spec type table to know exactly which ones to cover.

For each spec:

1. **Re-read** `specs/drafts.md` and `specs/contracts.md` (if multi-spec) to re-anchor in the whole picture.
2. **Author** the spec covering every dimension for its type and following the authoring rules below. Build the spec’s content fresh from draft outcomes, contracts, and interview clarifications.
3. **Write** the spec to its own file under `specs/`.
4. **Update contracts live**: if a new shared concept emerges during authoring, update `contracts.md` FIRST — then use that definition in the spec. Do NOT modify already-written spec files; they will be reconciled in Step 5.

### Authoring rules

- **English only** — spec content must always be written in English, regardless of the language used to communicate with the user.
- One spec per work item, product-level scope.
- Never invent missing information — **ask** during spec authoring. If information doesn't exist in the plan, note the gap in `## Planning Notes`.
- Use the completeness signals in the dimension tables to judge whether each dimension has been adequately covered.
- Spec content must be functional product context — what the product does and why this spec matters. Do not copy source links or code references into any spec section; those live in `### Sources consulted` in plan.md. If you discover new sources while defining a spec, add them to `### Sources consulted`, not to the spec body.
- After all dimensions are covered, append a **generated-by footer** at the end of the spec body:
  ```

  ---
  > Generated by {skill_name} v{skill_version}
  ```
  Where `{skill_name}` and `{skill_version}` come from this skill’s own SKILL.md frontmatter (`name` and `metadata.version`). Ensure there is a blank line before the `---` so it renders as a horizontal rule. This footer becomes part of the spec file on disk and flows through to the GitHub issue body as-is.
- Record in `## Planning Notes` any significant discoveries during spec scoping — particularly cross-spec connections, shared components, or constraints that aren't obvious from the specs alone. Prefix with `[Phase 3]`.
- For multi-spec plans, `contracts.md` is the single definition of shared concepts. Specs consume those definitions — same names, same ownership. Never redefine a contracted concept independently in a spec.
- After completing each spec, verify internal consistency: every dimension should align with the others. For bugs: Reproduction Path, Expected Behavior, and Verifiable Resolution must be consistent with the Defect Characterization. For spikes: Investigation Plan must address each Research Question, and Verifiable Completion must verify the Expected Deliverables. For user stories: every outcome in Persona & Intent and Narrative Summary should be covered by at least one Verifiable Outcome — if an outcome introduces scope not reflected in Persona & Intent or the Summary, update them to match.

### Writing specs to individual files

Each spec is written to its own file under the `specs/` directory:

- **Path**: `<workspace_root>/.aicontext/.sdd/{plan_name}/specs/spec-{N}-{kebab-name}.md`
- **Naming**: `{N}` is the spec number (1, 2, 3...), `{kebab-name}` is a short kebab-case identifier derived from the spec title (e.g., `spec-1-status-visibility.md`, `spec-2-reindex-action.md`)
- Create the `specs/` directory if it does not exist.
- The spec file contains the **complete spec** — every dimension covered per §Required information dimensions per spec type. The file IS the spec. It is plain markdown with no frontmatter — just content organized under clear headings.
- **Update the Spec Registry** in plan.md: after writing each spec file, add an entry to `## Spec Registry` in the session file with the spec number, type icon, title, and file path.

---

## Step 5 — Reconcile (multi-spec only, automatic)

After all specs are written, contracts.md may have evolved during deep-dives (new fields, refined types, shifted ownership). Sweep through and ensure every spec reflects the final state:

1. Read `specs/contracts.md` in full.
2. For each contract, verify the producer spec’s relevant dimensions define what the contract says it produces, and the consumer spec references what the contract says it consumes (bugs/spikes: Dependencies and core dimensions; user stories: Scope Boundaries, Supporting Context, and Verifiable Outcomes).
3. Fix any spec that is behind `contracts.md` — add missing fields, correct ownership statements, align terminology.

This is a directed sweep, not a re-evaluation. The contracts are the source of truth; the specs must match.

For single-spec plans: skip this step.

---

## Step 6 — Present & Gate

Present the complete plan to the user. The goal: the user sees the whole picture and can judge whether this plan solves their problem. Frame everything from the user's perspective — what they get, what they don't get, what could be wrong.

**Multi-spec presentation:**

1. **Why this plan** — 2-3 sentences on what we're building and why these pieces
2. **Spec overview** — a scannable table:

   | # | Type | Name | Scope (1 line) | Key deliverable |
   |---|------|------|----------------|-----------------|

3. **What you'll be able to do** — 3-5 user-facing outcomes when all specs are implemented. Not AC language — plain outcomes. E.g., "Trigger a re-index from the SPA and monitor its progress in real time."
4. **What’s NOT covered** — aggregated scope exclusions from all specs: Scope Boundaries dimensions (user stories and spikes) and the scope aspect in Defect Characterization (bugs). This is where users catch missing scope fastest.
5. **Key dependencies** — which specs block which, critical path across the plan. Not every contract — just what matters for sequencing and risk.
6. **Risks & assumptions** — what could be wrong, what was assumed. Users are great at spotting wrong assumptions.

**Single-spec presentation:**

1. **What and why** — 2-3 sentences
2. **Scope** — what's in, what's out
3. **What you'll be able to do** — user-facing outcomes
4. **Risks & assumptions** — what could be wrong

End with a structured approval using the assistant's native interactive question tool:

*"Does this match what you need? If anything is missing or wrong, I'll adjust the specs before we continue."*
- "Looks good — proceed"
- "I have changes"

If the user requests changes, modify the affected spec file(s), update `contracts.md` if needed, and re-present the changed elements.

## Gate

Before proceeding, verify:
- `specs/drafts.md` exists with decomposition rationale
- `specs/contracts.md` created with all inter-spec contracts (if multi-spec plan)
- All specs written to individual files per §Required information dimensions per spec type
- Spec Registry in plan.md populated
- Reconciliation complete — all specs match final `contracts.md` (if multi-spec plan)
- User has approved the plan via Step 6 presentation

Announce: **“Phase 3 complete — all specs drafted and approved. Proceeding to Phase 4 — Finalize.”** Then read `phase-4-finalize.md` and execute.
