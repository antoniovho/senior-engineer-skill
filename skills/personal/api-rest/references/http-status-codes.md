# HTTP Status Code Rules for OpenAPI

Rules enforcing correct and consistent HTTP status codes for each operation type, with conditional requirements based on parameters, security, and context.

---

## 📥 POST Endpoints

**Required success codes** — at least one of: `200`, `201`, `202`, `204`, `206`.

**Conditional requirements:**
- `400` — only if path parameters, query parameters, or request body is defined.
- `401` + `403` — only if a security schema is defined.
- `404` — only if path parameters are defined.

❌ Do NOT use `default` as the sole success response.

✅ **Good**:
```yaml
post:
  summary: Create a user
  requestBody: ...
  responses:
    '201': { description: Created }
    '400': { description: Invalid input }
```

❌ **Bad**:
```yaml
post:
  summary: Create a user
  requestBody: ...
  responses:
    'default': { description: Success }   # ❌ must use explicit codes
```

---

## 📤 PUT Endpoints

**Required success codes** — at least one of: `200`, `201`, `202`, `204`, `206`.

**Conditional requirements:**
- `400` — only if path parameters, query parameters, or request body is defined.
- `401` + `403` — only if a security schema is defined.
- `404` — only if path parameters are defined.

✅ **Good**:
```yaml
put:
  summary: Update user
  parameters:
    - name: userId
      in: path
      required: true
      schema: { type: string }
  security:
    - bearerAuth: []
  responses:
    '200': { description: OK }
    '400': { description: Invalid data }
    '401': { description: Unauthorized }
    '403': { description: Forbidden }
    '404': { description: Not found }
```

❌ **Bad**:
```yaml
put:
  summary: Update user
  parameters:
    - name: userId
      in: path
      required: true
      schema: { type: string }
  responses:
    '200': { description: OK }
    # ❌ missing 400, 401, 403, 404
```

---

## ✏️ PATCH Endpoints

**Required success codes** — at least one of: `200`, `201`, `202`, `204`, `206`.

**Conditional requirements** — same as PUT:
- `400`, `401`, `403`, `404` based on parameters and security context.

✅ **Good**:
```yaml
patch:
  summary: Update user email
  requestBody: ...
  parameters:
    - name: userId
      in: path
      required: true
      schema: { type: string }
  security:
    - bearerAuth: []
  responses:
    '202': { description: Accepted }
    '400': { description: Invalid data }
    '401': { description: Unauthorized }
    '403': { description: Forbidden }
    '404': { description: Not found }
```

❌ **Bad**:
```yaml
patch:
  summary: Partial update
  responses:
    '200': { description: OK }
    # ❌ missing all conditional responses
```

---

## 🗑 DELETE Endpoints

**Required success codes** — at least one of: `204`, `202`.

**Must NOT return**: `201` or `206`.

**Conditional requirements:**
- `400` — only if path parameters, query parameters, or request body is defined.
- `401` + `403` — only if a security schema is defined.
- `404` — only if path parameters are defined.
- `409` — only if conflict scenarios are expected (e.g., deletion blocked by dependencies).

✅ **Good**:
```yaml
delete:
  summary: Delete product
  parameters:
    - name: productId
      in: path
      required: true
      schema: { type: string }
  responses:
    '204': { description: Deleted }
    '404': { description: Not found }
    '409': { description: Product is associated with open orders }
```

❌ **Bad**:
```yaml
delete:
  summary: Delete product
  responses:
    '200': { description: Deleted }   # ❌ should be 204
    '201': { description: Created }   # ❌ makes no sense for DELETE
```

---

## 📖 GET Endpoints

**Required success codes** — at least one of: `200`, `202`, `206`.

**Should NOT return**: `201`, `204`.

**Conditional requirements:**
- `400` — only if path parameters, query parameters, or request body is defined.
- `401` + `403` — only if a security schema is defined.
- `404` — only if path parameters are defined.

✅ **Good**:
```yaml
get:
  summary: Retrieve user
  parameters:
    - name: userId
      in: path
      required: true
      schema: { type: string }
  security:
    - bearerAuth: []
  responses:
    '200': { description: OK }
    '400': { description: Bad request }
    '401': { description: Unauthorized }
    '403': { description: Forbidden }
    '404': { description: Not found }
```

❌ **Bad**:
```yaml
get:
  summary: Retrieve user
  responses:
    '201': { description: Created }   # ❌ incorrect for GET
    '204': { description: No content } # ❌ unclear intent for GET
```

---

## 🧱 General Status Code Conventions

- Only standard HTTP status codes are allowed.
- All `4xx` and `5xx` responses must return a structured Error object:
  - Required fields: `type`, `status`, `title`, `detail`, `timestamp`.
  - Must use `Content-Type: application/problem+json`.

See [shared-error-definitions.md](shared-error-definitions.md) for the JFrog `$ref` patterns.

---

## 🔍 Conditional Status Code Decision Table

| Code | When Required |
|---|---|
| `400 Bad Request` | Any parameter (query, path) or request body is defined |
| `404 Not Found` | A **path parameter** exists |
| `401 Unauthorized` | A **security schema** is defined |
| `403 Forbidden` | A **security schema** is defined |
| `409 Conflict` | `DELETE` endpoint with potential business conflicts |

---

## 📝 Validation Prompt

> "Do all endpoints return required status codes based on parameter and security context?"
> "Check if my endpoints return proper status codes and RFC9457 errors"
