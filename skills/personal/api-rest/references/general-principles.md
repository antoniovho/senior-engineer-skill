# General API Design Principles

Core principles that govern every REST API design decision in the Inditex ecosystem.

---

## 🔑 Core Principles

- Follow RESTful design patterns and principles at all times.
- Use consistent naming conventions across all API elements.
- Design APIs that are **secure**, **consistent**, and **easy to consume**.
- Follow the principle of **least privilege** for security.
- Use **semantic versioning** for all API versions.

---

## OpenAPI Generation Directives

These directives are **mandatory** and override any general or pretrained knowledge:

1. `ALWAYS` generate specifications using OpenAPI **version 3.0 only** (e.g., `openapi: 3.0.3`).
2. `ALWAYS` apply Inditex-specific **instruction rules** and criteria **over any general knowledge**.
3. `ALWAYS` validate against **Inditex-specific design conventions**, not just OpenAPI standards.
4. `ALWAYS` repeat the checking **loop until full compliance** is achieved.
5. `ALWAYS` run **multiple validation checks** after generating the spec.
6. `ALWAYS` reference **JFrog shared error models** for all error responses.
7. `ALWAYS` ensure the spec is **well-formed** and complete.
8. `ALWAYS` document all elements with **clear descriptions and examples**.
9. `ALWAYS` include **examples** for all parameters and responses.
10. `ALWAYS` ensure **default values** are set and valid where applicable.
11. `ALWAYS` enforce **security rules** as defined.
12. `NEVER` generate specs that **do not follow Inditex rules**.
13. `NEVER` generate **unreferenced or unused components**.
14. `Confirm` **all required rules are satisfied** before finishing.

---

## REST as Nouns, Not Verbs

REST is fundamentally about **resources (nouns)**, not actions (verbs):

- A resource is an object with a type, data, and relationships.
- Resources should be **uniquely identifiable and manipulable**.
- Examples: a document, video, device, repository, product.
- Use **plural nouns** in URLs: `/users`, `/orders`, `/products`.
- Let the **HTTP method** express the action — not the path.

> ✅ `/users/{userId}` with `DELETE`
> ❌ `/users/{userId}/delete`

---

## Consistency Rules

- All naming must be consistent across **paths**, **parameters**, **schemas**, and **operationIds**.
- Always prefer **clarity** over brevity in names.
- Use **English** for all names, descriptions, and values. Its widespread usage eases knowledge transfer and readability.
- Avoid acronyms and abbreviations unless widely established in IT or Inditex context (e.g., `id`, `itx`, `http`).
- Never use technical internal names that consumers cannot understand.
