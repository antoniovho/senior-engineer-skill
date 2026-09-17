# Approval Review Template

Use this template when approving a PR. Minor suggestions go as **inline comments**, not in the body.

## Using MCP (Primary — MUST use when available)

### Review Body (submitted with `event: "APPROVE"`)

The body should contain **only** the overall summary. Do NOT list file-specific suggestions here.

```
## Approval

Overall assessment of the pull request.

### Highlights

- Positive aspect 1
- Positive aspect 2
- Positive aspect 3

### Testing

Confirmation that changes have been tested or reviewed for correctness.

**Approved** — Ready to merge.
```

### Minor Suggestions (as inline comments)

Each non-blocking suggestion goes as a separate inline comment. Call the MCP tool `github_add_comment_to_pending_review` (this is a tool call, NOT a shell command) with:

- `owner`: "..."
- `repo`: "..."
- `pullNumber`: \<number\>
- `path`: "src/example.js"
- `line`: 42
- `side`: "RIGHT"
- `subjectType`: "LINE"
- `body`: "Minor: consider using a constant here:\n\`\`\`suggestion\nconst MAX_RETRIES = 3;\n\`\`\`"

### Workflow

1. `github_pull_request_review_write` → `method: "create"` (no event)
2. `github_add_comment_to_pending_review` → one call per minor suggestion (use ` ```suggestion ` blocks)
3. `github_pull_request_review_write` → `method: "submit_pending"`, `event: "APPROVE"`, `body: "<review body above>"`

---

## Using CLI (Last Resort Only)

> **Use ONLY if GitHub MCP tools are unavailable.**

CLI does not support inline comments, so all suggestions go in the body:

```bash
gh pr review <number> --approve --body "$(cat <<'EOF'
## Approval

Overall assessment of the pull request.

### Highlights

- Positive aspect 1
- Positive aspect 2

### Minor Suggestions (non-blocking)

- Optional improvement 1
- Optional improvement 2

### Testing

Confirmation that changes have been tested or reviewed for correctness.

**Approved** — Ready to merge.
EOF
)"
```
