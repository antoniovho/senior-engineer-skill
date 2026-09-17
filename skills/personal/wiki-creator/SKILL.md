---
name: wiki-creator
description: >
  Generates a complete project code wiki from scratch OR updates an existing one incrementally.
  If no wiki exists, generates it. If a wiki exists and there are code changes, updates only
  affected pages. NEVER refuses to run — always produces output. Documents architecture, APIs,
  domain models, extension recipes, and onboarding guides. Automatically detects the project's
  technology (React, Spring Boot, Go, Python, iOS, Android) and adapts content accordingly.
  Use when: you need documentation for a codebase, onboarding material, or want to keep
  docs updated as code evolves.
---

# Wiki Creator

Generate or update a deployable VitePress documentation site organized around four documentation types that serve four distinct needs:

| Section | Need | Question it answers | Consumer |
|---------|------|---------------------|----------|
| **Explanation** | Understanding | "Why does this work this way?" | AI (context) + Humans (onboarding) |
| **Reference** | Information | "What exists? What are the facts?" | AI (catalog) + Humans (lookup) |
| **How-to** | Action (goal-oriented) | "How do I accomplish X?" | AI (code gen) + Humans (daily work) |
| **Tutorial** | Learning (guided) | "Teach me from scratch" | Humans (first-time setup) |

**Progressive disclosure:** SKILL.md is the router. Per-page recipes live in `guides/universal-pages.md`, validation rules in `guides/validation.md`, archetype-specific page structure in `modules/archetypes/{archetype}.md`, and language search guidance in `modules/hints/{hint}.md`. Read those files only when entering the phase that uses them.

---

## §1 Design Principles

- **Diátaxis separation is sacred.** Never mix documentation types. A page is either explanation, reference, how-to, or tutorial — never a blend. If you catch yourself putting a "why" paragraph in a reference page, move it to explanation and link.
- **Importance-first ordering.** Within every page, section, and table: lead with what matters most.
- **Density over volume.** Every paragraph must carry information an agent or developer cannot easily infer from reading source code. No filler.
- **Explain once, cross-reference elsewhere.** Each concept has ONE canonical location. Other pages link to it.
- **Structure reveals architecture.** Headings and section order mirror the system's dependency and importance hierarchy.
- **Configuration is content.** Config-heavy applications get config documented as thoroughly as code.
- **Archetype-aware depth.** Universal pages provide cross-cutting documentation. Archetype-specific pages dive deep into patterns unique to the detected repo type.
- **Minimal diff (incremental).** In incremental mode, only touch pages actually affected by code changes.
- **Safe to re-run.** Running this skill twice on the same branch produces the same result.

---

## §2 Mode Detection

**CRITICAL: If no wiki exists, generate one from scratch.**

| Condition | Mode | Action |
|-----------|------|--------|
| Wiki directory does NOT exist | **Full** | Generate complete wiki from scratch |
| Wiki directory exists but `.manifest.json` missing or unreadable | **Full** | Regenerate (warn user) |
| User says "generate from scratch" / "full wiki" / "generate the wiki" | **Full** | Generate complete wiki |
| Wiki exists + `.manifest.json` + on branch with diff vs base | **Incremental** | Update only affected pages |
| User says "update wiki" / "incremental" / "patch wiki" | **Incremental** | Update only affected pages |
| Wiki exists + `.manifest.json` + NO diff (on base branch, no changes) | **Full** | Treat as fresh generation (overwrite) |

**Rules:**
- NEVER tell the user to use a different skill. This skill handles both full generation and incremental updates.
- NEVER report "prerequisites not met." If no wiki exists, that IS the trigger for Full mode.
- If on `main` with no diff and no wiki → **Full mode** (the user wants to generate the wiki).
- If on `main` with no diff and wiki exists → **Full mode** (regenerate/overwrite).
- When in doubt between Full and Incremental: if the wiki directory exists with a valid manifest AND there are code changes vs base branch, use Incremental. Otherwise, Full.

