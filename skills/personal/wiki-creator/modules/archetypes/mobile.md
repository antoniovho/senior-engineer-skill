# Mobile Archetype

Documentation module for **mobile applications** — native iOS and Android apps with navigation, UI patterns, and platform-specific lifecycle.

---

## Pages Generated

### Explanation pages (go in `explanation/`)

| Page | Purpose |
|------|---------|
| `explanation/navigation.md` | Navigation graph, deep links, conditional flows, screen inventory |
| `explanation/ui-architecture.md` | UI pattern (MVVM/MVI/TCA), state binding, view composition, design system |

### How-to pages (go in `how-to/`)

| Page | Purpose |
|------|---------|
| `how-to/mobile-recipes.md` | Add screen, add module, add persisted entity, add deep link, add dependency |

---

## Writing Guides

### `explanation/navigation.md`

**Diátaxis type:** Explanation. Answers: "How does navigation work and why this approach?"

**Sections:**

1. **"Navigation Graph" diagram** — Mermaid `graph TD`:
   - Subgraphs for each navigation section (main, auth, onboarding, settings, tabs)
   - Conditional paths (auth gate, feature flags)
   - Deep-link entry points marked

2. **"Screen Inventory" table** — (screen | module/graph | navigation type | deep link | auth required | source)

3. **"Navigation Pattern"** — Which approach is used and WHY:
   - Coordinator, NavigationStack, NavHost, Router abstraction, etc.
   - Trade-offs vs. alternatives.

4. **"Deep Linking"** — (scheme/path | destination | parameters | source). Configuration mechanism and fallback behavior.

5. **"Type-Safe Arguments"** — How navigation arguments are passed between screens.

6. **"Conditional Navigation"** — Auth gate, onboarding, feature flags. How each works and why.

---

### `explanation/ui-architecture.md`

**Diátaxis type:** Explanation. Answers: "How is the UI structured and why?"

**Sections:**

1. **"UI Architecture Pattern" diagram** — Data flow for chosen pattern:
   - MVVM: View ← ViewModel ← Service/Repository
   - MVI: View → Intent → Reducer → State → View
   - TCA: View ← Store ← Reducer

2. **"View Composition" diagram** — Container → Section → Component hierarchy.

3. **"State Binding Patterns"** — How UI state flows from business logic to view. Platform-specific mechanisms and when each is used.

4. **"Design System"** — Typography, color tokens, spacing, component library. How the design system is structured.

5. **"Declarative vs. Imperative"** (if mixed) — Which screens use which approach, bridging patterns, migration strategy.

6. **"Why This Architecture"** — Rationale for UI pattern choice, trade-offs accepted.

---

### `how-to/mobile-recipes.md`

**Diátaxis type:** How-to. Goal-oriented recipes.

**Recipe Index:**

| I want to… | Recipe |
|---|---|
| Add a new screen | [Add Screen](#add-screen) |
| Add a new feature module | [Add Module](#add-module) |
| Add a persisted entity | [Add Entity](#add-entity) |
| Add a deep link | [Add Deep Link](#add-deep-link) |
| Add a new dependency | [Add Dependency](#add-dependency) |
| Add a background task/worker | [Add Worker](#add-worker) |

**Per recipe:** Prerequisites + numbered steps + exact file paths + test step.

---

## Injections into Universal Pages

### In `explanation/architecture.md`:
- **App Lifecycle Diagram** — Launch → Foreground → Background → Terminate
- **Module/Package Structure** — Dependency graph between modules
- **Architecture Layers** — Presentation → Domain → Data with dependency rules

### In `explanation/decisions.md`:
- **Modularization Strategy** — Why modularized this way, build time impact, team ownership
- **Concurrency Architecture** — Threading/coroutine/async strategy and boundaries

### In `reference/domain-model.md`:
- **Local Persistence Model** — Entity diagram with ORM annotations, type converters
- **Local Storage** — Key-value storage keys table (if applicable)

### In `reference/configuration.md`:
- **Build Variants/Configurations** — (variant | purpose | signing | config | source)
- **Feature Flags** — Remote config mechanism, defaults
- **Platform Config** — Manifest/Info.plist keys, URL schemes, capabilities

### In `how-to/patterns.md`:
- **Mobile Patterns section** (platform-specific patterns come from hints):
  - UI state management pattern
  - Concurrency patterns
  - Dependency injection approach
  - Each with ✅ / ❌ examples from the actual codebase

### In `how-to/extend.md`:
- Add screen, add module, add entity, add worker recipes (platform-specific)

---

## Hints

After loading this archetype, also load the appropriate `hints/{platform}.md` file based on detection.
