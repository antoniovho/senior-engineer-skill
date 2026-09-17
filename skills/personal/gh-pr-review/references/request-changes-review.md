# Request Changes Review Template

Use this template when requesting changes on a PR. Critical issues go as **inline comments** on the specific lines, not listed in the body.

## Using MCP (Primary — MUST use when available)

### Review Body (submitted with `event: "REQUEST_CHANGES"`)

The body should contain **only** the executive summary and next steps. Do NOT list file-specific issues here — they go as inline comments.

```
## Changes Required

Overview of required changes before approval.

### Summary

Brief executive summary of the issues found (without file/line details — those are in inline comments).

### Additional Concerns

- General concern not tied to a specific line
- Another general concern

### Testing Recommendations

Specific tests that should be added or updated.

### Next Steps

Please address the inline comments and re-request review.
```

### Critical Issues (as inline comments)

Each critical issue goes as a separate inline comment. Call the MCP tool `github_add_comment_to_pending_review` (this is a tool call, NOT a shell command).

**With a concrete fix** (use ` ```suggestion ` block):

Call `github_add_comment_to_pending_review` with:
- `owner`: "..."
- `repo`: "..."
- `pullNumber`: \<number\>
- `path`: "src/service.js"
- `line`: 87
- `side`: "RIGHT"
- `subjectType`: "LINE"
- `body`: "**Critical**: This will throw a NullPointerException when input is empty.\n\`\`\`suggestion\nif (input == null || input.isEmpty()) {\n    return Collections.emptyList();\n}\n\`\`\`"

**Without a concrete fix** (describe problem and impact):

Call `github_add_comment_to_pending_review` with:
- `owner`: "..."
- `repo`: "..."
- `pullNumber`: \<number\>
- `path`: "src/config.yml"
- `line`: 15
- `side`: "RIGHT"
- `subjectType`: "LINE"
- `body`: "**Critical**: This timeout value is too low for production. It should be at least 30s to handle peak load."

### Workflow

1. `github_pull_request_review_write` → `method: "create"` (no event)
2. `github_add_comment_to_pending_review` → one call per critical issue (use ` ```suggestion ` blocks when possible)
3. `github_pull_request_review_write` → `method: "submit_pending"`, `event: "REQUEST_CHANGES"`, `body: "<review body above>"`

---

## Using CLI (Last Resort Only)

> **Use ONLY if GitHub MCP tools are unavailable.**

CLI does not support inline comments, so all issues must go in the body:

```bash
gh pr review <number> --request-changes --body "$(cat <<'EOF'
## Changes Required

Overview of required changes before approval.

### Critical Issues

1. **Issue Category**: Brief description
   - File: `path/to/file.ext:line`
   - Impact: Why this matters
   - Suggested fix: How to resolve

2. **Issue Category**: Brief description
   - File: `path/to/file.ext:line`
   - Impact: Why this matters
   - Suggested fix: How to resolve

### Additional Concerns

- Concern 1
- Concern 2

### Testing Recommendations

Specific tests that should be added or updated.

### Next Steps

Please address the critical issues and re-request review.
EOF
)"
```
