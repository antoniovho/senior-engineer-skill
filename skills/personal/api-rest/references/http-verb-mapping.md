# RESTful Action to HTTP Verb Mapping Rules

Rules for mapping actions to the correct HTTP methods. Actions must be expressed via HTTP verbs applied to resource-based paths — never embedded in the URL.

---

## Core Rule

**MUST** map all actions to standard HTTP methods. Avoid encoding actions in the URL (e.g., `/cancel`, `/execute`, `/create`). Resources drive API design — HTTP verbs express the action.

| Intent | HTTP Method |
|---|---|
| Create a new resource | `POST` |
| Read / List / Find | `GET` |
| Create or update (upsert) | `PUT` |
| Partial update | `PATCH` |
| Delete | `DELETE` |

---

## 🆕 Create → `POST`

✅ **Good**:
```yaml
paths:
  /users:
    post:
      summary: Create a new user
```

❌ **Bad** — action in path:
```yaml
paths:
  /users/create:
    post:
```

---

## 📖 Read / List / Find → `GET`

✅ **Good**:
```yaml
paths:
  /orders:
    get:
      summary: Get list of orders
```

❌ **Bad** — action keyword in path:
```yaml
paths:
  /orders/find:
    get:
```

---

## 🔄 Create or Update (Upsert) → `PUT`

✅ **Good**:
```yaml
paths:
  /users/{userId}:
    put:
      summary: Create or update user profile
```

❌ **Bad** — action in path:
```yaml
paths:
  /users/{userId}/createOrUpdate:
    put:
```

---

## ✏️ Partial Update → `PATCH`

✅ **Good**:
```yaml
paths:
  /products/{productId}:
    patch:
      summary: Update partial product info
```

❌ **Bad** — action embedded in path:
```yaml
paths:
  /products/updatePartial:
    patch:
```

---

## ❌ Delete → `DELETE`

✅ **Good**:
```yaml
paths:
  /carts/{cartId}:
    delete:
      summary: Remove cart
```

❌ **Bad** — verb in path + wrong method:
```yaml
paths:
  /carts/{cartId}/remove:
    post:
```

---

## 📝 Design Tip

REST is about **nouns** (resources), not **verbs** (actions). Let the HTTP method do the work.

> "Scan my paths for embedded actions and suggest refactors using standard HTTP verbs"
