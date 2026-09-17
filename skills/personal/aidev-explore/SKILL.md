---
name: aidev-explore
description: Architectural exploration of all repositories in a workspace. Detects technology stacks, required tool versions, architecture patterns, project structure, and coding conventions for every repo found — running explorations in parallel via sub-agents. Use this skill when the user wants to understand a workspace's technical landscape, onboard to a multi-repo project, or refresh the workspace state file. Triggers on "explore workspace", "detect stack", "workspace architecture", "aidev-explore", "scan repos", "what stacks are in this workspace", or when the user wants a technical overview of their multi-repo setup.
---

# aidev-explore — Workspace Architectural Explorer

This skill performs a comprehensive architectural exploration of every repository in the current workspace. It identifies technology stacks, required tool versions, architecture patterns, project structure, and coding conventions — then consolidates everything into a single state file at `.aicontext/.state/stack.md`.

The exploration combines two approaches:
- **Deterministic detection** via [scripts/detect-repo.sh](scripts/detect-repo.sh) — fast, reliable, zero-token cost for stack, build system, tools, and contracts.
- **LLM interpretation** via sub-agents — explores the codebase with full autonomy to identify project structure, architecture patterns, conventions, constraints, and gotchas. No artificial limits on how much to read — the agent uses its judgment to reach high-confidence conclusions.

## Output

A single markdown file at the workspace root:

```
.aicontext/.state/stack.md
```

This file contains one section per repository with all detection results, plus a timestamp of the last update.

## Workflow

### 1. Discover repositories and prepare session file

Identify all repositories in the workspace. A repository is any directory containing a `.git` folder. Check:
- The workspace root itself (if it has `.git/`)
- Each immediate subdirectory of the workspace root
- If a `repos/` directory exists at the workspace root, each subdirectory within it

Once you have the list of repository paths, immediately create the output file with its initial scaffold:

1. Create the directory `.aicontext/.state/` if it doesn't exist
2. Write the file `.aicontext/.state/stack.md` with the header and an empty section per repo:

```markdown
# Workspace Stack & Architecture

> Last updated: {YYYY-MM-DD HH:mm:ss} (UTC)

---

## {repo-name}

_Exploring..._

---

## {next-repo-name}

_Exploring..._

---
```

This file is the session artifact — all subsequent steps write their results into it as they become available, rather than accumulating data and writing once at the end.

**Gate 1** — before proceeding, verify:
- [ ] At least one repository path was identified
- [ ] Each path actually contains a `.git/` directory
- [ ] The file `.aicontext/.state/stack.md` exists with the scaffold structure

### 2. Run deterministic detection and write results

For EACH discovered repository, execute the detection script:

```bash
bash <skill_path>/scripts/detect-repo.sh <repo_path>
```

This returns a JSON object per repo with: stack, build system, tool versions, and contracts. Run all script invocations in parallel (they are independent and fast).

The script handles all deterministic classification — the LLM does NOT need to read build files or classify stacks.

**As soon as script results are available**, write the `### Stack & Environment` section into each repo's `## {repo-name}` block in `stack.md`, replacing the `_Exploring..._` placeholder:

```markdown
### Stack & Environment
- **Detected stack**: ...
- **Project framework detected**: yes | no
- **Build system**: ...
- **Tool versions**: ...
- **Contracts**: ...
```

**Gate 2** — before proceeding, verify:
- [ ] The script `detect-repo.sh` was executed (not the LLM doing detection manually)
- [ ] A valid JSON output was obtained for each repository
- [ ] Each JSON contains the fields: `repo_name`, `stack`, `tool_versions`, `contracts`
- [ ] Each repo section in `stack.md` now has a `### Stack & Environment` block

### 3. Spawn parallel interpretation sub-agents

For each repository, spawn an explore sub-agent using the prompt in [references/explore-agent-prompt.md](references/explore-agent-prompt.md). Pass the script's JSON output as context so the sub-agent knows what was already detected and only needs to do the interpretive work (architecture patterns, conventions, etc. from source code).

All sub-agents run in parallel — spawn them all in a single turn.

If only one repository exists, skip sub-agent overhead and run the interpretation inline.

**As each sub-agent completes**, append its output to the corresponding repo section in `stack.md` — don't wait for all sub-agents to finish. The sub-agent's output format is defined in [references/explore-agent-prompt.md](references/explore-agent-prompt.md) and should be inserted without reformatting.

