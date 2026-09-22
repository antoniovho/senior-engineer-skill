---
name: gh-pr-review
description: Submit pull request reviews using GitHub MCP tools. MANDATORY — always use MCP tools (github_pull_request_review_write, github_add_comment_to_pending_review) to submit reviews. NEVER use gh CLI if MCP is available. CLI is only a last-resort fallback when MCP tools are completely unavailable.
---

# GitHub Pull Request Reviews with Line-Specific Comments (MCP)

## MANDATORY: Decision Tree

Before doing anything, follow this decision tree:

1. **Can you call the MCP tool `github_pull_request_review_write`?**
   - **YES** → You **MUST** use the MCP workflow below. Proceed to "Review Workflow".
   - **NO** (tool not found, MCP server down, auth error) → You **MAY** use the CLI fallback at the bottom of this document.

**There are NO exceptions.** Do NOT use `gh pr review`, `gh pr comment`, or any CLI command when MCP tools are available. "CI mode", "ensuring proper submission", or any other justification is **NOT** a valid reason to skip MCP.

> These are **MCP tool calls** that you invoke through your tool-calling interface — they are NOT shell commands to run in a terminal.

## Review Workflow

To create multiple separate inline comment threads (each comment appears as its own conversation in GitHub's Files changed tab):

**Step 1 (optional): Inspect the PR changes**

Skip this step if you already have the diff or file list from a previous analysis. Otherwise, use `github_pull_request_read` to get the information needed to position inline comments:

- `method: "get_diff"` — see the actual code changes and line numbers
- `method: "get_files"` — list all changed files and their paths

**Step 2: Create pending review**

Call the MCP tool `github_pull_request_review_write` (this is a tool call, NOT a shell command):

- `owner`: "org-name"
- `repo`: "repo-name"
- `pullNumber`: 123
- `method`: "create"

> Do NOT pass `event` when creating — it opens a draft review.

**Step 3: Add inline comments (repeat for each comment)**

Call the MCP tool `github_add_comment_to_pending_review` once per inline comment (this is a tool call, NOT a shell command):

- `owner`: "org-name"
- `repo`: "repo-name"
- `pullNumber`: 123
- `path`: "src/file1.js"
- `line`: 45
- `side`: "RIGHT"
- `subjectType`: "LINE"
- `body`: "This needs error handling"

**Step 4: Submit the pending review**

Call the MCP tool `github_pull_request_review_write` (this is a tool call, NOT a shell command):

- `owner`: "org-name"
- `repo`: "repo-name"
- `pullNumber`: 123
- `method`: "submit_pending"
- `event`: "COMMENT"
- `body`: "Left some inline feedback"

### Summary Flow

```
[github_pull_request_read (get_diff / get_files)]   ← only if diff not already available
         ↓
github_pull_request_review_write (method: "create", no event)   ← opens pending review
         ↓
github_add_comment_to_pending_review                             ← repeat for each inline comment
         ↓
github_pull_request_review_write (method: "submit_pending", event: APPROVE | REQUEST_CHANGES | COMMENT)
```

## MCP Tool Reference

### github_pull_request_read

Read PR information needed to position inline comments.

**Key Parameters:**
- `owner`: Repository owner (string, required)
- `repo`: Repository name (string, required)
- `pullNumber`: PR number (number, required)
- `method`: "get_diff" | "get_files" | "get_reviews" | "get_review_comments" (string, required)

### github_pull_request_review_write

Create or submit PR reviews.

**Key Parameters:**
- `owner`: Repository owner (string, required)
- `repo`: Repository name (string, required)
- `pullNumber`: PR number (number, required)
- `method`: "create" | "submit_pending" | "delete_pending" (string, required)
- `event`: "APPROVE" | "REQUEST_CHANGES" | "COMMENT" (string, required for `submit_pending`; omit on `create`)
- `body`: Overall review summary (string, optional)
- `commitID`: Specific commit SHA (string, optional)

### github_add_comment_to_pending_review

Add line-specific comments to a pending review. **Each call creates a separate comment thread in the PR.**

**Key Parameters:**
- `owner`: Repository owner (string, required)
- `repo`: Repository name (string, required)
- `pullNumber`: PR number (number, required)
- `path`: File path relative to repo root (string, required)
- `line`: Line number for single-line comments (number, optional)
- `startLine`: Starting line for multi-line comments (number, optional)
- `side`: "RIGHT" (new code) | "LEFT" (old code) (string, optional)
- `startSide`: Starting side for multi-line (string, optional)
- `subjectType`: "LINE" | "FILE" (string, required)
- `body`: Comment text (string, required)

### Supporting Tools

| Tool | method | When to use |
|------|--------|-------------|
| `github_pull_request_read` | `get_diff` | See actual code changes and line numbers |
| `github_pull_request_read` | `get_files` | List all changed files and their paths |
| `github_pull_request_read` | `get_review_comments` | Check existing inline review threads |
| `github_pull_request_read` | `get_reviews` | See existing reviews on the PR |

## Complete Example: Multiple Inline Comments

**Step 1 (optional) — Get diff and files:**

Skip if the diff is already available from a prior analysis. Otherwise call `github_pull_request_read` with `method: "get_diff"` and/or `method: "get_files"` to identify changed files and line numbers.

**Step 2 — Create pending review (MCP tool call):**

Call `github_pull_request_review_write` with:
- `owner`: "inditex"
- `repo`: "mic-ghcajava"
- `pullNumber`: 62
- `method`: "create"

**Step 3a — Add inline comment on a specific line (MCP tool call):**

Call `github_add_comment_to_pending_review` with:
- `owner`: "inditex"
- `repo`: "mic-ghcajava"
- `pullNumber`: 62
- `path`: ".github/workflows/execute-command-test.yml"
- `line`: 10
- `side`: "RIGHT"
- `subjectType`: "LINE"
- `body`: "Consider adding a timeout for this step to prevent hanging workflows."

**Step 3b — Add another inline comment (MCP tool call):**

Call `github_add_comment_to_pending_review` with:
- `owner`: "inditex"
- `repo`: "mic-ghcajava"
- `pullNumber`: 62
- `path`: "code/test/java/com/inditex/ghcajava/SumTest.java"
- `line`: 5
- `side`: "RIGHT"
- `subjectType`: "LINE"
- `body`: "This test is expected to fail. Consider adding @Disabled annotation with explanation."

**Step 3c — Add file-level comment (MCP tool call):**

Call `github_add_comment_to_pending_review` with:
- `owner`: "inditex"
- `repo`: "mic-ghcajava"
- `pullNumber`: 62
- `path`: ".github/workflows/merge-configuration.yml"
- `subjectType`: "FILE"
- `body`: "Overall this workflow configuration looks good. Consider documenting the purpose of this change."

**Step 4 — Submit the pending review (MCP tool call):**

Call `github_pull_request_review_write` with:
- `owner`: "inditex"
- `repo`: "mic-ghcajava"
- `pullNumber`: 62
- `method`: "submit_pending"
- `event`: "COMMENT"
- `body`: "Left several inline suggestions. Overall the PR looks reasonable but please address the comments."

## Review Event Types

| Event | Description | Use Case |
|-------|-------------|----------|
| `APPROVE` | Approve the PR | Code is ready to merge |
| `REQUEST_CHANGES` | Block merge until addressed | Critical issues found |
| `COMMENT` | Neutral feedback | Questions, suggestions, observations |

## Comment Positioning

### Understanding `side` Parameter

- **RIGHT**: Comment on the new version (additions/modifications in the PR)
- **LEFT**: Comment on the old version (deletions/original code)

### Single-Line vs Multi-Line Comments

- **Single-line**: Use only `line` and `side`
- **Multi-line**: Use `startLine`, `line`, `startSide`, and `side`

## GitHub Suggestion Format

When proposing a concrete code change in an inline comment, use the `suggestion` code block in the `body` of `github_add_comment_to_pending_review`. GitHub renders an **"Apply suggestion"** button that lets the author accept the change with one click.

### Single-line suggestion

For a comment on a single `line`, the suggestion replaces that line:

````
body: "Consider using a constant here:\n```suggestion\nconst TIMEOUT_MS = 5000;\n```"
````

### Multi-line suggestion

For a comment spanning `startLine` to `line`, the suggestion replaces the entire range:

````
body: "This block can be simplified:\n```suggestion\nconst result = items.filter(isValid);\n```"
````

> **Important**: The content inside the `suggestion` block must be the exact replacement code — no explanation, no diff markers.

## Best Practices

1. **NEVER use CLI when MCP is available** — there are no valid reasons to prefer CLI over MCP. "CI mode", "proper submission", or any other justification is NOT acceptable
2. **Always use pending review workflow** for inline comments — never try to execute MCP tool names as shell commands
3. **Get the diff if needed** — use `github_pull_request_read` with `get_diff`/`get_files` only if file paths and line numbers are not already known from a prior analysis
4. **Batch all comments** — Create review → add all inline comments → submit once with `submit_pending`
5. **Each `github_add_comment_to_pending_review` call** creates a separate conversation thread
6. **Be specific** — reference exact lines, provide actionable feedback
7. **Use ` ```suggestion ` blocks** for proposable code changes — they create an "Apply suggestion" button in GitHub
8. **Include summary** — add overall context in the review `body` when submitting

## Fallback: CLI (Last Resort Only)

> **MANDATORY**: Use CLI **ONLY** if the GitHub MCP tools are completely unavailable (server down, not configured). If you can call `github_pull_request_review_write`, you **MUST NOT** use `gh pr review`. There are **NO exceptions**.

CLI does **not** support line-specific inline comments. Only the review summary body is supported:

```bash
gh pr review 123 --approve --body "LGTM"
gh pr review 123 --request-changes --body "Changes needed"
gh pr review 123 --comment --body "Some observations"
```
