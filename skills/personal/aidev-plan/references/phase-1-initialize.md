# Phase 1 — Initialize & Understand

> This file contains the complete instructions for Phase 1. Read it when starting this phase. Do not read other phase instruction files until this phase's gate is met.

## Steps

> **`<workspace_root>`** = the root directory of the **project the user is working on**. This is the user's project directory — NOT the agent's session state directory. Resolve it from the IDE workspace path or the current working directory. If the user invoked the skill from within a specific directory, that directory is the workspace root. When in doubt, ask the user.

> **Execution model.** Steps 1–2 are sequential setup (session file, target repo, MCP tool selection). Step 3 extracts search terms and launches two sub-agents in parallel (issue search + product context acquisition). Step 4 processes results from both sub-agents (blocking checkpoint if duplicate issues detected). Step 5 summarizes understanding and transitions to Phase 2.

1. **Check for prior research (optional)** — Only consume research if the user explicitly provides a path to a research session file. **Do not search for research files automatically.** If the user provides a path, read it and consume its main sections — `## Research Objective`, `## Research Conclusions` (Key Findings, Scope, Recommendations, Risks, Open Questions), `## Internal Capabilities`, `## External Analysis`, and `## Sources`. Treat scope, recommendations, and risks as **binding context**. If no research path is provided, skip this step entirely.

2. **Create the session file & determine target repository** ← *requires step 1 complete if research was provided*

   **2.1. Create session file** — living document updated throughout planning:
    - Template: Load [template-plan-session.md](../assets/template-plan-session.md) — do not omit any section.
    - Path: `<workspace_root>/.aicontext/.sdd/{plan_name}/plan.md` — where `{plan_name}` matches the `aidev-research` plan name (if coming from `aidev-research`) or is a short, kebab-case summary of the planning topic.
    - Create directories if they don't exist. Also create the `specs/` subdirectory: `<workspace_root>/.aicontext/.sdd/{plan_name}/specs/`
    - If `aidev-research` handoff exists, populate the `## Research Context` section with a summary of the binding context (objective, key findings, recommendations, risks, open questions).
    - Populate `## Overview` — what is being planned, why, and for whom. If coming from `aidev-research`, summarize the research objective and recommended direction. If from an idea or direct requirement, capture the problem statement and desired outcome.
    - Set status to `🔄 Understanding`.

   **2.2. Determine target repository** — If the user already specified a target repository (`owner/repo`) in their planning prompt, use it directly — no auto-detection or confirmation needed. Otherwise, try to infer it automatically:
   1. Check if `<workspace_root>/repos` exists.
   2. Inside it, look for directories matching the pattern `app-*`.
   3. **If exactly one `app-*` directory is found** — treat it as the target repository. Resolve its `owner/repo` identifier from its git remote origin (`git -C <path> remote get-url origin`, then extract `owner/repo` from the URL). Inform the user which repository was auto-detected: *"Detected target repository: owner/repo"*.
   4. **Otherwise** — the `repos` folder does not exist, contains no `app-*` directories, or contains more than one — hold the question for the combined setup prompt in §2.4.

   Write the resolved `owner/repo` to the session file's `## Metadata` → `**Target repository**` field immediately. This value is reused in Phase 4 (materialization) to avoid re-resolving the same repository.

   **2.3. Discover product-level MCP tools** — If the user already specified which MCP tool(s) to use in their planning prompt, record the selection and skip discovery. Otherwise, **discover** the available tools in your **MCP tool list** that can provide functional context about the product (what it is, what it does, scope, etc). If tools are found, hold the question for the combined setup prompt in §2.4.

   If no product-context tools are discovered, inform the user and move on — Sub-agent B will rely on wikis and GitNexus only.

   **2.4. Combined setup prompt** — If §2.2 and/or §2.3 have pending questions (target repo not resolved, MCP tool not selected), present them together in a **single interactive question tool call**. This avoids multiple back-and-forth exchanges:

   - **Target repository** (if unresolved): freeform input, header `"Target repository"`, prompt `"Which repository should be used? (owner/repo format)"`. If multiple `app-*` directories were found in §2.2, list them as selectable options.
   - **Product context tool** (if tools were discovered): list the discovered tools as selectable options with a `"Skip — use wikis/GitNexus only"` option. Header `"Product context tool"`, prompt `"Which tool should I use to understand the product?"`.

   If both questions are already resolved (user provided repo + tool, or repo auto-detected + user provided tool, etc.), skip this step entirely.