---

## §3 Archetype & Hint Detection

During Phase 1 (Scan), detect the project's **archetype** (what type of repo) and **hint** (what language/framework):

| Marker | Archetype | Hint |
|--------|-----------|------|
| `package.json` contains `koa` \| `express` \| `fastify` \| `hono` \| `@amiga-fwk-nodejs/core` (without `react-dom`) | `archetypes/backend-api.md` | `hints/node.md` |
| `pom.xml` contains `spring-boot-starter` | `archetypes/backend-api.md` | `hints/spring-boot.md` |
| `go.mod` exists + HTTP router in imports | `archetypes/backend-api.md` | `hints/go.md` |
| `pyproject.toml` contains `fastapi` \| `flask` \| `django` | `archetypes/backend-api.md` | `hints/python.md` |
| `package.json` contains `react-dom` + (`vite` \| `webpack`) | `archetypes/frontend-spa.md` | `hints/react.md` |
| `Package.swift` exists + app target | `archetypes/mobile.md` | `hints/ios.md` |
| `build.gradle.kts` contains `com.android.application` | `archetypes/mobile.md` | `hints/android.md` |

**Rules:**
- Detection is performed ONCE during full generation and recorded in `.manifest.json` (fields: `archetype`, `hint`).
- In incremental mode, archetype and hint are read from `.manifest.json` — never re-detected.
- Multi-archetype supported (monorepos): a repo can activate multiple archetypes with their respective hints.
- If no archetype detected, generate only universal pages.
- After detection: read the archetype file for page structure, then read the hint file for search guidance.

---

## §4 Output Structure

```
{output_dir}/                          # default: wiki/
├── .gitignore
├── .manifest.json                     # Source map + archetype/hint metadata
├── package.json                       # VitePress + mermaid plugin
├── .vitepress/
│   ├── config.mts                     # VitePress config (dark theme, sidebar, nav, mermaid)
│   ├── theme/
│   │   ├── index.ts                   # Custom theme with medium-zoom
│   │   └── custom.css                 # Dark mode variables + mermaid overrides
│   └── public/
│       └── logo.svg                   # Placeholder logo
├── index.md                           # Landing page (Quick Start + navigation map)
├── explanation/                       # WHY — understanding the system
│   ├── architecture.md                # System purpose, tech stack, high-level diagrams, domain model
│   ├── decisions.md                   # ADRs, constraints, failure modes, invariants
│   └── {archetype-specific}.md        # e.g., data-layer.md, state-management.md, middleware-chain.md
├── reference/                         # WHAT — facts, tables, catalog
│   ├── api.md                         # All endpoints, request/response shapes, auth
│   ├── domain-model.md                # ER diagram, entities, enums, DTOs, mappers
│   ├── configuration.md              # Config keys, env vars, commands, feature flags
│   └── integrations.md               # External services, auth mechanisms, data flow
├── how-to/                            # HOW — goal-oriented recipes
│   ├── extend.md                      # Step-by-step recipes: add endpoint, entity, integration...
│   ├── patterns.md                    # Code conventions, naming, testing, branching, linting
│   └── {archetype-specific}.md        # e.g., backend-recipes.md, frontend-recipes.md, mobile-recipes.md
└── tutorial/                          # LEARN — guided, step-by-step
    ├── setup.md                       # Prerequisites, installation, dev server, build, test
    └── first-contribution.md          # First PR walkthrough + glossary
```

### Section boundaries (Diátaxis enforcement)

