# Frontend SPA Archetype

Documentation module for **Single Page Applications** — browser-based UI apps with client-side routing and state management.

---

## Pages Generated

### Explanation pages (go in `explanation/`)

| Page | Purpose |
|------|---------|
| `explanation/state-management.md` | All state layers, interactions, persistence, rationale |
| `explanation/data-layer.md` | API client architecture, fetching patterns, caching strategy |

### Reference pages (go in `reference/`)

| Page | Purpose |
|------|---------|
| `reference/ui-components.md` | Catalog of reusable UI components: props, location, usage guidance |

### How-to pages (go in `how-to/`)

| Page | Purpose |
|------|---------|
| `how-to/frontend-recipes.md` | Add page/route, add component, add data hook, add state |

---

## Writing Guides

### `explanation/state-management.md`

**Diátaxis type:** Explanation. Answers: "How does state work in this app and why?"

**Sections (importance order):**

1. **"State Layers" diagram** — Mermaid `graph TD` with subgraphs per layer:
   - Server cache (data fetching library)
   - Global client state (store/context)
   - URL state (query params, route params)
   - Local component state
   - Persisted state (localStorage, sessionStorage)

2. **"State Layers" table** — (layer | technology | persistence | scope | use cases | source)

3. **"Why This Approach"** — Decision table:
   | Alternative | Rejected Because | Evidence |

4. **"Data Flow" sequence diagram** — How state changes propagate: user action → dispatch/mutation → state update → re-render.

5. **"Persistence Strategy"** — (state item | storage | serialization | hydration trigger | source)

6. **"Constraints & Gotchas"** — 3-5 non-obvious things that break if done wrong.

---

### `explanation/data-layer.md`

**Diátaxis type:** Explanation. Answers: "How does this app talk to backends and manage server data?"

**Sections:**

1. **"At a Glance" table** — (concern | technology | source)

2. **"API Client Architecture" diagram** — Mermaid showing the interceptor/middleware chain (auth injection, retry, error mapping).

3. **"Data Fetching Lifecycle" sequence diagram** — Component → Hook → Client → Backend → Cache → Render.

4. **"Data Hooks/Services" table** — (hook/service | endpoint | cache key | returns | source)

5. **"Mutation Patterns"** — How writes work: optimistic updates, invalidation strategy, error rollback.

6. **"Caching Strategy"** — Cache timing, refetch policies, prefetching.

7. **"Why This Architecture"** — Rationale for client design choices.

---

### `reference/ui-components.md`

**Diátaxis type:** Reference. Catalog of all reusable UI components.

**Sections:**

1. **"Page Composition Pattern" diagram** — How pages assemble from layout → page → sections → components.

2. **"Shared Components" table** — (component | purpose | key props | location | source). Order by usage frequency.

3. **"Domain Components" table** — Feature-specific reusable components.

4. **"Styling Pattern"** — Brief reference to design tokens, CSS approach. Link to `how-to/patterns.md`.

5. **"Component Decision Tree"** — When to use which component.

**Rules:**
- NO "how to create a component" — link to `how-to/frontend-recipes.md`.
- NO "why we chose this pattern" — link to explanation.
- Every row must have a Source column.

---

### `how-to/frontend-recipes.md`

**Diátaxis type:** How-to. Goal-oriented recipes.

**Recipe Index:**

| I want to… | Recipe |
|---|---|
| Add a new page/route | [Add Route](#add-route) |
| Add a new shared component | [Add Component](#add-component) |
| Add a new data-fetching hook | [Add Hook](#add-hook) |
| Add global state | [Add State](#add-state) |
| Add a form | [Add Form](#add-form) |

**Per recipe:** Prerequisites + numbered steps + exact file paths + test step.

---

## Injections into Universal Pages

### In `explanation/architecture.md`:
- **Component Hierarchy** diagram — App → Providers → Layout → Pages → Views → Components
- **Provider/Context Stack** — Ordered initialization of context/providers + why this order

### In `reference/configuration.md`:
- **Build Config** — Environment variables, feature flags, API base URLs
- **Runtime Config** — How config differs per environment

### In `how-to/patterns.md`:
- **Frontend Patterns section** (framework-specific patterns come from hints):
  - Component structure (props interface, exports)
  - Hook naming and dependency management
  - Styling conventions
  - Each with ✅ / ❌ examples from the actual codebase

### In `how-to/extend.md`:
- Add route, add component, add hook recipes (framework-specific)

---

## Hints

After loading this archetype, also load the appropriate `hints/{framework}.md` file based on detection.
