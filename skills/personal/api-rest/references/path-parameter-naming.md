# OpenAPI Path Design Rules

Rules for path naming, parameter conventions, query parameter defaults, and ambiguity prevention.

---

## ⚠️ Ambiguity and Equivalence Validation — MANDATORY

Before generating ANY endpoint, perform the following validation. **API certification will block publication if ambiguous or equivalent paths are found.**

### Equivalent Paths (NEVER allowed)

Two paths are **equivalent** if they are identical after path template substitution.

❌ **Bad**:
```
/users/{id}
/users/{userId}
```
These resolve to the same URL pattern.

### Ambiguous Paths (requires confirmation)

Two paths are **ambiguous** if a concrete URL could match either:

⚠️ **Warning**:
```
/users/{id}
/users/active
```
`/users/active` could match both paths.

⚠️ **Warning**:
```
/{entity}/me
/books/{id}
```

### Validation Steps

**Step 1** — Check for Equivalent Paths:
- List all existing paths with parameters.
- Verify the new path does not match any existing pattern after substitution.
- **STOP and REFUSE** if equivalent paths are detected.

**Step 2** — Check for Ambiguous Paths:
- Identify static segments that could match existing path parameters.
- **STOP and ASK** the user if ambiguity is detected.

**Step 3** — User Confirmation Required when ambiguity is found:
1. Show the conflict explicitly.
2. Ask: "This creates a routing ambiguity. Are you intentionally designing this for testing purposes?"
3. Wait for explicit approval.
4. Document the ambiguity prominently if approved.

> **RULE**: Never generate equivalent paths under any circumstances. Always confirm before generating ambiguous paths.

---

## 🔡 Paths Must Be Lowercase

✅ **Good**:
```yaml
paths:
  /user-preferences:
```

❌ **Bad**:
```yaml
paths:
  /UserPreferences:   # ❌ uppercase
```

---

## 🐍 Use kebab-case in Path Segments

✅ **Good**:
```text
/api/book-reviews
```

❌ **Bad** — underscores:
```text
/api/book_reviews
```

---

## 🐫 Path Parameters Must Be camelCase

✅ **Good**:
```yaml
parameters:
  - name: userId
    in: path
```

❌ **Bad**:
```yaml
parameters:
  - name: user_id    # ❌ snake_case
```

---

## 🐫 Query Parameters Must Be camelCase

✅ **Good**:
```yaml
parameters:
  - name: sortBy
    in: query
```

❌ **Bad**:
```yaml
parameters:
  - name: sort_by    # ❌ snake_case
```

---

## 🧱 Limit Path Segment Depth

No more than **6 static segments** (excluding path parameters).

✅ **Good**:
```yaml
/users/{userId}/orders/{orderId}/items:
```

❌ **Bad**:
```yaml
/a/b/c/d/e/f/g:   # ❌ more than 6 segments
```

---

## 🚫 No Required Query Parameters on Modifying Verbs (POST, PUT, PATCH)

Query parameters on `POST`, `PUT`, and `PATCH` must not be marked `required: true`.

✅ **Good**:
```yaml
parameters:
  - name: trackingId
    in: query
    required: false
    schema:
      type: string
      default: "auto"
```

❌ **Bad**:
```yaml
parameters:
  - name: trackingId
    in: query
    required: true    # ❌ required query param on POST
```

---

## 🚫 No Required Query Parameters on GET / DELETE Either

Even on `GET` or `DELETE`, query parameters should not be `required`.

✅ **Good**:
```yaml
parameters:
  - name: filter
    in: query
    required: false
    schema:
      type: string
      default: "active"
```

❌ **Bad**:
```yaml
parameters:
  - name: filter
    in: query
    required: true    # ❌ should not be required
```

---

## 🧰 Optional Query Parameters Must Define a `default`

Every non-required query parameter **must** include a `default` value.

Rules:
- `schema.default` must be explicitly set (not just described in `description`).
- If `default: null`, then `nullable: true` **must** also be set.
- If `default: null` and `enum` is defined, `null` **must** be in the enum values.

✅ **Good** — numeric default:
```yaml
parameters:
  - name: limit
    in: query
    required: false
    schema:
      type: integer
      default: 10
```

✅ **Good** — nullable default:
```yaml
parameters:
  - name: limit
    in: query
    required: false
    schema:
      type: integer
      nullable: true
      default: null
```

✅ **Good** — enum with null default:
```yaml
parameters:
  - name: status
    in: query
    required: false
    schema:
      type: string
      enum: [ACTIVE, INACTIVE, PENDING, null]
      nullable: true
      default: null
```

❌ **Bad** — missing default:
```yaml
parameters:
  - name: limit
    in: query
    required: false
    schema:
      type: integer
      # ❌ missing default
```

❌ **Bad** — non-nullable default null:
```yaml
parameters:
  - name: limit
    in: query
    required: false
    schema:
      type: integer
      default: null   # ❌ requires nullable: true
```

❌ **Bad** — empty string default:
```yaml
parameters:
  - name: limit
    in: query
    required: false
    schema:
      type: integer
      default: ""     # ❌ empty default
```

---

## 🚫 No Hyphens as Wildcards in Path Templates

Only curly braces are valid for path templates.

✅ **Good**:
```yaml
/users/{userId}/orders/{orderId}/items:
```

❌ **Bad**:
```yaml
/users/{userId}/orders/-/items:   # ❌ hardcoded hyphen as wildcard
```

---

## 📝 Validation Prompt

> "Check that all paths use lowercase, camelCase params, and safe query defaults"
> "Verify there are no ambiguous or equivalent paths in this spec"
