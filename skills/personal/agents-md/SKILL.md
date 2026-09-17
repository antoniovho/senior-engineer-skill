---
name: agents-md
description: "Generate or update an AGENTS.md file for a repository. Use this skill when a user asks to: initialize AGENTS.md, update AGENTS.md, create agent instructions for a repo, scaffold an AGENTS.md, generate coding agent context, or document project conventions for AI agents."
---

# AGENTS.md Generator

## Workflow

> Steps 1, 2, and 3 are independent — execute them **in parallel through sub-agents** if the runtime supports it.

1. **Explore the repo** — go beyond file listings. Inspect:
   - **Project structure**: directory layout, module boundaries, entry points.
   - **Coding patterns & style**: naming conventions, formatting rules, indentation, import ordering, error-handling idioms.
   - **Architecture conventions**: layering (hexagonal, clean, MVC…), dependency direction, how modules communicate.
   - **Version control practices**: 
      - Use GitHub MCP tools to analyze existing commit history and patterns
      - Filter human commits only - exclude automated bot commits when analyzing patterns
      - Document real project conventions (not theoretical standards)
      - Include commit message standards (format, scope, breaking changes)

2. **Detect tech stack** — identify frameworks from manifests (`pom.xml`, `go.mod`, `pyproject.toml`, `package.json`, etc.) and API specs.

3. **Discover skills** — auto-detect the skills directory based on the agent that is currently running:
   | Agent | Skills directory |
   |-------|-----------------|
   | GitHub Copilot | `.copilot/skills` |
   | Cline | `.cline/skills` |
   | OpenCode | `.agents/skills` |
   | Claude Code | `.claude/skills` |

   If the agent is not listed above, infer the path by inspecting well-known dotfile directories at the repo root or ask the user.

   Then run: `python scripts/detect-skills.py <resolved-skills-dir>`. The script outputs raw frontmatter data for each detected skill. You will **synthesize** this output in the next step — do not paste it verbatim.

4. **Fill the template** — use [assets/AGENTS.template.md](assets/AGENTS.template.md).
   - **Audience is exclusively AI agents, not humans.** Every sentence must tell the agent **HOW** to operate (commands to run, constraints to follow, steps to execute) — never describe **WHAT** the project is or narrate its purpose like a README would.
   - For the **Skills section**: do **not** paste the raw frontmatter table from the script. Instead, **synthesize** each skill's frontmatter into a concise, actionable sentence that tells the agent when and why to invoke it.
   - **Progressive disclosure**: The sections **Context Management** and **Skills** keep their full content inline in `AGENTS.md`. All other sections (`Build & Test`, `Codebase Navigation`, `Security Constraints`, `Git Workflows`, `Conventions & Constraints`) must contain **only** a one-sentence trigger instruction telling the agent **when** to load the detail, followed by a `read_file` reference pointing to `.aicontext/agent_docs/<section-slug>.md`. Do **not** inline the detailed content in `AGENTS.md`.
   - Fill remaining sections with real, verified data from the repo. Every placeholder must be replaced with concrete values or removed.

5. **Generate detail docs** — create the directory `.aicontext/agent_docs/` at the repo root and write one markdown file per section with the full operational detail:
   | File | Content |
   |------|---------|
   | `build-and-test.md` | Prerequisites, all build/test/lint commands, and CI constraints. |
   | `codebase-navigation.md` | Module map, key dependencies, and external integrations. |
   | `security-constraints.md` | Auth mechanisms, secrets management, and sensitive areas. |
   | `git-workflows.md` | Branching model, commit format, PR rules, and forbidden actions. |
   | `conventions-and-constraints.md` | Naming rules, code style, architecture constraints, error handling, and testing rules. |

   Each file must be self-contained, written in imperative style for AI agents, and contain **only** verified data from the repo — no placeholders.

6. **Write** — create or overwrite `AGENTS.md` at the repo root and all files under `.aicontext/agent_docs/`.

## Key Rules

- The **Skills section** is the most important output. It must instruct the agent, in imperative non-negotiable tone, to inspect its loaded skills before every task and execute those that match.
- Each skill entry must be a **synthesized one-liner** describing trigger and purpose — not a copy of the raw `description` field from frontmatter.
- Replace **every** placeholder and remove all HTML comments/TODOs.
- The Skills section must contain **at least one** entry. If no framework is detected, note it and tell the agent to check for newly loaded skills.
- The entire document is written **for an AI coding agent**. Do not include human-oriented explanations, onboarding prose, or project rationale. Focus on operational instructions: what to run, what to avoid, what constraints to respect.
- Do not repeat `README.md` content — link to it.
- Write in English, imperative style.
- Keep the final file scannable in under 2 minutes.
