---
name: backlog-management
description: Create and edit GitHub issues (user stories, bugs, spikes) with guided template-driven workflows. Use whenever the user mentions creating issues, editing issues, filing bugs, adding stories, managing backlog, tracking work items, updating an existing issue. Also triggers on "crear issue", "editar issue", "dar de alta tarea", "modificar tarea", "nuevo bug", "actualizar issue", "cambiar prioridad", "añadir al backlog", or any issue creation/editing intent targeting GitHub.
---

# Backlog Management

You help users create and edit GitHub issues by guiding them through structured workflows. The goal is to ensure every issue — whether new or being updated — has enough context for anyone picking it up to understand what needs to be done and why.

## Language

All issue content (title, body, section headers, acceptance criteria, etc.) must be written in English, regardless of the language the user communicates in. The conversation with the user can happen in their preferred language, but the resulting GitHub issue is always in English.

## Tool Priority

All GitHub operations (creating issues, editing issues, managing projects) use **gh CLI via bundled scripts as the primary method**. MCP tools are used only as a fallback when gh CLI is not available.

**How it works:** The scripts check for `gh` availability at startup. If `gh` is not installed or not authenticated, they exit with code **127** — this signals the agent to switch to the MCP fallback path documented in the workflows.

| Exit code | Meaning | Agent action |
|-----------|---------|--------------|
| **0** | Success — result on stdout | Parse output and continue |
| **1** | Error — details on stderr | Report error to user |
| **127** | gh CLI not available | Use MCP fallback |

Scripts:
- [`scripts/gh-issue.sh`](scripts/gh-issue.sh) — `create`, `view`, `edit` subcommands
- [`scripts/gh-project.sh`](scripts/gh-project.sh) — `add-item`, `list-fields`, `set-field` subcommands

## Conversational Efficiency

Each message exchange with the user costs time. Batch all the questions you need into the fewest possible rounds — ideally, group everything you can ask at once into a single message. The user should never feel like they're filling out a form one field at a time.

If you have a tool for asking the user questions (each agent platform provides its own), use it to present multiple questions in a single round. For anything that doesn't fit in the tool, combine remaining questions into your text message alongside the tool call.

## Routing

Determine the user's intent from their message:

- **Create** — The user wants to file a new issue interactively. Read [references/create-workflow.md](references/create-workflow.md) and follow its steps.
- **Edit** — The user wants to modify an existing issue (change title, body, labels, assignees, milestone, project fields, etc.). Read [references/edit-workflow.md](references/edit-workflow.md) and follow its steps.
- **Publish** — The caller provides a file path to a markdown file that contains a fully-written issue (frontmatter + body). Read [references/create-workflow.md](references/create-workflow.md) and follow the **Publish Path** section.

If the intent is ambiguous, ask the user in a single question whether they want to create a new issue, edit an existing one, or publish a pre-written file.

## Resources

- [scripts/gh-issue.sh](scripts/gh-issue.sh) — gh CLI wrapper for issue create/view/edit
- [scripts/gh-project.sh](scripts/gh-project.sh) — gh CLI wrapper for project add-item/list-fields/set-field
- [references/create-workflow.md](references/create-workflow.md) — Issue creation workflow (interactive + publish path)
- [references/edit-workflow.md](references/edit-workflow.md) — Issue editing workflow
- Issue body templates (discoverable via `assets/template-*.md` glob):
  - [assets/template-user-story.md](assets/template-user-story.md) — User story
  - [assets/template-bug.md](assets/template-bug.md) — Bug
  - [assets/template-spike.md](assets/template-spike.md) — Spike
