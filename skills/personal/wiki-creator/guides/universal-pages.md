# Universal Page Writing Guides

Per-page recipes for all pages generated regardless of detected stack. Read this file during Phase 5 (Write) of Full mode, or Phase 4 (Regenerate) of Incremental mode.

These recipes assume the writing standards in `SKILL.md §5` are already in force.

---

## `index.md` (Landing Page)

**Diátaxis type:** None (navigation hub — the only page that doesn't fit a quadrant).

**Purpose:** 60-second orientation + routing. Deliberately short.

**Required sections:**

```markdown
# {PROJECT_NAME} Developer Wiki

**{PROJECT_NAME}** is {one-sentence description with key tech stack}.

> **Repository:** [`{org}/{repo}`]({github_url}) · **Branch:** `main`

---

## Quick Start

{code block: clone + install + run — 3-5 commands max}

<!-- Sources: package.json (or equivalent) -->

---

## System at a Glance

{ONE Mermaid flowchart — top-level boxes only, no internals}

---

## Navigate This Wiki

| I need to… | Go to |
|---|---|
| Understand the architecture and why it's built this way | [Explanation → Architecture](./explanation/architecture.md) |
| Know what decisions were made and what constraints exist | [Explanation → Decisions](./explanation/decisions.md) |
| Look up an endpoint, entity, or config key | [Reference](./reference/api.md) |
| Learn how to extend the system (add endpoint, entity, etc.) | [How-to → Extend](./how-to/extend.md) |
| Know the code conventions and patterns | [How-to → Patterns](./how-to/patterns.md) |
| Set up my development environment | [Tutorial → Setup](./tutorial/setup.md) |
| Make my first contribution | [Tutorial → First Contribution](./tutorial/first-contribution.md) |
```

**Rules:**
- NO domain ER diagram, NO detailed request flow, NO routes table here.
- The architecture diagram is simplified (5-8 boxes max). Full version lives in `explanation/architecture.md`.
- Target: ~60 lines.

---

## Explanation Pages

### `explanation/architecture.md`

**Diátaxis type:** Explanation. Answers: "What is this system and why is it shaped this way?"

**Required sections:**

1. **"Why This Exists"** — 2-4 paragraphs. Business motivation, not feature list. What problem does it solve?

2. **"Tech Stack" table** — (aspect | choice | version | source)
   Language, framework, build tool, state management, auth, styling, testing. Exact versions from lockfiles.

3. **"High-Level Architecture" diagram** — Mermaid flowchart with semantic subgraph labels. Show major components and their relationships.
   - After diagram: **"Why this structure"** — 2-3 sentences explaining why these components exist and how they relate.

4. **"Domain Model Overview"** — Brief summary (3-5 sentences) + link to `reference/domain-model.md` for the full ER. Show a simplified ER here (top 5-7 entities max).

5. **"Request Lifecycle"** — Sequence diagram for the most representative request path. Explains how a request flows through the system end-to-end.

6. **"Key Directories"** table — (directory | responsibility | source). Group by layer.

7. **"What to Read Next"** — 3-4 bullets linking to the most relevant next pages.

Target: ~400-500 lines.

---

### `explanation/decisions.md`

**Diátaxis type:** Explanation. Answers: "Why were these choices made? What can't I change?"

**Required sections:**

1. **"Architectural Decisions" table** — (Decision | Choice | Rationale | Alternatives Rejected | Source)
   Order by impact: the decision that affects the most code first.

2. **"System Constraints"** — Things that MUST NOT be violated:
   - Provider/initialization ordering (if applicable)
   - Framework-imposed restrictions
   - Non-obvious invariants
   - Convention enforcement rules
   
   Format: bulleted list with **bold constraint** + explanation of what breaks if violated.

3. **"Failure Modes"** — How the system handles failure:
   - Error handling strategy (centralized vs. distributed)
   - Retry/circuit-breaker patterns
   - Graceful degradation paths
   - Health checks and readiness probes
   
   Include a sequence diagram for the most critical failure flow.

4. **"Security Model"** — Auth mechanism, authorization rules, token lifecycle, CORS. High-level: explain the approach and why.

5. **"What This Doesn't Cover"** — Explicit boundaries. What's out of scope for this system.

Target: ~400-600 lines.

---

## Reference Pages

### `reference/api.md`

**Diátaxis type:** Reference. Pure facts about endpoints.

**Required sections:**

1. **"Endpoints" table** — For ALL endpoints:
   | Method | Path | Handler | Auth | Request Body | Response | Source |
   
   Order by path hierarchy (group by resource).

2. **"Error Responses"** table — (status code | meaning | response shape | when)

3. **"Authentication"** — Brief statement of auth mechanism + link to `explanation/decisions.md` for the "why".

**Rules:**
- NO explanation of why endpoints exist. That's explanation territory.
- NO "how to call" guides. That's how-to territory.
- Every row has a Source column with file link.
- Target: variable (depends on API surface).

---

### `reference/domain-model.md`

**Diátaxis type:** Reference. Catalog of all entities and their shapes.

**Required sections:**

1. **"Entity Relationship Diagram"** — Full Mermaid `erDiagram` with all entities and relationships.

2. **Per-entity tables** — For each entity/model:
   | Field | Type | Required | Default | Validation | Description | Source |
   
   Order entities by importance (core domain first, supporting last).

3. **"Enums"** — For each enum:
   | Value | Description | Source |

4. **"DTOs & Mappers"** table — (DTO | Maps To/From | Transformer | Source)

**Rules:**
- NO "why we chose this model." Link to explanation for that.
- This is the canonical location for entity details. Other pages link here.

---

### `reference/configuration.md`

**Diátaxis type:** Reference. All config keys and commands.

**Required sections:**

1. **"Commands"** table — ALL available commands:
   | Command | Description | Source |

2. **"Configuration Keys"** — Grouped by category, one table per category:
   | Key | Type | Default | Required | Description | Source |

3. **"Environment Variables"** table — (variable | maps to | default | source)

4. **"Feature Flags"** table — (flag | description | default | source) — if applicable.

5. **"Key Files"** table — (file | purpose | source)

**Rules:**
- Include EVERY discoverable config key. Completeness matters here.
- NO explanation of why configs are set this way. Link to `explanation/decisions.md`.

---

### `reference/integrations.md`

**Diátaxis type:** Reference. Facts about external services.

**Required sections:**

1. **"Integration Inventory"** table — (service | purpose | auth mechanism | base URL config | timeout | source)

2. **Per-integration data flow** — Mermaid sequence diagram showing request/response. One per integration (or group trivial ones).

3. **"Failure Handling"** table — (service | retry policy | circuit breaker | fallback | source)

**Rules:**
- Skip if zero external integrations.
- NO "why we use service X." That's explanation.

---

## How-to Pages

### `how-to/extend.md`

**Diátaxis type:** How-to. Goal-oriented recipes for extending the system.

**Structure:**

Start with a lookup table:

```markdown
## Recipe Index

| I want to… | Recipe |
|---|---|
| Add a new API endpoint | [Add Endpoint](#add-endpoint) |
| Add a new domain entity | [Add Entity](#add-entity) |
| Add a new external integration | [Add Integration](#add-integration) |
| Add a new background job/worker | [Add Worker](#add-worker) |
```

Then one H2 per recipe:

```markdown
## Add Endpoint

**Prerequisites:** Familiarity with [Architecture](../explanation/architecture.md) and [Patterns](./patterns.md).

**Steps:**
1. Create handler/controller in `{path}` following naming convention `{convention}`
2. Define request/response types in `{path}`
3. Add route to router config in `{file}:{line}`
4. Add auth/middleware (see [Decisions](../explanation/decisions.md#security-model))
5. Add test in `{test_path}` using pattern from [Patterns](./patterns.md#testing)
6. Update API docs if maintained separately

<!-- Sources: {relevant files} -->
```

**Rules:**
- Every step references exact file paths from the codebase.
- Steps are numbered and imperative ("Create", "Add", "Wire").
- Link to explanation for background; don't explain inline.
- Include recipes for the most common 4-6 extension scenarios. Archetype modules add more.

---

### `how-to/patterns.md`

**Diátaxis type:** How-to. Conventions to follow when writing code in this repo.

**Required sections:**

1. **"File & Directory Conventions"** — (pattern | example | applies to)

2. **"Naming Conventions"** — (element | convention | example | source)

3. **"Code Patterns"** — For each pattern, show ✅ Correct and ❌ Wrong examples drawn from the actual codebase:
   - Error handling pattern
   - Data access pattern
   - State management pattern (if applicable)
   - Dependency injection pattern

4. **"Testing Conventions"** — (aspect | convention | example | source)
   - Test file location
   - Test naming
   - Mock/stub approach
   - What to test vs. not test

5. **"Workflow"** — Branch naming, commit messages, PR process, CI checks.

**Rules:**
- Every convention must have a real source file example.
- This is "how to follow the rules," not "why these rules exist" (that's explanation).

---

## Tutorial Pages

### `tutorial/setup.md`

**Diátaxis type:** Tutorial. Guided learning: get the project running.

**Required sections:**

1. **"Prerequisites"** table — (requirement | version | install via | verify with)

2. **"Step-by-step Setup"** — Numbered steps with copy-pasteable commands. Each step has:
   - What to run
   - What you should see (expected output)
   - What to do if it fails (brief troubleshooting)

3. **"Development Server"** — Command + expected URL + hot-reload behavior.

4. **"Build & Test"** — Commands to build and run tests. Expected output.

5. **"IDE Setup" (optional)** — Only if the project has specific IDE requirements (plugins, settings).

**Rules:**
- Assume the reader has NEVER seen this project.
- Every command must work if copy-pasted in order.
- No shortcuts, no "you probably already know this."
- Target: ~150-250 lines.

---

### `tutorial/first-contribution.md`

**Diátaxis type:** Tutorial. Guided learning: make your first PR.

**Required sections:**

1. **"What You'll Build"** — One sentence describing a small, representative change.

2. **"Walkthrough"** — Step-by-step, from `git checkout -b` to PR merged:
   - Create branch
   - Make the change (specific example)
   - Run tests
   - Commit (with correct message format from `how-to/patterns.md`)
   - Push + create PR
   - What CI checks will run

3. **"Glossary"** — 20-40 domain-specific terms used in this codebase:
   | Term | Definition |

**Rules:**
- The walkthrough example should be something small but real (not "add a console.log").
- Link to `how-to/patterns.md` for the conventions, don't repeat them.
- Target: ~300-500 lines.