3. **Parallel acquisition** ← *requires step 2 complete: session file exists, target repo resolved, and MCP tool selection recorded* — Launch two sub-agents in parallel to acquire context and check for duplicates simultaneously. Both sub-agents run in the same turn to minimize wait time.

   **3.1. Extract search terms** (inline, before launching sub-agents)

   The user's planning prompt is the **primary source** for keyword extraction — it defines what they actually want to plan. Extract 3–5 keywords directly from their description. If prior research was consumed in step 1, use it as supplementary context to enrich the search with domain vocabulary or alternative phrasings — but never let research terms override or displace keywords derived from the user's own words. Generate 2–3 keyword combinations that cover different phrasings of the same intent (synonyms, related terms, broader/narrower scope).

   **Multilingual & acronym expansion** — Issue authors may use a different language or domain-specific abbreviations than the user's prompt. To bridge vocabulary gaps:
   1. **Translate across languages**: If the user writes in Spanish, generate keyword variants in English (and vice versa). Teams often title issues in a different language or mix languages within the same title. For each keyword combination, produce its counterpart in the other language.
   2. **Expand to domain acronyms and abbreviations**: For each core concept, consider whether common abbreviations, acronyms, or domain-specific names exist.
   3. **Include atomic keywords**: In addition to multi-word combinations, generate 2–3 single high-signal keywords derived from the core concepts (e.g., "diagnostic", "RCA", "assistant"). Single-keyword searches are noisier but catch issues that multi-word combinations miss due to phrasing differences.

   The expanded set should produce **4–6 keyword combinations** total (the original 2–3 plus their multilingual/acronym variants).

   **3.2. Launch two sub-agents in parallel**

   **Sub-agent A — Issue Search**

   Spawn a single `general-purpose` sub-agent that receives the target repository (`owner/repo`) and **all** keyword combinations. The sub-agent must:
   1. Use GitHub search tools (`search_issues`) to search for matching issues (both open and closed) using each keyword combination sequentially
   2. Deduplicate results across all searches (by issue URL)
   3. Return a compact summary — one line per unique issue: `title | URL | state (open/closed) | one-line relevance note`. If no matches across all searches: `No matches found.`

   **Sub-agent B — Product Context**

   Spawn a single `general-purpose` sub-agent that acquires product context. The sub-agent receives: the user's planning topic, the list of artifact repositories involved, the user's MCP tool selection from §2.3 (if any), and instruction to return a synthesized functional summary.

   The sub-agent uses the following sources. **Product-level MCP tool** is used only if the user selected one in §2.3. **Wikis** and **GitNexus** are optional — the sub-agent checks for their availability autonomously and uses them only if present.

   - **Product-level MCP tool** (only if user selected one in §2.3): Use the specified tool to understand the product's value proposition and capabilities. If the user skipped tool selection, skip this source.

   - **Artifact wikis** (also referred to as **code wiki** in downstream templates): Check each artifact repository for a `wiki/` or `.github/illuminate` folder. These folders are generated from a complete analysis of the codebase, always kept in sync with the code — never stale. They provide domain models, architecture, conventions, enums, API surfaces, task recipes, change impact, architectural decision records, tech debt, code style, functionality maps, and more. If present, browse starting from the entry point (typically README.md, index.md, toc.yml, llms*.txt, or overview file), understand the artifact's functional role in the product, and extract findings relevant to the planning topic. If the folder is not present, it does not exist — do not attempt to find it via GitHub MCP or any remote lookup.

   - **GitNexus MCP**: If GitNexus tools are available, use them for **live structural analysis** of the codebase — dependencies, call chains, functional clusters, and execution flows. GitNexus provides dynamic queries over actual code structure, complementary to wikis (curated documentation). When an artifact is indexed in GitNexus, it is the **EXCLUSIVE** tool for code-level context — architecture, dependencies, execution flows, symbol relationships, call chains, and source code content. **Never use `view`, `grep`, `glob`, or `bash` to read source code in a repository that GitNexus has indexed.** The only exceptions where direct file access is acceptable are: README/documentation prose, configuration file values (YAML, JSON, .env), and non-code assets. Use `include_content: true` when actual source code is needed.

   > **Note**: `explore`-type sub-agents (Haiku model) do NOT have MCP access — only `general-purpose` sub-agents can execute GitNexus queries. Never delegate GitNexus work to explore agents.

   The sub-agent must return:
   - A functional summary of what the product does, who it serves, what capabilities each artifact contributes — all in **domain/product language** (applying the Functional-Language Rule from SKILL.md). Architecture and tech stack details are relevant only when they represent product-level constraints (e.g., "the product operates as two separate applications — an operations SPA and a backend service" is relevant; "uses Spring Boot with WebFlux and a PostgreSQL database" is not).
   - A list of sources consulted with brief notes on what each revealed
   - Any significant discoveries or surprises relevant to the planning topic

