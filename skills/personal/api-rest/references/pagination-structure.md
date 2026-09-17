# OpenAPI Pagination and Response Structure Rules

Rules ensuring paginated and list responses follow the correct structure, naming conventions, and HATEOAS link format.

---

## 📦 Encapsulate List Responses in Objects — Never Root Arrays

Paginated `GET` responses for list endpoints **must return an object**, not a raw array.

✅ **Good**:
```yaml
paths:
  /users:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
```

❌ **Bad** — root-level array:
```yaml
paths:
  /users:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
```

---

## 🧭 Use a `data` Property for the Collection

All item collections **must** be nested inside a `data` property.

✅ **Good**:
```yaml
type: object
properties:
  data:
    type: array
    items:
      type: object
```

❌ **Bad** — custom name instead of `data`:
```yaml
type: object
properties:
  users:
    type: array    # ❌ must be named 'data'
```

---

## 🔢 Pagination Must Include `limit` and `offset`

When paginating, the response must include a `pagination` object with `limit` and `offset`.

✅ **Good**:
```yaml
type: object
required: [data, pagination]
properties:
  data:
    type: array
  pagination:
    type: object
    required: [limit, offset]
    properties:
      limit:
        type: integer
        example: 20
      offset:
        type: integer
        example: 0
```

❌ **Bad** — missing limit and offset:
```yaml
type: object
properties:
  data:
    type: array
  pagination:
    type: object
    # ❌ missing limit and offset
```

---

## 🔗 HATEOAS Links Must Include `rel` and `href`

When providing pagination links, each link object must define both `rel` and `href`.

✅ **Good** — full pagination object with links:
```yaml
pagination:
  type: object
  required: [limit, offset]
  properties:
    limit:
      type: integer
      example: 20
    offset:
      type: integer
      example: 0
    links:
      type: array
      items:
        type: object
        required: [rel, href]
        properties:
          rel:
            type: string
            enum: [self, prev, next, first]
            example: "self"
          href:
            type: string
            example: "https://api.example.com/users?limit=20&offset=0"
        examples:
          - rel: "self"
            href: "https://api.example.com/users?limit=20&offset=0"
          - rel: "next"
            href: "https://api.example.com/users?limit=20&offset=20"
          - rel: "prev"
            href: "https://api.example.com/users?limit=20&offset=-20"
          - rel: "first"
            href: "https://api.example.com/users?limit=20&offset=0"
```

❌ **Bad** — incomplete link object:
```yaml
links:
  type: object
  properties:
    next: { type: string }
    # ❌ missing self, prev, first; missing href structure
```

---

## 📝 Validation Prompt

> "Ensure list responses follow pagination structure with limit, offset, and links"