**Gate 3** — before proceeding, verify:
- [ ] One explore sub-agent was spawned per repository (or inline interpretation for single-repo case)
- [ ] Each sub-agent received the detection JSON as input
- [ ] Each sub-agent returned a response containing the sections: Project Structure, Architecture & Patterns, Conventions, Constraints & Gotchas
- [ ] Each sub-agent's output was written to `stack.md`

### 4. Cross-repo topology (multi-repo workspaces only)

Skip this step if the workspace contains a single repository.

Once all sub-agents have completed, analyze how the repositories relate to each other. The primary evidence comes from the contracts and integrations already detected:
- If repo A produces a contract and repo B consumes it, that's a dependency link
- Shared artifact IDs in build files (one repo depending on another as a library)
- Matching service names across configs (one repo's client pointing at another repo's service)
- Shared event topics or queues (async communication)

Synthesize a `## Workspace Topology` section and append it at the end of `stack.md`. Use a concise format — one line per relationship. Example:

```markdown
## Workspace Topology

| From | To | Relationship |
|------|-----|-------------|
| repo-a | repo-b | REST API (repo-a produces, repo-b consumes) |
| repo-c | repo-a | Async event via topic `orders.created` |
| repo-b | shared-lib | Maven dependency |
```

If no inter-repo relationships are found, write "No inter-repository relationships detected" and move on.

**Gate 4** — before proceeding, verify:
- [ ] Cross-repo analysis was performed (or skipped for single-repo workspaces)
- [ ] A `## Workspace Topology` section was appended to `stack.md` (or "No inter-repository relationships detected" if none found)

### 5. Report to user

Briefly summarize what was found — number of repos explored, stacks detected, any notable findings. Point the user to the output file path.

## Output structure

The final state of `.aicontext/.state/stack.md` after a complete run:

```markdown
# Workspace Stack & Architecture

> Last updated: {YYYY-MM-DD HH:mm:ss} (UTC)

---

## {repo-name}

### Stack & Environment
- **Detected stack**: ...
- **Project framework detected**: yes | no
- **Build system**: ...
- **Tool versions**: ...
- **Contracts**: ...

{sub-agent output — ### headings for Project Structure, Architecture & Patterns, Conventions, and Constraints & Gotchas}

---

## {next-repo-name}
...

---

## Workspace Topology

| From | To | Relationship |
|------|-----|-------------|
| ... | ... | ... |
```

The **Stack & Environment** section is formatted from the script's JSON output. The rest (project structure, architecture, conventions, gotchas) comes directly from the sub-agent's response. The **Workspace Topology** section is synthesized by the orchestrator after all repos are explored (only for multi-repo workspaces).

## Success Criteria

✅ **Session file created first** — the file `.aicontext/.state/stack.md` was created at the start of the workflow, before any detection runs.
✅ **Incremental writing** — results were written to `stack.md` as they became available (after script detection, after each sub-agent completion), not accumulated and written at the end.
✅ **Deterministic detection via script** — the detection was performed by executing `scripts/detect-repo.sh`, not by the LLM reading build files and classifying manually.
✅ **Explore sub-agents spawned** — one explore sub-agent was spawned per repository to perform the interpretive analysis (or inline interpretation was performed for the single-repo case).
✅ **Cross-repo topology** — for multi-repo workspaces, inter-repository relationships were analyzed and written to the Workspace Topology section. For single-repo workspaces, this step was correctly skipped.
✅ **Complete output** — the final file contains a `## {repo-name}` section for every discovered repository, each with both deterministic and interpretive data.

## Key Rules

- Create the session file FIRST, then populate it incrementally. The file should be useful at any point during execution — even if the process is interrupted.
- Deterministic detection via script FIRST, LLM interpretation SECOND. Never use the LLM to classify stacks or parse .tool-versions — the script already did that.
- Spawn all repo interpretations in parallel — never sequentially.
- If only one repo exists, skip sub-agent overhead and interpret inline.
- Do not ask the user for confirmation before exploring — this is a read-only operation.
- Each run produces a fresh snapshot — the file is created anew (overwriting any previous version) in step 1.
- Sub-agents have full autonomy to explore as much as needed — no artificial file-count limits. The goal is high-confidence conclusions, not minimal reads.
- The script handles "unknown" cases gracefully — if no build file is found, it reports stack as "unknown" and the sub-agent still explores observable structure.
