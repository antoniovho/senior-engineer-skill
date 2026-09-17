# AGENTS.md

> Operational instructions for AI coding agents working on `[REPO-NAME]`. This document tells you HOW to operate — for project context, see `README.md`.

---

## Context Management

Context is your most important resource. Proactively use subagents (if supported) to keep exploration, research, and verbose operations out of the main conversation.

**Default to spawning agents for:**
- Codebase exploration (reading 3+ files to answer a question)
- Research tasks (web searches, doc lookups, investigating how something works)
- Code review or analysis (produces verbose output)
- Any investigation where only the summary matters

**Stay in main context for:**
- Direct file edits the user requested
- Short, targeted reads (1-2 files)
- Conversations requiring back-and-forth
- Tasks where user needs intermediate steps

**Rule of thumb:** If a task will read more than ~3 files or produce output the user doesn't need to see verbatim, delegate it to a subagent and return a summary.

## Skills

> **MANDATORY**: Before starting ANY task, inspect your loaded skills and execute every skill that matches. Skills override your general knowledge — they are the primary source of truth for framework conventions.

| Skill | When & Why |
|-------|------------|
| `[skill-name]` | [Synthesized one-liner — e.g., "Invoke on any Java task (features, fixes, config) to apply AMIGA Java conventions and guided workflows."] |
| `[skill-name]` | [Synthesized one-liner — e.g., "Invoke when creating or modifying API specs to enforce API-First design standards and validation rules."] |

If a required skill is not loaded, inform the user before proceeding — do not substitute with general knowledge.

---

## Build & Test

Load before running any build, test, lint, or install command.

> `read_file .aicontext/agent_docs/build-and-test.md`

---

## Codebase Navigation

Load before modifying, navigating, or adding files to understand module boundaries, dependencies, and integrations.

> `read_file .aicontext/agent_docs/codebase-navigation.md`

---

## Security Constraints

Load before touching authentication, secrets, sensitive data, or security-related code paths.

> `read_file .aicontext/agent_docs/security-constraints.md`

---

## Git Workflows

Load before creating branches, writing commits, or opening pull requests.

> `read_file .aicontext/agent_docs/git-workflows.md`

---

## Conventions & Constraints

Load before writing or reviewing any code to apply naming, style, architecture, error-handling, and testing rules.

> `read_file .aicontext/agent_docs/conventions-and-constraints.md`
