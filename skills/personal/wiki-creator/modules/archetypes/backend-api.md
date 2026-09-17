# Backend API Archetype

Documentation module for **backend API services** — any HTTP server exposing endpoints, regardless of language or framework.

---

## Pages Generated

### Explanation pages (go in `explanation/`)

| Page | Purpose |
|------|---------|
| `explanation/middleware-chain.md` | HTTP middleware/filter pipeline, request context, error propagation |
| `explanation/dependency-injection.md` | DI container or wiring approach, registration, lifecycle, layer boundaries |
| `explanation/persistence-layer.md` | ORM/data-access patterns, transactions, migrations, query strategies |
| `explanation/security.md` | Auth mechanism, authorization rules, filter/middleware chain, CORS |

### How-to pages (go in `how-to/`)

| Page | Purpose |
|------|---------|
| `how-to/backend-recipes.md` | Add endpoint, add service/use case, add entity/model, add migration, add integration |

---

## Writing Guides

### `explanation/middleware-chain.md`

**Diátaxis type:** Explanation. Answers: "How does the HTTP pipeline work and why this order?"

**Sections:**

1. **"Middleware Pipeline" sequence diagram** — Full request path through all middleware/filters in order: Request → [each middleware] → Handler → Response (include error paths).

2. **"Middleware Inventory" table** — (middleware/filter | purpose | order | applies to | config | source)

3. **"Request Context Enrichment" table** — (middleware | context key/attribute | value type | consumed by)

4. **"Router Configuration"** — Router approach, route grouping, prefix strategy, middleware-per-route vs. global.

5. **"Error Propagation"** — How errors bubble: centralized handler, middleware chain, HTTP status mapping.

6. **"Why This Order"** — Rationale for middleware ordering. What breaks if reordered.

---

### `explanation/dependency-injection.md`

**Diátaxis type:** Explanation. Answers: "How are dependencies wired and why?"

**Sections:**

1. **"Container/Wiring Overview" diagram** — Mermaid `graph TD` showing how components are registered and resolved. Layer boundaries visible (controllers → services/use cases → repositories → infrastructure).

2. **"Registration Strategy" table** — (component | lifetime (singleton/transient/scoped/request) | registration method | source)

3. **"Dependency Graph" diagram** — Mermaid `graph LR` showing key dependency chains.

4. **"Injection Mode"** — How injection works in this stack (constructor, annotation, decorator, Depends). Why this approach.

5. **"Lifecycle & Initialization"** — Bootstrap sequence: container/app creation → registration → resolution/startup → ready. Graceful shutdown and resource cleanup.

6. **"Why This Structure"** — Rationale for DI approach, trade-offs vs alternatives.

---

### `explanation/persistence-layer.md`

**Diátaxis type:** Explanation. Answers: "How does data persistence work and why these patterns?"

**Sections:**

1. **"Domain Model"** — Link to [`reference/domain-model.md`](../reference/domain-model.md) for the full ER diagram. Do NOT duplicate the ER here. Instead, add an **"ORM/Mapping Details" table** with persistence-specific info not in reference:
   | Entity | Fetch Strategy | Cascade | Indexes | Cache | Source |

2. **"Repository/Query Patterns"** — Which data access strategies are used and why (ORM queries, raw SQL, query builders, specifications, etc.).

3. **"Transaction Management"** — Where transactions are declared, propagation/isolation strategies, read-only optimizations. WHY transactions are at this layer.

4. **"Migration Strategy"** — Migration tool, naming conventions, rollback approach, CI integration.

5. **"Performance Patterns"** — N+1 prevention, batch operations, pagination, caching. Why these choices.

---

### `explanation/security.md`

**Diátaxis type:** Explanation. Answers: "How does security work and what can't be bypassed?"

**Sections:**

1. **"Security Pipeline" sequence diagram** — Request → Auth extraction → Validation → Authorization → Handler → Response (include 401/403 paths).

2. **"Authentication Mechanisms" table** — (mechanism | endpoints | token type | validation | source)

3. **"Authorization Rules" table** — (endpoint/resource pattern | required role/permission | method | source)

4. **"Why This Model"** — Rationale for auth approach, security boundaries, what it doesn't protect against.

5. **"CORS Configuration"** — (origins | methods | headers | credentials | source)

---

### `how-to/backend-recipes.md`

**Diátaxis type:** How-to. Goal-oriented recipes.

**Recipe Index:**

| I want to… | Recipe |
|---|---|
| Add a new API endpoint | [Add Endpoint](#add-endpoint) |
| Add a new service/use case | [Add Service](#add-service) |
| Add a new domain entity/model | [Add Entity](#add-entity) |
| Add a database migration | [Add Migration](#add-migration) |
| Add a new middleware/filter | [Add Middleware](#add-middleware) |
| Add an external integration | [Add Integration](#add-integration) |
| Add a secured endpoint | [Add Secured Endpoint](#add-secured-endpoint) |

**Per recipe:** Prerequisites + numbered steps + exact file paths + registration/wiring step + test step.

---

## Injections into Universal Pages

### In `explanation/architecture.md`:
- **Layer Architecture Diagram** — Controllers/Handlers → Services/Use Cases → Repositories → Infrastructure
- **Layer Boundary Rules** table — (layer | responsibility | allowed dependencies | source)
- **Bootstrap Sequence** — How the app starts and becomes ready to serve

### In `reference/domain-model.md`:
- **ORM/Schema Mapping** — Framework-specific entity annotations/schema mapped to domain model
- **Migrations table** — (migration | purpose | date | source)

### In `reference/configuration.md`:
- **Config Loading Mechanism** — How config is loaded and merged
- **Config Schema/Type** — Full config structure documented
- **Secrets Handling** — How secrets are separated from regular config

### In `how-to/patterns.md`:
- **Backend Patterns section** (language-specific patterns come from hints):
  - Interface/contract-first design
  - Repository pattern
  - Error hierarchy and centralized handling
  - Each with ✅ / ❌ examples from the actual codebase

### In `how-to/extend.md`:
- Archetype-specific recipes for add endpoint, add entity, add integration

---

## Hints

After loading this archetype, also load the appropriate `hints/{language}.md` file based on detection. The hints provide:
- **What to search for** — file patterns, keywords, annotations/decorators
- **Language-specific patterns** — idiomatic code conventions for `how-to/patterns.md`
- **Framework specifics** — where things live, naming conventions, CLI commands
