---
name: gh-issue-comment
description: Add comments to GitHub issues using gh CLI. Use when commenting on issues, providing updates, asking questions, or responding to discussions. Supports mentions (@user), issue references (#123), and code blocks. Works with current repository or cross-repo via -R flag. Expects markdown-formatted comment content.
---

# GitHub Issue Comments

Add comments to existing GitHub issues using the `gh issue comment` command.

## Workflow

1. Identify the issue (number or URL)
2. Prepare markdown comment content
3. Execute command with body via heredoc or file

## Command Patterns

### Basic Comment

```bash
gh issue comment 123 --body "$(cat <<'EOF'
Your comment in markdown format.

Additional details here.
EOF
)"
```

### By URL

```bash
gh issue comment https://github.com/owner/repo/issues/123 --body "Comment text"
```

### Cross-Repository

```bash
gh issue comment 123 -R owner/repo --body "Comment text"
```

### From File

```bash
gh issue comment 123 --body-file comment.md
```

### Edit Last Comment

```bash
gh issue comment 123 --edit-last --body "Updated comment"
```

## Available Flags

| Flag | Description |
|------|-------------|
| `-b, --body` | Comment body text |
| `-F, --body-file` | Read body from file |
| `--edit-last` | Edit your last comment |
| `--delete-last` | Delete your last comment |
| `-R, --repo` | Target repository (owner/repo) |

## Formatting Features

- **Mentions**: `@username` to notify users
- **Issue refs**: `#123` to link issues in same repo
- **Cross-repo refs**: `owner/repo#123` for other repos
- **Commit refs**: Full SHA or short hash
- **Code blocks**: Triple backticks with language
- **Task lists**: `- [ ]` for checkboxes
- **Quotes**: `>` for quoting previous comments

## Reference Templates

For common scenarios, see:
- `references/implementation-complete.md` - Post after resolving a GitHub issue (draft PR open)
- `references/follow-up-comment.md` - Follow-up discussions
- `references/status-update-comment.md` - Progress updates
- `references/resolution-comment.md` - Issue resolution

## Failure Report Template

Use this template when reporting a non-fixable failure back to the issue via `gh issue comment`:

```markdown
## DarwinAgent Failure Report

**Command:** `/<command-name>`
**Failed step:** <step number and name, e.g. "Step 2 — Read the issue">
**Error:** <exact error message or HTTP status code>

**Why it cannot be fixed automatically:**
<one sentence explaining why this requires human intervention>

**Action required:**
<specific action the user must take to unblock, e.g. "provide an explicit issue number in the trigger comment", "grant `contents:write` permission to the GitHub token">
```

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| "issue not found" | Invalid issue number | Verify issue exists in repository |
| "permission denied" | No write access | Check repository permissions |
| "authentication required" | Not logged in | Run `gh auth status` |

## Examples

### Follow-up Question

```bash
gh issue comment 45 --body "$(cat <<'EOF'
Thanks for the detailed report!

A few clarifying questions:
1. Does this happen consistently or intermittently?
2. Have you tried clearing the cache?

@reporter let me know when you have a chance.
EOF
)"
```

### Status Update with Checklist

```bash
gh issue comment 89 -R myorg/project --body "$(cat <<'EOF'
## Progress Update

Work is progressing well on this issue.

### Completed
- [x] Database schema updated
- [x] API endpoint implemented

### In Progress
- [ ] Frontend integration
- [ ] Unit tests

ETA: End of week.
EOF
)"
```

### Resolution Comment

```bash
gh issue comment 102 --body "$(cat <<'EOF'
## Resolution

Fixed in commit abc1234.

**Root Cause**: The validation regex was too strict.

**Solution**: Updated regex to accept valid edge cases.

**Verification**: Added test cases covering the reported scenario.

This will be included in the next release.
EOF
)"
```
