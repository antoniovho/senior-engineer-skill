# Comment Review Template

Use this template for neutral feedback (non-blocking). Code-specific discussion points go as **inline comments**, general observations go in the body.

## Using MCP (Primary — MUST use when available)

### Review Body (submitted with `event: "COMMENT"`)

The body should contain **only** general observations and questions not tied to specific lines. Do NOT list file-specific points here.

```
## Review Observations

General observations on the pull request (not blocking).

### General Notes

- Overall observation about approach or architecture
- Question about design decision

### Questions

- Question for the author not tied to a specific line?
- Clarification needed about the overall approach?

Let me know your thoughts on these points.
```

### Discussion Points (as inline comments)

Each code-specific discussion point goes as a separate inline comment. Call the MCP tool `github_add_comment_to_pending_review` (this is a tool call, NOT a shell command).

**With a code alternative** (use ` ```suggestion ` block):

Call `github_add_comment_to_pending_review` with:
- `owner`: "..."
- `repo`: "..."
- `pullNumber`: \<number\>
- `path`: "src/handler.js"
- `line`: 23
- `side`: "RIGHT"
- `subjectType`: "LINE"
- `body`: "Have you considered using a strategy pattern here?\n\`\`\`suggestion\nconst handler = strategies.get(type);\nreturn handler.process(input);\n\`\`\`"

**Without a code alternative** (observation/question):

Call `github_add_comment_to_pending_review` with:
- `owner`: "..."
- `repo`: "..."
- `pullNumber`: \<number\>
- `path`: "src/utils.js"
- `line`: 55
- `side`: "RIGHT"
- `subjectType`: "LINE"
- `body`: "This function seems to duplicate the logic in parseConfig() on line 12. Could they share a common helper?"

### Workflow

1. `github_pull_request_review_write` → `method: "create"` (no event)
2. `github_add_comment_to_pending_review` → one call per discussion point (use ` ```suggestion ` blocks when applicable)
3. `github_pull_request_review_write` → `method: "submit_pending"`, `event: "COMMENT"`, `body: "<review body above>"`

---

## Using CLI (Last Resort Only)

> **Use ONLY if GitHub MCP tools are unavailable.**

CLI does not support inline comments, so all points go in the body:

```bash
gh pr review <number> --comment --body "$(cat <<'EOF'
## Review Observations

General observations on the pull request (not blocking).

### Discussion Points

1. **Point 1**: Question or observation
   - File: `path/to/file.ext:line`
   - Context or reasoning
   - Suggested alternative (if applicable)

2. **Point 2**: Question or observation
   - Context or reasoning

### Suggestions

- Suggestion 1 (optional)
- Suggestion 2 (optional)

### Questions

- Question for the author?
- Clarification needed?

Let me know your thoughts on these points.
EOF
)"
```
