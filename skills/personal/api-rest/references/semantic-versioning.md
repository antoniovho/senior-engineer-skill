# OpenAPI Versioning Rules

Rules for applying semantic versioning consistently in OpenAPI specifications.

---

## 🔢 Semantic Versioning Required

All OpenAPI specs **MUST** use [Semantic Versioning](https://semver.org) in the `info.version` field.

- Format: `MAJOR.MINOR.PATCH` (e.g., `1.0.0`, `2.3.1`).
- Must start from `1.0.0` as the initial version.
- Must match the `api.version` field in `metadata.yml` exactly.

✅ **Good**:
```yaml
info:
  version: "2.1.0"
```

❌ **Bad** — not semantic:
```yaml
info:
  version: "v1"
```

❌ **Bad** — incomplete semver:
```yaml
info:
  version: "1.0"
```

---

## 🧪 Understanding Semantic Version Increments

| Change Type | Field to Increment | Example |
|---|---|---|
| Breaking changes | **MAJOR** | `1.0.0` → `2.0.0` |
| New features, backward-compatible | **MINOR** | `1.0.0` → `1.1.0` |
| Bug fixes | **PATCH** | `1.0.0` → `1.0.1` |

---

## 🔗 Version Consistency

The `info.version` value **must be identical** to the `api.version` in `metadata.yml`:

```yaml
# openapi-rest.yml
info:
  version: "1.2.0"

# metadata.yml
api:
  version: "1.2.0"   # ✅ must match
```

---

## 📝 Validation Prompt

> "Check that all OpenAPI specs use semantic versioning in `info.version` and that it matches `metadata.yml`"