4. **Process results** ← *requires step 3 complete: both sub-agents have returned* — Process the outputs from both sub-agents.

   **4.1. Issue search results** — This is a **blocking checkpoint**. Do not proceed to step 5 until fully resolved.

   - **If an existing issue (open or recently closed) already covers what the user wants to plan** — meaning the scope, intent, and outcome substantially overlap — **pause the workflow and present the finding to the user**. Explain clearly what was found and why it appears to overlap: *"I found an existing task that appears to cover this request: [issue title](URL) (state). The scope overlaps because [brief explanation]. Before I continue planning, I need your decision — should I proceed with a new plan anyway, or does this existing task already cover what you need?"* Wait for the user's explicit answer. Do NOT continue while waiting. If the user decides the existing issue is sufficient, end the workflow. If the user decides to proceed, continue with the existing issue noted as context in `## Planning Notes`.
   - **If related but not overlapping issues are found** — issues that touch the same area but address a different concern or scope — present them as context: *"I found N related issues, but none fully cover this request: [list with links]. These may be useful context during planning. Proceeding."* Record these in the session file under `## Planning Notes` with a `[Phase 1]` prefix.
   - **If no issues found**: *"No existing issues found on this topic. Proceeding."*

   The distinction between "already covered" and "related but different" matters. An issue titled "Add retry logic to payment service" covers a request to "plan retry handling for payments" — that is a blocking overlap, pause and ask. But it does not cover "plan circuit-breaker for payment service" — that is related context, not a duplicate. When in doubt, err on the side of pausing — a false pause is cheap (the user says "proceed"), but a duplicate plan wastes significant effort.

   **4.2. Product context** — Populate the session file from Sub-agent B's output:
   - Populate the `## Product Context` section with the functional summary — what the product does, who it serves, what capabilities each artifact contributes, and how they relate.
   - Populate `### Sources consulted` within `## Product Context` — transfer the sources list from the sub-agent's output. For each artifact repository consulted, resolve the latest **remote** commit hash once — use `git rev-parse @{upstream} 2>/dev/null || git rev-parse origin/HEAD` (this returns the tracking branch tip, falling back to the repo's default branch; it always yields a commit that exists on GitHub, even when the local branch has unpushed commits). Combine with the remote URL to form commit-pinned GitHub URLs for all references (e.g., `https://github.com/inditex/{repo}/blob/{commit}/{path}`). This pins each reference to the exact version consulted, so links remain valid even if the file changes later.
   - Add to `## Planning Notes` — record any significant discoveries, surprises, or connections from the sub-agent's output. Keep notes brief (1-3 sentences each) and prefix with `[Phase 1]`.

5. **Summarize understanding** ← *requires step 4 complete: product context populated and issue search checkpoint resolved* — Summarize understanding to the user as a **preamble before the first interview round** — include the product name (derived from product context, wikis, or the user's input, never from directory or workspace paths), the key artifacts involved (referencing them by name but describing what each one does for the user or the product, not its internal architecture), and any initial observations framed in product terms. The user is a product stakeholder — they care about what the product does and what it could do better, not about how the code is structured internally. Then immediately proceed to Phase 2. The user will have the opportunity to correct any misunderstanding through their interview answers.

## Gate

When all steps above are complete:
- Session file exists with Overview, Product Context, and Sources consulted populated

Announce: **"Phase 1 complete — moving to Phase 2: Deep Interview."** Then read `phase-2-interview.md` and present the understanding summary alongside the first interview round.
