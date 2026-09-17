# Commons & Metadata

Rules for contact information, resource identification, operationId, summaries, and response format — the foundational building blocks of every OpenAPI spec.

---

## ✅ Resource Identification

The fundamental concept in REST is the **resource**.

- A resource is an entity with a type, data, and relationships to other resources.
- It can be uniquely identified and manipulated (e.g., a document, video, product, repository).
- Once identified, use **plural nouns** to name them in URLs: `/users`, `/orders`, `/books`.

---

## Required Metadata

Every OpenAPI spec **must** include:

- `info.contact.email` — valid email address of the API team.
- `info.contact.url` — must be a properly formatted URI starting with `https://`.

✅ **Good**:
```yaml
info:
  contact:
    name: API Team
    email: lddapifirst@inditex.com
    url: https://my-api-docs.inditex.com
```

❌ **Bad**:
```yaml
info:
  contact:
    # missing email and url
```

❌ **Bad**:
```yaml
info:
  contact:
    url: http://insecure.example.com   # ❌ must start with https
```

---

## Summary and Description

Every operation **must** include both `summary` and `description`:

| Field | Rule |
|---|---|
| `summary` | Short, action-oriented. Must **not** repeat or closely match `description`. |
| `description` | Explains behavior, side effects, and use cases in detail. |

❌ **Avoid** generic phrases like "Summary", "Description", or "Create" alone.

✅ **Good**:
```yaml
get:
  summary: Retrieve a paginated list of active users
  description: Returns users filtered by status. Supports pagination via limit and offset. Only users with an active account are returned.
```

❌ **Bad**:
```yaml
get:
  summary: Get users
  description: Get users   # ❌ identical to summary
```

---

## `operationId` — Required on Every Operation

Each operation **must** define a non-empty `operationId`. It must be **unique** across the entire spec.

### Naming Rules

- Format: `verbNoun[Qualifier]` in camelCase (no hyphens).
- Must start with a letter or underscore.
- Subsequent characters must be letters, numbers, or underscores.
- Do **not** include HTTP method redundantly (e.g., `getUsers` → just `listUsers`).
- Do **not** include transport terms (e.g., `Rest`, `Http`, `Api`).
- Must be action-oriented; the verb must reflect intent.

### Canonical Verbs

| Intent | Canonical Verb |
|---|---|
| Retrieve a single resource | `get` |
| Retrieve a collection | `list` |
| Create | `create` |
| Replace (PUT) | `upsert` or `replace` (pick one, stay consistent) |
| Partial update | `update` or `patch` (pick one, stay consistent) |
| Delete | `delete` |
| Search with filters (POST/GET) | `search` |
| State change / domain action | domain verb: `confirm`, `cancel`, `reserve`, `exchange` |

### ✅ Good

```yaml
paths:
  /users:
    get:
      operationId: listUsers
    post:
      operationId: createUser
    put:
      operationId: replaceUser
    patch:
      operationId: updateUser
    delete:
      operationId: deleteUser
```

### ❌ Bad

```yaml
paths:
  /users:
    get:
      operationId: list-users       # ❌ hyphens not allowed
    post:
      operationId: createUserPost   # ❌ do not include 'Post'
    put:
      operationId: replaceUserRest  # ❌ do not include 'Rest'
    patch:
      operationId: modifyUser       # ❌ use 'updateUser' or 'patchUser'
    delete:
      operationId: DeleteUser       # ❌ must be camelCase
```

---

## Response Format

`GET` operations with 2xx responses **must not** return a root-level array. Wrap collections in a `data` property inside a root object:

✅ **Good**:
```json
{
  "data": [ ... ]
}
```

❌ **Bad**:
```json
[ ... ]   // ❌ root-level array
```

See [pagination-structure.md](pagination-structure.md) for the full pagination wrapping rules.

---

## 📝 Validation Prompt

> "Check all operations include operationId and suggest improvements to naming consistency"
> "Validate that info.contact.email and info.contact.url are properly defined"
