---
name: gh-pr-create
description: Create git branches and pull requests using the gh-pr-create skill (backed by the gh-sherpa GitHub CLI extension). Use when creating branches from GitHub or Jira issues, or when creating pull requests linked to issues. Automates branch naming following the contribution model configured for the repository. Use for tasks like "create a branch for issue #42", "open a PR for this issue", "create a branch and PR for JIRA-123".
---

# gh-pr-create: Branch and PR Creation

gh-sherpa is a GitHub CLI extension that creates branches and pull requests linked to GitHub or Jira issues, following the repository's configured naming conventions.

## Prerequisites

- `gh` CLI installed and authenticated
- `gh-sherpa` extension installed (see below)

## First Step (REQUIRED)

Before running any `gh sherpa` command, check if the extension is installed and install it if missing:

```bash
gh extension list | grep sherpa || gh extension install InditexTech/gh-sherpa
```

Do NOT search the filesystem for the binary — `gh-sherpa` is a `gh` extension, not a standalone executable, so it won't appear in `PATH` or at a predictable path. Just run the command above — it handles both detection and installation in one step.

## Commands

### Create Branch

```bash
# From a GitHub issue (non-interactive, auto-confirm)
gh sherpa create-branch --issue <number> --yes

# From a Jira issue
gh sherpa create-branch --issue <JIRA-123> --yes

# From a specific base branch
gh sherpa create-branch --issue <number> --base <branch> --yes

# Bug issue → hotfix branch prefix
gh sherpa create-branch --issue <number> --yes --prefer-hotfix
```

### Create Pull Request

```bash
# Create branch + PR in draft mode (default) from issue
gh sherpa create-pr --issue <number> --yes

# Create PR from the current branch (branch already exists — no issue flag needed)
# Use this form when the branch was already created and checked out;
# omitting --issue prevents sherpa from attempting to re-create the branch.
gh sherpa create-pr --yes

# Create non-draft PR
gh sherpa create-pr --issue <number> --yes --no-draft

# Create PR without auto-closing the issue
gh sherpa create-pr --issue <number> --yes --no-close-issue

# Create PR with a specific template
gh sherpa create-pr --issue <number> --yes --template docs/pull_request_template.md

# Hotfix PR from bug issue
gh sherpa create-pr --issue <number> --yes --prefer-hotfix
```

## Key Flags

| Flag               | Description                                              |
|--------------------|----------------------------------------------------------|
| `--issue, -i`      | GitHub issue number or Jira issue key                    |
| `--yes, -y`        | Skip confirmation prompts (REQUIRED for unattended use)  |
| `--base`           | Base branch (default: repo default branch)               |
| `--no-fetch`       | Skip fetching remote branches                            |
| `--no-draft`       | Create PR as ready for review (default is draft)         |
| `--no-close-issue` | Don't auto-close issue when PR merges                    |
| `--prefer-hotfix`  | Use `hotfix/` prefix for bug issues instead of `bugfix/` |
| `--template`       | Path to PR template file                                 |

## Branch Naming Convention

Sherpa derives the branch name from the issue type and title:

- `feature/GH-42-short-description` — feature issues
- `bugfix/GH-17-short-description` — bug issues
- `hotfix/GH-17-short-description` — bugs with `--prefer-hotfix`
- `refactoring/GH-55-short-description` — refactoring issues
- `feature/JIRA-123-short-description` — Jira issues

The exact mapping depends on your local Sherpa config at `~/.config/sherpa/config.yml`.

## Important Notes

- Always pass `--yes` flag to avoid interactive prompts (required for unattended/automated use)
- By default, `create-pr` creates a **draft** PR; use `--no-draft` for ready-for-review PRs
- Must be run inside a git repository with a configured GitHub remote
- For Jira issues, Jira credentials must be configured in `~/.config/sherpa/config.yml`
