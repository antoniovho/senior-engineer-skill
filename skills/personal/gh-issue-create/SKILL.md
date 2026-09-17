---
name: gh-issue-create
description: Create GitHub issues using gh CLI with proper formatting and structure. Use when creating issues, bug reports, feature requests, or tasks. Supports labels, assignees, milestones, and projects. Works with current repository or cross-repo via -R flag. Expects markdown-formatted content from agent/LLM.
---

# GitHub Issue Creation

Create GitHub issues using the `gh issue create` command.

## Workflow

1. Prepare markdown content (title and body)
2. Determine target repository (current or specify with -R)
3. Build command with appropriate flags
4. Execute with body via heredoc or file

## Command Patterns

### Basic Issue (Current Repository)

```bash
gh issue create --title "Issue title" --body "$(cat <<'EOF'
Issue description in markdown format.

## Details
Additional context here.
EOF
)"
```

### Cross-Repository

```bash
gh issue create -R owner/repo --title "Issue title" --body "Issue body"
```

### With Metadata

```bash
gh issue create --title "Bug: Login fails" \
  --body "Description here" \
  --label "bug,priority-high" \
  --assignee "@me" \
  --milestone "v1.0"
```

### From File

```bash
gh issue create --title "Issue title" --body-file issue-body.md
```

## Available Flags

| Flag              | Description                          |
|-------------------|--------------------------------------|
| `-t, --title`     | Issue title (required)               |
| `-b, --body`      | Issue body text                      |
| `-F, --body-file` | Read body from file                  |
| `-l, --label`     | Add labels by name (comma-separated) |
| `-a, --assignee`  | Assign users (`@me` for self)        |
| `-m, --milestone` | Add to milestone by name             |
| `-p, --project`   | Add to project by title              |
| `-R, --repo`      | Target repository (owner/repo)       |

## Formatting Guidelines

- Use markdown for body content
- Include code blocks with language hints
- Use task lists `- [ ]` for action items
- Reference issues with `#123`
- Mention users with `@username`

## Reference Templates

For common scenarios, see:
- `references/bug-report-template.md` - Bug report structure
- `references/feature-request-template.md` - Feature request format
- `references/task-template.md` - General task format

## Error Handling

| Error                          | Cause             | Solution                           |
|--------------------------------|-------------------|------------------------------------|
| "authentication required"      | Not logged in     | Run `gh auth status` to verify     |
| "Could not resolve repository" | Invalid repo      | Check -R flag format: owner/repo   |
| "label not found"              | Invalid label     | Verify label exists in repository  |
| "milestone not found"          | Invalid milestone | Check milestone name in repository |

## Examples

### Bug Report

```bash
gh issue create --title "Bug: API returns 500 on empty input" \
  --label "bug" \
  --body "$(cat <<'EOF'
## Description
The API endpoint `/api/process` returns HTTP 500 when called with empty payload.

## Steps to Reproduce
1. Send POST to `/api/process` with empty body
2. Observe 500 response

## Expected Behavior
Should return 400 Bad Request with validation error.

## Environment
- API Version: 2.1.0
- Environment: Production
EOF
)"
```

### Feature Request with Assignee

```bash
gh issue create -R myorg/backend \
  --title "Feature: Add rate limiting to public API" \
  --label "enhancement,api" \
  --assignee "developer1" \
  --body "$(cat <<'EOF'
## Problem
Public API has no rate limiting, risking abuse.

## Proposal
Implement token bucket rate limiting:
- 100 requests/minute for anonymous
- 1000 requests/minute for authenticated

## Acceptance Criteria
- [ ] Rate limiter implemented
- [ ] Headers include rate limit info
- [ ] Documentation updated
EOF
)"
```
