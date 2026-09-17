# OpenAPI Schema Property Naming Rules

Rules for property naming conventions, enum formatting, schema structure, and type-specific constraints.

---

## 🐫 Properties Must Be camelCase

All schema properties must use camelCase.

✅ **Good**:
```yaml
type: object
properties:
  userName:
    type: string
```

❌ **Bad**:
```yaml
type: object
properties:
  user_name:   # ❌ snake_case
    type: string
```

---

## UPPER_SNAKE_CASE Enum Values

All enum and `x-extensible-enum` values **must** be `UPPER_SNAKE_CASE`.

Normalization rules:
- Replace spaces and hyphens with `_`.
- Remove accents (e.g., `visión` → `VISION`).
- Mixed/numeric values: uppercase letters only (`3d` → `3D`, `v2` → `V2`).
- Keep punctuation only if integral and widely standardized; otherwise remove.

### Choosing `enum` vs `x-extensible-enum`

**Use `enum` (closed set) when ALL are true:**
- Set is defined by a stable standard (e.g., ISO codes, PCI constants).
- Product/business has committed no new values without a version bump.
- Clients can safely hard-code exhaustive handling.

**Use `x-extensible-enum` (variable set) if ANY are true:**
- New values may appear without a version bump.
- The list is "open-ended examples" rather than a definitive catalog.
- Values depend on external catalogs (DB rows, CMS config).
- Values may be region/tenant specific.
- Spec text says "such as…", "e.g.", "includes but not limited to".

> **When in doubt, assume closed and use `enum`.**

✅ **Good — closed set**:
```yaml
type: string
enum: [ACTIVE, INACTIVE, PENDING]
```

❌ **Bad — lowercase enum**:
```yaml
type: string
enum: [active, inactive, pending]   # ❌
```

✅ **Good — variable set**:
```yaml
type: string
x-extensible-enum: [NEW, IN_PROGRESS, COMPLETED]
```

❌ **Bad — lowercase x-extensible-enum**:
```yaml
type: string
x-extensible-enum: [new, in_progress, completed]   # ❌
```

---

## 🚫 No DTO Suffix in Schema Names

Never use `dto`, `DTO`, or `Dto` as part of schema names.

✅ **Good**:
```yaml
components:
  schemas:
    UserProfile:
      type: object
```

❌ **Bad**:
```yaml
components:
  schemas:
    UserDTO:     # ❌
      type: object
```

---

## 📄 Request Body Must Define a Schema

Every request body content type must specify a valid `schema`.

✅ **Good**:
```yaml
requestBody:
  content:
    application/json:
      schema:
        $ref: '#/components/schemas/UserInput'
```

❌ **Bad**:
```yaml
requestBody:
  content:
    application/json:
      # ❌ missing schema
```

---

## 🧪 Boolean Parameters Should Use `is` Prefix

✅ **Good**:
```yaml
parameters:
  - name: isActive
    in: query
    schema:
      type: boolean
```

❌ **Bad**:
```yaml
parameters:
  - name: active   # ❌ lacks is- prefix
    in: query
    schema:
      type: boolean
```

---

## 🧬 Boolean Properties Must Use `is` Prefix

✅ **Good**:
```yaml
type: object
properties:
  isEnabled:
    type: boolean
```

❌ **Bad**:
```yaml
type: object
properties:
  enabled:   # ❌ should be isEnabled
    type: boolean
```

---

## 📅 Date Properties Must End with `Date`

Properties of `format: date` must end with `Date`.

✅ **Good**:
```yaml
birthDate:
  type: string
  format: date
```

❌ **Bad**:
```yaml
birth:        # ❌ must end with Date
  type: string
  format: date
```

---

## 🕒 Datetime Properties Must End with `Date` or `DateTime`

Properties of `format: date-time` must end with `Date` or `DateTime`.

✅ **Good**:
```yaml
updatedDateTime:
  type: string
  format: date-time
```

❌ **Bad**:
```yaml
updated:         # ❌ lacks suffix
  type: string
  format: date-time
```

---

## ⚠️ Exception: HATEOAS `rel` Enum Values Are Lowercase

The UPPERCASE enum rule has **one explicit exception**: HATEOAS pagination link `rel` values must be **lowercase** per [RFC 5988](https://datatracker.ietf.org/doc/html/rfc5988).

✅ **Correct — lowercase `rel` values**:
```yaml
rel:
  type: string
  enum: [self, prev, next, first]
  example: "self"
```

❌ **Wrong — do NOT uppercase rel values**:
```yaml
rel:
  type: string
  enum: [SELF, PREV, NEXT, FIRST]   # ❌ rel values must be lowercase
```

This is the **only** exception to the UPPERCASE enum rule.

---

## 📝 Human-Readable Names

- Property names must be human words, not technical jargon.
- Avoid acronyms and abbreviations unless widely established:
  - Accepted: `id`, `itx`, `http`, `en`, `en-us`
  - Avoid: opaque abbreviations consumers won't understand
- Use **English** for all names.

---

## 📝 Validation Prompts

> "Check if schema properties follow camelCase and date-time suffix conventions"
> "Are all enum values UPPERCASE?"
> "Are there any DTO suffixes in schema names?"
