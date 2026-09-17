# API Structure and Organization

Rules governing file layout, component naming, path organization, and import discipline for OpenAPI specifications.

---

## File Organization

✅ **Best Practice**: Split large API specifications into multiple files for maintainability.

```text
openapi-rest.yml   ← main entry point
apis/<domain>/     ← per-resource YAMLs
```

❌ **Avoid**: One large monolithic OpenAPI file.

---

## Required Files per API Package

### `metadata.yml`

`ALWAYS` include `metadata.yml` in the root of each API folder. It defines essential API metadata.

```yaml
api:
  name: "My API"
  version: "0.2.1"
  definition: openapi-rest.yml
  type: kernel
  visibility: TEAM
  description: REST API intended for showing Schema Sets structure
  contact:
    name: API Team
    email: lddapifirst@inditex.com
  tags:
    - API Schema Sets
```

Valid values for `type`: `kernel` | `application`
Valid values for `visibility`: `PUBLIC` | `TEAM`
Required value for `api-spec-type` in `apis/metadata.yml` registry: `rest`

### `README.md`

`ALWAYS` include `README.md` with **all six mandatory sections** in this exact order:

```markdown
# My API Documentation

## About
## Configuration
## Main Goal
## Specifics
## Example
## Usage
```

> ⚠️ The `## Example` section is **required by the API Portal certification engine** (rule `EX_MD054 / inditex-mandatory-example`). Omitting it causes a documentation score penalty.
> See [readme-documentation.md](readme-documentation.md) for section content rules and markdown quality requirements (bare URLs, email formatting, etc.).

### `SUMMARY.md`

For REST APIs only: **single line, 80–150 characters**, used in the API Portal. Never create `SUMMARY.md` for AsyncAPI, gRPC, or GraphQL. Verify length with `echo -n "..." | wc -c`.

---

## Recommended Folder Structure

```text
/apis/
  /books/
    books.yml
  /users/
    users.yml
  /libraries/
    libraries.yml
  openapi-rest.yml   ← main file
  metadata.yml       ← metadata file
  readme.md          ← documentation file
```

---

## File Naming

✅ **Use lowercase kebab-case**:
```text
books.yml, users.yml, libraries.yml
```

❌ **Avoid**:
```text
BooksAPI.yml, users_api.yml, Library-API.yml
```

---

## Component Organization

Organize schemas **by domain**, not in a single shared file:

✅ **Good**:
```text
/apis/
  /domain1/
    schemas.yml   # schemas specific to domain1
  /domain2/
    schemas.yml   # schemas specific to domain2
  /shared/
    schemas.yml   # truly common/shared schemas only
```

❌ **Avoid**:
```text
/apis/
  /shared/
    schemas.yml   # ALL schemas from all domains
```

---

## Component Naming — No Collisions

Schema names must be clearly distinct from one another. Case variants of the same base name cause issues in code generation.

✅ **Good** — clearly different names:
```yaml
components:
  schemas:
    user:
      type: object
      properties:
        id: { type: integer }
        name: { type: string }
    UserDetails:
      type: object
      properties:
        userId: { type: integer }
        email: { type: string }
```

❌ **Bad** — too similar to `user`:
```yaml
components:
  schemas:
    user:
      type: object
    User:           # ❌ differs only in case
      type: object
```

---

## Path Organization in Main File

Group related paths with comments for readability:

✅ **Good**:
```yaml
paths:
  # Books
  /books:
    $ref: 'books/books.yml#/paths/~1books'

  # Users
  /users:
    $ref: 'users/users.yml#/paths/~1users'
```

---

## Component References

Always use `$ref` to reference reusable components:

```yaml
paths:
  /books/{bookId}:
    $ref: 'books/books.yml#/paths/~1books~1{bookId}'
```

---

## Import Discipline

✅ **Import only directly used refs**. Components defined in imported files are inherited automatically — do not re-import nested dependencies.

❌ **Do not** import a nested dependency file that is not used directly in the current file.
