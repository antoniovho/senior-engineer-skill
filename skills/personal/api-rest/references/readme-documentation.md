# README and SUMMARY Documentation Rules

Rules for writing correct, certification-compliant `README.md` and `SUMMARY.md` files for every REST API package.

---

## apis/README.md (Base Catalog) — Mandatory Content

The base catalog file `apis/README.md` is required and must describe the repository-level API registry.

It must include at least:

- Purpose of the `apis/` registry.
- A list or table of APIs including `name`, `definition-path`, and a short description.
- Maintenance guidance explaining how to add or update registry entries.
- A pointer/reference to each API folder README.

---

## README.md — Mandatory Sections

`ALWAYS` include **all nine sections** in the following order. Missing any section will cause a documentation certification failure.

```markdown
# <API Title> Documentation

## Summary
## About
## Get Started
## Configuration
## Main Goal
## Specifics
## Example
## Usage
## Support
```

> ⚠️ **`## Example` is mandatory for certification.** Its absence triggers rule `EX_MD054 / inditex-mandatory-example` and reduces the documentation score. This section must always be present even if other sections vary.

---

## README.md — Section Content Guide

### `## Summary`

One or two sentences that describe the API at a glance. Used as the consumer-facing elevator pitch.

```markdown
## Summary

The Books API exposes RESTful endpoints to browse and manage book entities in the catalog, secured with Bearer JWT authentication.
```

---

### `## About`

Short paragraph describing what the API is and who it serves.

```markdown
## About

The Books API provides a RESTful interface for managing book entities in the catalog.
```

---

### `## Get Started`

Minimal steps a consumer needs to make a first successful call: authentication, base URL, and a quick example.

```markdown
## Get Started

1. Obtain a Bearer JWT token from the authentication service.
2. Set the base URL: `https://api.inditex.com/books/v1`.
3. Make your first call:

```http
GET /books?limit=5&offset=0
Authorization: Bearer <token>
```
```

---

### `## Configuration`

A table listing key API properties: type, visibility, version, spec file, and contact email.

```markdown
## Configuration

| Property       | Value                          |
|----------------|-------------------------------|
| API Type       | application                   |
| Visibility     | PUBLIC                        |
| Version        | 1.0.0                         |
| Spec File      | openapi-rest.yml              |
| Contact Email  | <team@inditex.com>            |
```

> ⚠️ **Emails must be wrapped in angle brackets** (`<email@domain.com>`) in markdown tables and prose. A bare email address (e.g., `team@inditex.com` without `<>`) triggers rule `MD034 / no-bare-urls` and causes a certification warning.

---

### `## Main Goal`

One or two sentences explaining the business purpose of the API.

```markdown
## Main Goal

Enable consumers to browse the catalog and register new titles through a
standards-compliant REST API following Inditex API design guidelines.
```

---

### `## Specifics`

Bullet list of the available endpoints and their behaviour. Reference the HTTP method, path, and a brief description of each operation.

```markdown
## Specifics

- `GET /books` — Returns a paginated list of books wrapped in a `data` array with a `pagination` object.
- `POST /books` — Creates a new book record and returns the created entity with its generated identifier.
- All error responses follow `application/problem+json` using JFrog shared error definitions.
- Authentication via Bearer JWT token (global security scheme).
```

---

### `## Example`

**This section is required by the API Portal certification engine.**

Provide at least one realistic request/response HTTP block. Use `http` fenced code blocks.

```markdown
## Example

### List books

​```http
GET /books?limit=20&offset=0
Authorization: Bearer <token>
​```

### Create a book

​```http
POST /books
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "isbn": "978-0-7432-7356-5",
  "genre": "FICTION",
  "publishedDate": "1925-04-10",
  "isAvailable": true
}
​```
```

---

### `## Usage`

Additional usage instructions, integration notes, or environment-specific tips.

```markdown
## Usage

Use the `limit` and `offset` query parameters on `GET /books` to paginate results.
The `bookId` returned on `POST /books` is a UUID to be used in subsequent operations.
```

### `## Support`

Contact information and links for getting help: team email, Slack channel, or issue tracker.

```markdown
## Support

For questions or issues, contact the team at <books-api-team@inditex.com> or open a ticket in the internal issue tracker.
```

---

## SUMMARY.md — Rules

- **REST APIs only** — do not create `SUMMARY.md` for AsyncAPI, gRPC, or GraphQL.
- Must be a **single line**, **80–150 characters** (inclusive).
- No trailing newline beyond the one implicit in the file.
- Used verbatim in the API Portal listing — write it as a consumer-facing description.

✅ **Good** (89 chars):
```
REST API for managing book entities — supports paginated list and create operations with JWT authentication.
```

❌ **Bad — too short** (< 80 chars):
```
Books API.
```

❌ **Bad — too long** (> 150 chars):
```
This is a REST API for managing book entities in the catalog system, supporting paginated list retrieval and create operations secured with JWT Bearer token authentication.
```

> **Tip**: Count characters before saving. Online tools or `echo -n "..." | wc -c` in terminal work well.

---

## Markdown Quality Rules (affect certification score)

| Rule | Code | Fix |
|---|---|---|
| Wrap emails in `<>` | `MD034 / no-bare-urls` | `<team@inditex.com>` instead of `team@inditex.com` |
| Wrap URLs in `<>` or use `[text](url)` | `MD034 / no-bare-urls` | `<https://example.com>` or `[Example](https://example.com)` |
| `## Example` section must exist | `EX_MD054 / inditex-mandatory-example` | Add `## Example` heading with at least one code block |
| No trailing spaces | `MD009` | Remove trailing whitespace from lines |
| Blank line before/after headings | `MD022` | Ensure one blank line before and after each `##` heading |
