---
name: conventional-commits
description: Create git commits following the Conventional Commits specification. Use when making commits, staging changes, or writing commit messages. Enforces structured commit messages with type, optional scope, and description. Use for tasks like "commit these changes", "create a commit for this fix", "stage and commit my work", "write a commit message for these changes".
---

# Conventional Commits

Conventional Commits is a specification for structuring commit messages to be human- and machine-readable.

## Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Rules

- **type** and **description** are mandatory
- Description must be in lowercase, imperative mood, no period at end
- Breaking changes: append `!` after type/scope, or add `BREAKING CHANGE:` footer
- Multiple footers are allowed (one per line)

## Types

| Type       | Use when                                   |
|------------|--------------------------------------------|
| `feat`     | Adding a new feature                       |
| `fix`      | Fixing a bug                               |
| `docs`     | Documentation only changes                 |
| `style`    | Formatting, whitespace (no logic change)   |
| `refactor` | Code restructuring (no feature/fix)        |
| `test`     | Adding or updating tests                   |
| `chore`    | Build process, tooling, dependency updates |
| `perf`     | Performance improvements                   |
| `ci`       | CI/CD configuration changes                |
| `revert`   | Reverting a previous commit                |

## Examples

```bash
# Simple feature
git commit -m "feat: add user authentication endpoint"

# Bug fix with scope
git commit -m "fix(auth): handle expired token gracefully"

# Breaking change
git commit -m "feat!: remove deprecated v1 API endpoints"

# With body and footer
git commit -m "fix(payments): prevent duplicate charge on retry" \
           -m "Idempotency key was not being sent on retried requests, causing the payment provider to process them as new charges." \
           -m "Fixes #234"

# Docs update
git commit -m "docs: update contributing guide with commit conventions"

# Chore
git commit -m "chore: upgrade dependencies to latest patch versions"
```

## Workflow

1. Stage changes: `git add <files>` (or `git add -A` for all)
2. Write the commit message following the format above
3. Commit: `git commit -m "<message>"`

For multi-line messages, use `-m` multiple times or a heredoc:

```bash
git commit -m "fix(api): correct pagination offset calculation" \
           -m "The offset was calculated as page * size instead of (page-1) * size." \
           -m "Fixes #89"
```

## Scope Guidelines

- Use scope to identify the module, component, or area affected
- Keep scopes short and consistent across commits (e.g., `auth`, `api`, `ui`, `db`)
- Omit scope when the change is global or cross-cutting

## Breaking Changes

Mark breaking changes with `!` after the type (and scope):

```bash
git commit -m "feat(api)!: rename /users endpoint to /accounts"
```

Or use a `BREAKING CHANGE:` footer:

```bash
git commit -m "refactor: restructure config file format" \
           -m "BREAKING CHANGE: Config keys have been renamed. See migration guide."
```
