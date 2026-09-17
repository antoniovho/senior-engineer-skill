# OpenAPI Security & Schema Rules

Rules for securing APIs and enforcing schema constraints to prevent injection, resource exhaustion, and misconfiguration.

---

## 🔐 Global Security Must Be Defined

Every spec **must** define a `security` field at global level.

✅ **Good**:
```yaml
security:
  - bearerAuth: []
```

❌ **Bad** — missing entirely:
```yaml
# no security field
```

---

## 🚫 No Operation-Level `servers`

Do not define `servers` inside individual operations. Use global `servers` only.

✅ **Good**:
```yaml
servers:
  - url: https://api.example.com
```

❌ **Bad**:
```yaml
paths:
  /users:
    get:
      servers:                     # ❌ not allowed here
        - url: https://api.dev.com
```

---

## 🔑 HTTPS Required for All Servers

All server URLs must use `https` or `localhost`.

✅ **Good**:
```yaml
servers:
  - url: https://api.example.com
```

❌ **Bad**:
```yaml
servers:
  - url: http://insecure.example.com   # ❌ http not allowed
```

---

## 🧪 String Parameters Must Define `maxLength` (except enum)

ALL string parameters (except those using `enum`) **must** define `maxLength`.

✅ **Good**:
```yaml
parameters:
  - name: filter
    in: query
    schema:
      type: string
      maxLength: 32
```

❌ **Bad**:
```yaml
parameters:
  - name: filter
    in: query
    schema:
      type: string
      # ❌ missing maxLength
```

---

## 🧪 String Properties in Request Bodies Must Define `maxLength` (except enum)

ALL string properties in request bodies (except enum) **must** define `maxLength`.

✅ **Good**:
```yaml
requestBody:
  content:
    application/json:
      schema:
        type: object
        properties:
          name:
            type: string
            maxLength: 50
```

❌ **Bad**:
```yaml
properties:
  name:
    type: string
    # ❌ missing maxLength
```

---

## 📋 Header Objects Must Define a Schema

All header parameters must have a `schema` with a defined type.

✅ **Good**:
```yaml
parameters:
  - name: custom-header
    in: header
    schema:
      type: string
      maxLength: 50
```

❌ **Bad**:
```yaml
parameters:
  - name: custom-header
    in: header
    # ❌ missing schema
```

---

## 🔁 Array Parameters Must Define `maxItems`

Always limit array size to prevent resource exhaustion.

✅ **Good**:
```yaml
parameters:
  - name: ids
    in: query
    schema:
      type: array
      items: { type: string }
      maxItems: 50
```

❌ **Bad**:
```yaml
schema:
  type: array
  items: { type: string }
  # ❌ missing maxItems
```

---

## 🧮 Numeric Fields Must Have `minimum` and `maximum`

All `integer` or `number` types **must** define bounds unless `readOnly`.

✅ **Good**:
```yaml
schema:
  type: integer
  minimum: 1
  maximum: 100
```

❌ **Bad**:
```yaml
schema:
  type: number
  # ❌ missing min/max
```

❌ **Bad** — only one bound:
```yaml
schema:
  type: number
  minimum: 0
  # ❌ missing maximum
```

---

## 🧾 String Fields Without `maxLength` Must Have `pattern` or `enum`

If `maxLength` is not specified, provide a `pattern` for format validation.

✅ **Good**:
```yaml
schema:
  type: string
  pattern: '^[a-z]+$'
```

❌ **Bad**:
```yaml
schema:
  type: string
  # ❌ missing both pattern and maxLength
```

---

## 🧱 Avoid Empty Schemas

Empty schemas accept any input. Always define type and structure.

✅ **Good**:
```yaml
schema:
  type: object
  properties:
    name: { type: string }
```

❌ **Bad**:
```yaml
schema: {}   # ❌ empty schema
```

---

## � Request/Response Schemas Must Use `additionalProperties: false` and Explicit `required`

All request and response body schemas **must** define:
- `additionalProperties: false` — prevents unintended extra fields from being accepted or returned.
- `required` array — explicitly lists all mandatory properties.

This prevents injection through unknown fields and makes contracts explicit and verifiable.

✅ **Good**:
```yaml
components:
  schemas:
    CreateUserRequest:
      type: object
      additionalProperties: false
      required:
        - name
        - email
      properties:
        name:
          type: string
          maxLength: 100
          example: "Alice"
        email:
          type: string
          maxLength: 200
          example: "alice@example.com"
```

❌ **Bad** — missing both constraints:
```yaml
components:
  schemas:
    CreateUserRequest:
      type: object
      properties:          # ❌ no additionalProperties: false
        name:              # ❌ no required array
          type: string
```

---

## �💼 Prohibited OAuth2 Flows

Do **NOT** use:
- `implicit` OAuth2 flow
- `password` OAuth2 flow
- OAuth1 protocol

✅ **Good**:
```yaml
type: oauth2
flows:
  authorizationCode:
    ...
```

❌ **Bad**:
```yaml
type: oauth2
flows:
  implicit: {}    # ❌ not allowed
  password: {}    # ❌ not allowed
```

---

## 🔑 Approved Authentication Schemes Only

Only IANA-approved schemes from the [OpenAPI Specification](https://swagger.io/docs/specification/v3_0/authentication/):

- `bearer`
- `apiKey`
- `basic`
- `oauth2`
- `openIdConnect`
- `cookieAuth`

✅ **Good**:
```yaml
scheme: bearer
```

❌ **Bad**:
```yaml
scheme: customHmacToken   # ❌ not IANA-approved
```

---

## 🛂 Security Field Must Reference Defined `securitySchemes`

Only schemes declared in `components.securitySchemes` can be used in `security`.

✅ **Good**:
```yaml
security:
  - itxBearerAuth: []

components:
  securitySchemes:
    itxBearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

❌ **Bad**:
```yaml
security:
  - oauth2:
      - read:data   # ❌ not defined in securitySchemes
```

---

## 🛂 OAuth2 Scopes Must Be Defined

If using OAuth2 with scopes, all required scopes must be declared in the scheme.

✅ **Good**:
```yaml
security:
  - oauth2:
      - read:data
```

❌ **Bad**:
```yaml
security:
  - oauth2: []   # ❌ but scopes are required by the scheme
```

---

## 🧼 Security Arrays Must Be Non-Empty

✅ **Good**:
```yaml
security:
  - apiKey: []
```

❌ **Bad** — empty global security:
```yaml
security: []   # ❌
```

---

## 🧼 Do Not Override Global Security at Endpoint Level

Endpoints must not use `security: []` to bypass global security. If an endpoint does not require security, expose it in a different API.

❌ **Bad**:
```yaml
security:
  - apiKey: []
paths:
  /resources:
    get:
      security: []   # ❌ overrides global security
```

---

## 📝 Validation Prompt

> "Check if all security schemes in this spec follow best practices"
> "Verify that all string parameters and properties have maxLength defined"
> "Are there any arrays without maxItems or numbers without minimum/maximum?"
