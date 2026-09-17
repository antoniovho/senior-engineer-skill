# OpenAPI Tags Usage Rules

Rules for defining and using tags in OpenAPI specifications to ensure proper grouping and documentation.

---

## 🏷️ Global `tags` Must Be Defined at Root Level

The root OpenAPI document **must** declare a `tags` array describing the available operation groups.

✅ **Good**:
```yaml
tags:
  - name: Users
    description: Operations related to user management
  - name: Orders
    description: Manage customer orders
```

❌ **Bad** — missing global tags:
```yaml
# No tags array defined at root level
```

---

## 🔖 Every Operation Must Include a Non-Empty `tags` Array

All operations **must** be tagged with at least one tag from the global `tags` definition.

✅ **Good**:
```yaml
paths:
  /users:
    get:
      tags: [Users]
      summary: Retrieve user list
```

❌ **Bad** — empty array:
```yaml
paths:
  /users:
    get:
      tags: []          # ❌ empty array not allowed
```

❌ **Bad** — missing tags entirely:
```yaml
paths:
  /users:
    get:
      summary: Retrieve user list   # ❌ no tags field
```

---

## 🔤 Tag Names Must Be PascalCase

✅ **Good**:
```yaml
tags:
  - name: Users
  - name: OrdersManagement
```

❌ **Bad**:
```yaml
tags:
  - name: users             # ❌ lowercase
  - name: orders_management # ❌ snake_case
  - name: users-management  # ❌ kebab-case
```

---

## 📌 Operation Tags Must Match Global Definitions

Every tag used in an operation must have a corresponding entry in the root `tags` array.

✅ **Good**:
```yaml
# root
tags:
  - name: Products
    description: Product catalog operations

# operation
paths:
  /products:
    get:
      tags: [Products]
```

❌ **Bad** — tag used but not declared globally:
```yaml
# root
tags:
  - name: Orders

# operation
paths:
  /products:
    get:
      tags: [Products]   # ❌ 'Products' not in global tags
```

---

## 📝 How Many Tags Should an API Have?

| Count | Guidance |
|---|---|
| < 5 | Too broad — most operations end up in a few groups. Aim for more unless the API is very small. |
| **5 – 10** | ✅ Recommended range for most APIs. |
| 12 – 15 | Acceptable for very large, multi-domain APIs that cannot be split. |
| > 15 | ❌ Strong signal the API should be split into multiple specifications. |

> **Rule**: Never exceed 15 tags per specification.

---

## 📝 Validation Prompt

> "Validate that all operations are tagged and tags are declared globally"