| Content type | Goes in | NEVER in |
|-------------|---------|----------|
| "Why we chose X over Y" | `explanation/decisions.md` | reference, how-to |
| "List of all endpoints" | `reference/api.md` | explanation, how-to |
| "Step-by-step: add an endpoint" | `how-to/extend.md` | reference, explanation |
| "Install and run the project" | `tutorial/setup.md` | how-to (it's learning, not work) |
| "ER diagram with all entities" | `reference/domain-model.md` | explanation (explanation links to it) |
| "Architecture diagram" | `explanation/architecture.md` | reference |
| "Naming conventions" | `how-to/patterns.md` | explanation |
| "Failure modes & circuit breakers" | `explanation/decisions.md` | reference |

### Archetype-specific pages placement

Archetype-specific pages split into two categories:
- **Explanation pages** (how a subsystem works): go in `explanation/`. E.g., `explanation/middleware-chain.md`, `explanation/state-management.md`
- **How-to pages** (recipes specific to the archetype): go in `how-to/`. E.g., `how-to/backend-recipes.md`, `how-to/mobile-recipes.md`

Each archetype file specifies which pages go where.

---

## §5 Writing Standards

### Universal Rules (1–10)

1. **Every page starts with VitePress frontmatter:**
   ```yaml
   ---
   title: "Page Title"
   description: "One-sentence description."
   ---
   ```

2. **Tables are the primary structured format.** Use tables for: tech stack, commands, model fields, API endpoints, config values, enum values, routes, key files.

3. **Narrative context before every table/diagram:** 3-5 sentences explaining WHY this exists and HOW it relates to the system. In reference pages, keep narrative minimal (1-2 sentences max).

4. **Mermaid theme is global.** Do NOT add `%%{init}` theme blocks to individual diagrams — the theme is configured once in `.vitepress/config.mts` and applies to all diagrams automatically.

5. **Sequence diagrams ALWAYS use `autonumber`.**

6. **Source citations follow claims.** Two formats:
   - `<!-- Sources: file.ts:line-range -->` after diagrams and major sections
   - `[file.ts:line](https://github.com/{org}/{repo}/blob/main/file.ts#Lline)` inside table cells

7. **Cross-reference pages** with relative Markdown links. When the same concept could go in two pages, pick the canonical location per Diátaxis type and link from elsewhere.

8. **No `<details>` collapsible sections** — AI agents read linearly.

9. **No per-node `style` directives in Mermaid** unless a specific node must stand out.

10. **Importance-first ordering** inside pages: order H2s and table rows by criticality.

### Diátaxis-specific Rules (11–14)

11. **Explanation pages:** Lead with WHY, then show HOW the system works (diagrams, flows). End with "Implications" or "Constraints" that other pages depend on.

12. **Reference pages:** Pure facts. Minimal narrative (1-2 sentences per section max). Dense tables. No opinions, no rationale. Link to explanation for the "why".

13. **How-to pages:** Goal in the title. Numbered steps. Prerequisites stated upfront. No lengthy explanation — link to explanation pages for background.

14. **Tutorial pages:** Assume zero context. Ordered steps. Every command is copy-pasteable. Success criteria stated ("you should see X"). No side-quests.

### Incremental-Only Rules (15–19)

15. **Preserve page structure.** Keep same H2 sections unless code changes warrant adding/removing.

16. **Update citations.** All source comments and inline links must point to lines that currently exist.

17. **Remove dead references.** If a cited file was deleted, remove its citation and dependent content.

18. **Add new content.** New files in scope → add to relevant tables/diagrams.

19. **Cross-reference integrity.** If you rename a heading, update `#anchor` links in other pages.

---

## §6 Full Generation Mode

**Execute all phases sequentially without stopping for confirmation.**

### Phase Overview

| Phase | Name | Purpose | Outputs |
|-------|------|---------|---------|
| 1 | **Scan** | Read codebase, detect archetype + hint, extract metadata | Internal: project profile |
| 2 | **Extract** | Catalog domain model, APIs, patterns, config | Internal: domain catalog |
| 3 | **Plan** | Design page structure per Diátaxis | Internal: content plan |
| 4 | **Scaffold** | Generate VitePress infrastructure | `.vitepress/`, `package.json` |
| 5 | **Write** | Generate all content pages | All `.md` files |
| 6 | **Validate** | Verify per `guides/validation.md` | Fixes in-place |

---

### Phase 1 — Scan

**Goal:** Build a complete mental model of the codebase and detect archetype + hint.

**Steps:**

1. Read project root manifests (`package.json` / `pom.xml` / `pyproject.toml` / `go.mod` / `build.gradle.kts` / `Package.swift`) to identify:
   - Project name, version, description
   - Language and framework versions (exact from lockfiles)
   - Build tool and scripts
   - Test framework
   - Key dependencies

2. **Detect archetype + hint** per [§3](#3-archetype--hint-detection). Record `archetype` and `hint`.

3. **Load archetype + hint** — For each detected archetype, read `modules/archetypes/{archetype}.md` and `modules/hints/{hint}.md`.

4. Read directory tree (2 levels deep) to map project structure.

5. Read entry point(s) to identify: bootstrap sequence, config loading, router/routes.

6. Read configuration files: `.env`, `application.yml`, `config/`, CI/CD files, deployment manifests.

7. Read test configuration to understand testing patterns.

8. Identify the **repository GitHub URL** from package manifest or `.git/config`.

**Internal output:** Project profile with: `name`, `version`, `description`, `language`, `framework`, `build_tool`, `archetype`, `hint`, `github_url`, `commands`, `directory_map`, `entry_points`, `key_config_files`.

---

### Phase 2 — Extract

**Goal:** Catalog every entity, endpoint, pattern, config key, integration, and failure mode. Tag each item as **critical / important / supporting**.

**Steps:**

1. **Domain model** — entities, fields, types, required/optional, defaults, validations, enums, relationships, mappers. Record exact file paths and lines.

2. **API contracts** — HTTP method, path, handler, params, request/response shapes, middleware, error responses.

3. **Architectural patterns** — state management, data fetching, auth flow, module system, error handling, caching.

4. **Configuration** — ALL config keys: name, type, default, description, required/optional. Env var mappings. Feature flags. Secret references (names only).

5. **Integrations** — external services, auth mechanism per service, request/response flow, timeout/retry/circuit-breaker.

6. **Conventions** — file naming, test patterns, commit/branch conventions, linting config, styling approach.

7. **Failure modes** — error handling patterns, retry logic, fallbacks, circuit breakers, health checks.

8. **Tool/agent rules** — Check for `.clinerules`, `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.copilot-instructions.md`.

9. **Constraints** — framework-imposed restrictions, provider ordering, non-obvious behaviors, deprecated patterns.

10. **Importance tagging:**
    - **Critical** — core domain logic, main architectural patterns, entry points, primary APIs
    - **Important** — secondary flows, configuration, integrations, error handling
    - **Supporting** — utilities, helpers, internal tooling, CI/CD details

---

### Phase 3 — Plan

**Goal:** Design page structure following Diátaxis, incorporating archetype-specific pages.

**Rules:**

1. **`index.md`** — Navigation hub only. Quick Start block + architecture diagram (simplified) + "Where to go" table. NO deep content.

2. **`explanation/`** section:
   - `architecture.md` — ALWAYS. System purpose, tech stack table, high-level architecture diagram, domain model overview (summary + link to reference/domain-model.md), request lifecycle.
   - `decisions.md` — ALWAYS. Decision log, constraints, failure modes, invariants, rationale for major choices.
   - Archetype-specific explanation pages (defined in the active archetype file).

3. **`reference/`** section:
   - `api.md` — ALWAYS (skip if zero endpoints).
   - `domain-model.md` — ALWAYS. Full ER diagram, all entity tables, enum tables, mapper tables.
   - `configuration.md` — ALWAYS (skip if < 5 config keys). All config keys + env vars + commands.
   - `integrations.md` — ALWAYS (skip if zero external integrations).
   - Archetype-specific reference pages (if defined in the active archetype file).

4. **`how-to/`** section:
   - `extend.md` — ALWAYS. Consolidated recipes: add endpoint, add entity, add integration, etc.
   - `patterns.md` — ALWAYS. Code conventions, naming, testing, workflow patterns.
   - Archetype-specific how-to pages (defined in the active archetype file).

5. **`tutorial/`** section:
   - `setup.md` — ALWAYS. Prerequisites, step-by-step setup, dev server, build, test, lint.
   - `first-contribution.md` — ALWAYS. First PR walkthrough + glossary.

6. **Sidebar ordering:** Explanation → Reference → How-to → Tutorial.

7. **Anti-repetition rule:** Each fact lives in ONE canonical page per Diátaxis type. Summary + link from elsewhere.

8. **Page count target:** 9–15 universal pages + archetype-specific pages. Aim for ~20,000–35,000 words total.

---

### Phase 4 — Scaffold

**Goal:** Generate VitePress infrastructure using pre-built assets.

#### Step 1 — Copy static assets

Copy `assets/static/` into `{output_dir}/`:
```
assets/static/.gitignore                   → {output_dir}/.gitignore
assets/static/.vitepress/theme/custom.css  → {output_dir}/.vitepress/theme/custom.css
assets/static/.vitepress/theme/index.ts    → {output_dir}/.vitepress/theme/index.ts
assets/static/.vitepress/public/logo.svg   → {output_dir}/.vitepress/public/logo.svg
```

#### Step 2 — Generate `package.json` from template

Read `assets/templates/package.json.template` and substitute:
- `{{PROJECT_NAME}}` → project name (kebab-case)

#### Step 3 — Generate `.vitepress/config.mts` from template

Read `assets/templates/config.mts.template` and substitute:
- `{{PROJECT_NAME}}` → project display name
- `{{PROJECT_DESCRIPTION}}` → one-sentence description
- `{{BASE}}` → `'/'`
- `{{GITHUB_URL}}` → full GitHub repository URL
- `{{SIDEBAR}}` → generated sidebar configuration

**Sidebar generation rules:**
- Order: **Explanation → Reference → How-to → Tutorial**
- Each group has `collapsed: false`
- Only include pages that were actually generated

---

### Phase 5 — Write

**Goal:** Generate all content pages with maximum quality.

**Read first:** `guides/universal-pages.md` for per-page recipes. For each active archetype, the writing guides in `modules/archetypes/{archetype}.md` and search guidance in `modules/hints/{hint}.md`.

**Process per page:**
1. Determine Diátaxis type (explanation/reference/how-to/tutorial).
2. Follow the recipe from `guides/universal-pages.md` or the active module file.
3. **Enforce Diátaxis boundaries:** if you're writing "why" in a reference page, stop — that belongs in explanation. If you're writing steps in an explanation page, that belongs in how-to.
4. Lead every section/table with items tagged **critical** in Phase 2.
5. Cite every claim that names a file, function, value, or behavior.
6. Verify cross-references link to pages that will exist.

---

### Phase 6 — Validate

**Read:** `guides/validation.md` for the full checklist. Apply auto-fixes in place; report report-only findings in the final summary.

---

## §7 Incremental Mode

**Prerequisite:** Wiki must exist with readable `.manifest.json`. If missing → **do NOT report an error** — silently fall back to Full mode (§6) and execute it.

**Execute all phases sequentially without stopping for confirmation.**

### Phase Overview

| Phase | Name | Purpose | Outputs |
|-------|------|---------|---------|
| 1 | **Diff** | Identify changed files vs. main | Internal: changed file list |
| 2 | **Map** | Map changed files → affected wiki pages | Internal: stale page list |
| 3 | **Context & Validate** | Read sources + audit content accuracy | Internal: context bundle |
| 4 | **Regenerate** | Rewrite affected pages | Updated `.md` files |
| 5 | **Sync** | Verify cross-refs + run validation | Fixes in-place |
| 6 | **Report** | Summarize what changed | Console output |

---

### Phase 1 — Diff

1. **Determine base branch** using this fallback chain (stop at first success):
   1. `--base <branch>` argument provided by user → use directly.
   2. `gh pr view --json baseRefName -q .baseRefName` → real PR target branch (requires `gh` CLI authenticated).
   3. Environment variable `$GITHUB_BASE_REF` → set automatically in GitHub Actions PR workflows.
   4. Branch recorded in `.manifest.json` field `branch`.
   5. `main` (if `origin/main` exists).
   7. If all fail → abort incremental mode and report: "Cannot determine base branch. Run full mode or specify `--base <branch>`."

2. Run `git diff --name-only origin/{base_branch}...HEAD`. If the remote ref doesn't exist, try `{base_branch}...HEAD`.
3. Categorize: Added, Modified, Deleted, Renamed.
4. Filter out: test snapshots, lockfiles, CI config, wiki `.md` files.

---

### Phase 2 — Map

1. **Read `.manifest.json`** — use `sourceMap` for page → source mapping.
2. Build reverse index: `source_file → [wiki_pages]`
3. For each changed file, look up affected wiki pages → **stale**.
4. Structural heuristics for uncited files:
   - New/deleted files in `src/` → relevant page is stale
   - Changes to package scripts/Makefile → `tutorial/setup.md` + `reference/configuration.md`
   - Changes to route definitions → `reference/api.md` + `explanation/architecture.md`
   - Changes to types/models → `reference/domain-model.md`
   - Changes to config files → `reference/configuration.md`
   - Changes to API hooks/services → `reference/api.md` + explanation pages
   - Changes to auth → `reference/integrations.md`
   - Changes to deployment/CI → `explanation/decisions.md` (if deployment section exists)
   - Changes to entry point/providers → `explanation/architecture.md`
5. Deleted file is cited → that page is stale.
6. NO pages affected → "Wiki is up to date" and stop.

---

### Phase 3 — Context & Validation

1. For each stale page, read: current wiki content + ALL source files it cites + changed files that triggered staleness.
2. Read `index.md` and `.vitepress/config.mts` sidebar.
3. Scan new files in covered directories.
4. Note deleted file citations to remove.
5. **Content accuracy validation (MANDATORY):** For each stale page, verify every factual claim still exists in current source. Build list of stale + missing content.
6. **Decision gate:** Stale/missing content → regenerate. Only line numbers shifted → update citations only.

---

### Phase 4 — Regenerate

Apply all rules from [§5](#5-writing-standards). Use `guides/universal-pages.md` for universal pages, active `modules/archetypes/{archetype}.md` + `modules/hints/{hint}.md` for archetype-specific pages.

---

### Phase 5 — Sync

1. Update sidebar if pages added/removed.
2. Run validation per `guides/validation.md`.
3. Update `.manifest.json` — `sourceMap`, `generatedAt`, `commitHash`.

---

### Phase 6 — Report

```
## Wiki Update Summary

| Page | Reason | Action |
|------|--------|--------|
| explanation/architecture.md | src/main.tsx modified | Regenerated |
| how-to/extend.md | New handler added | Regenerated |

Files changed in PR: 12
Wiki pages affected: 3
Wiki pages unchanged: 8
```

---

## §8 Edge Cases

### New major feature (new directory/module)
Report: "New module detected — consider running full mode." Do NOT auto-create pages in incremental mode.

### Renamed files
Find all citing pages, update citations, regenerate.

### Config-only changes
MUST still execute content accuracy validation. Never assume cosmetic.

### Test-only changes
Report "Wiki is up to date."

### Manifest missing
Fall back to Full mode with warning.

---

## §9 Invocation

### Full Mode
```
Generate the wiki for this repository
```

### Incremental Mode
```
Update wiki for this PR
```

### Optional arguments
- `--output <dir>` — Output directory (default: `wiki/`)
- `--base <branch>` — Base branch for incremental diff (default: auto-detected from PR via `gh` CLI, `$GITHUB_BASE_REF`, manifest, or `main`)
