# OpenAPI Example Definition Rules

Rules for enforcing the presence of meaningful, non-null, non-empty `example` values on all parameters and schema properties.

---

## Core Rules

- `ALWAYS` enforce the presence of `example` values on parameters and schema properties.
- `ALWAYS` generate **realistic and valid** example values.
- `ALWAYS` validate all examples against their schemas.
- `ALWAYS` ensure examples are **not empty strings** and **not null** (unless nullable is true and null is intentional).

---

## 🔣 Path Parameters Must Have Examples

Every parameter defined within a path must include an `example`.

✅ **Good**:
```yaml
parameters:
  - name: userId
    in: path
    required: true
    schema:
      type: string
      example: "abc123"
```

❌ **Bad** — missing example:
```yaml
parameters:
  - name: userId
    in: path
    required: true
    schema:
      type: string
      # ❌ missing example
```

❌ **Bad** — null example:
```yaml
parameters:
  - name: userId
    in: path
    required: true
    schema:
      type: string
      example: null   # ❌ not allowed
```

❌ **Bad** — empty example:
```yaml
parameters:
  - name: userId
    in: path
    required: true
    schema:
      type: string
      example: ""     # ❌ not allowed
```

---

## 🔣 Component Parameters Must Have Examples

All parameters under `components.parameters` must also include a valid `example`.

✅ **Good**:
```yaml
components:
  parameters:
    storeId:
      name: storeId
      in: path
      required: true
      schema:
        type: string
        example: "10701"
```

❌ **Bad** — null or missing:
```yaml
components:
  parameters:
    storeId:
      name: storeId
      in: path
      required: true
      schema:
        type: string
        example: null   # ❌ not allowed
```

---

## 🧬 Schema Properties Must Include Examples

Each schema property (except complex types like `object` and `array`) must have an `example`.

✅ **Good**:
```yaml
type: object
properties:
  name:
    type: string
    example: "Zara"
  age:
    type: integer
    example: 30
```

❌ **Bad**:
```yaml
type: object
properties:
  name:
    type: string
    # ❌ missing example
  age:
    type: integer
    # ❌ missing example
```

---

## 📝 Why Examples Matter

Providing examples:
- Enables **mock server generation** automatically.
- Improves **documentation rendering** in Swagger UI.
- Helps **API consumers** understand expected values immediately.
- Enables **contract testing** tools to validate responses.

---

## 📝 Validation Prompt

> "Scan the spec for any missing examples in parameters or properties"
