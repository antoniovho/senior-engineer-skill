---
name: gh-pr-comment
description: Add comments to pull requests using GitHub MCP or gh CLI. Use when adding general PR comments, code examples in comment body, or discussion points (not formal reviews). Supports markdown formatting, code blocks, and mentions. Does NOT handle line-specific inline comments on diffs or interactive suggestion blocks — use the gh-pr-review skill for those.
---

# GitHub Pull Request Comments (MCP + CLI)

Add comments to pull requests using GitHub MCP tools (for inline comments) or gh CLI (for general comments).

## Comment vs Review

| Use Case | Tool/Command |
|----------|--------------|
| General discussion, questions, updates | `gh pr comment` CLI (this skill) |
| Inline feedback on specific lines | MCP pending review workflow |
| Reply to existing comment thread | `github_add_reply_to_pull_request_comment` MCP tool |
| Formal approve/request-changes | `gh-pr-review` skill |

Comments don't affect PR merge status; reviews can block merging.

## For Inline Comments: Use MCP Pending Review

To add comments on specific lines/files, use the **gh-pr-review** skill with the pending review workflow:

1. Create pending review
2. Add inline comments with `github_add_comment_to_pending_review`
3. Submit as `COMMENT` (non-blocking)

See the **gh-pr-review** skill for detailed instructions.

## For General Comments: Use CLI

### Basic Comment

```bash
gh pr comment 789 --body "$(cat <<'EOF'
Your comment in markdown format.

Additional details here.
EOF
)"
```

### By Branch

```bash
gh pr comment feature-branch --body "Comment on the PR for this branch"
```

### By URL

```bash
gh pr comment https://github.com/owner/repo/pull/789 --body "Comment text"
```

### Cross-Repository

```bash
gh pr comment 789 -R owner/repo --body "Comment text"
```

### Edit Last Comment

```bash
gh pr comment 789 --edit-last --body "Updated comment"
```

## MCP Tool: Reply to Comment Thread

### github_add_reply_to_pull_request_comment

Reply to an existing comment thread.

**Parameters:**
- `owner`: Repository owner (string, required)
- `repo`: Repository name (string, required)
- `pullNumber`: PR number (number, required)
- `commentId`: ID of comment to reply to (number, required)
- `body`: Reply text (string, required)

**Example:**
```
github_add_reply_to_pull_request_comment(
  owner="inditex",
  repo="mic-ghcajava",
  pullNumber=62,
  commentId=12345678,
  body="Good point! I've updated the implementation accordingly."
)
```

## CLI Flags Reference

| Flag | Description |
|------|-------------|
| `-b, --body` | Comment body text |
| `-F, --body-file` | Read body from file |
| `--edit-last` | Edit your last comment |
| `--delete-last` | Delete your last comment |
| `-R, --repo` | Target repository (owner/repo) |

## Formatting Features

- **Code blocks**: Triple backticks with language identifier for syntax highlighting
- **Mentions**: `@username` for notifications
- **PR/Issue refs**: `#123` to link related items
- **File links**: Reference specific files in the PR
- **Task lists**: `- [ ]` for action items

> **Note on `suggestion` blocks**: GitHub's interactive "Apply suggestion" button **only works in inline review comments** created via `github_add_comment_to_pending_review` (see the **gh-pr-review** skill). In general PR comments posted via `gh pr comment`, ` ```suggestion ` blocks render as plain code blocks with no interactive functionality. Use regular language-tagged code blocks (e.g. ` ```javascript `) to show proposed code in general comments.

### Showing Proposed Code in General Comments

````markdown
```javascript
// Proposed replacement code
const result = processData(input);
```
````

## Examples

### General PR Comment (CLI)

```bash
gh pr comment 456 --body "$(cat <<'EOF'
## Feedback

Great progress on this feature! A few observations:

- The API design looks clean
- Consider adding more test coverage for edge cases
- Documentation is clear and helpful

Let me know if you have questions.
EOF
)"
```

### Status Update (CLI)

```bash
gh pr comment 123 -R myorg/frontend --body "$(cat <<'EOF'
## Update

I've addressed the review feedback:

- [x] Fixed the null check issue
- [x] Added unit tests
- [x] Updated documentation

Ready for another look when you have time.

@reviewer
EOF
)"
```

### Reply to Existing Comment (MCP)

First, get the comment ID from the PR, then:

```
github_add_reply_to_pull_request_comment(
  owner="myorg",
  repo="myrepo",
  pullNumber=456,
  commentId=987654321,
  body="Thanks for the feedback! I've made those changes."
)
```

## When to Use MCP vs CLI

| Scenario | Recommended Approach |
|----------|---------------------|
| General PR discussion | CLI (`gh pr comment`) |
| Quick question/update | CLI (`gh pr comment`) |
| Status update | CLI (`gh pr comment`) |
| Inline code feedback on specific lines | MCP (pending review, see gh-pr-review skill) |
| Multiple inline comments | MCP (batch in single review) |
| Reply to existing thread | MCP (`github_add_reply_to_pull_request_comment`) |

## Thread Reply Templates

Use these templates when replying to individual review comment threads via `github_add_reply_to_pull_request_comment`.

### Thread reply — change applied

```
<short-commit-hash> <one-phrase summary of what changed — be specific, not generic>
```

Write the commit hash **unescaped** (no backticks, no code span) so GitHub renders it as a clickable commit link. Example:

```
a1b2c3d4 renamed variable `retVal` to `processingResult` in UserService.java
```

### Thread reply — stale comment

```
This comment refers to code that no longer exists in the current diff — marking as stale.
```

### Thread reply — skipped comment

```
Skipping this change: <specific reason, e.g. "ambiguous intent", "requires architectural decision", "conflicts with change applied in another thread">.
```

---

## Failure Report Template

Use this template when reporting a non-fixable failure back to the PR via `gh pr comment`:

```markdown
## DarwinAgent Failure Report

**Command:** `/<command-name>`
**Failed step:** <step number and name, e.g. "Step 3 — Fetch review threads">
**Error:** <exact error message or HTTP status code>

**Why it cannot be fixed automatically:**
<one sentence explaining why this requires human intervention>

**Action required:**
<specific action the user must take to unblock, e.g. "grant `contents:write` permission to the GitHub token", "ensure the PR exists and is accessible">
```

---

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| "pull request not found" | Invalid PR | Verify PR number/URL |
| "permission denied" | No access | Check repository permissions |
| "authentication required" | Not logged in | Run `gh auth status` or `opencode mcp auth github` |
