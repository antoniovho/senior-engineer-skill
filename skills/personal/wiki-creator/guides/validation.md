# Validation Checklist

Single source of truth for wiki validation. Phase 6 (Full mode) and Phase 5 (Incremental mode) both run these checks.

---

## Checks

| # | Check | Auto-fix? | Notes |
|---|-------|-----------|-------|
| 1 | Every `.md` page has `title` + `description` YAML frontmatter | ✅ | Generate from page title and one-line summary |
| 2 | Every factual claim naming a file, function, value, or behavior is cited | ✅ | Add source comments/links. Citations follow claims, not quotas |
| 3 | All relative Markdown links point to existing files | ✅ | Run after all pages written |
| 4 | Sidebar in `config.mts` matches actual generated pages | ✅ | Add missing; remove dangling |
| 5 | No Mermaid diagram contains inline `%%{init}` theme blocks (theme is global via `config.mts`) | ✅ | Remove if found; global config handles theming |
| 6 | Every `sequenceDiagram` contains `autonumber` | ✅ | |
| 7 | Diátaxis boundary check: no "why" explanations in reference pages | Report only | Flag instances where reference pages contain rationale |
| 8 | Diátaxis boundary check: no step-by-step recipes in explanation pages | Report only | Flag instances where explanation pages contain how-to steps |
| 9 | No concept explained in multiple pages (anti-repetition) | Report only | Two pages with the same diagram or same detailed table is a violation |
| 10 | `index.md` does NOT contain domain ER, detailed request flow, or routes table | ✅ | Those belong in reference/ or explanation/ |
| 11 | `how-to/extend.md` has a Recipe Index table at the top | ✅ | |
| 12 | Every recipe in `how-to/extend.md` references real file paths | Report only | |

---

## On failure

- **Auto-fix checks** — fix in place, then re-verify.
- **Report-only checks** — list findings in the final summary; do not invent content to satisfy them.

---

## Manifest generation (Phase 6 — Full mode only)

Generate `.manifest.json` at the wiki root:

```json
{
  "generatedAt": "2026-05-05T12:00:00Z",
  "commitHash": "<current HEAD commit>",
  "branch": "<current branch name>",
  "version": "8.0",
  "archetype": "backend-api",
  "hint": "node",
  "pages": ["index.md", "explanation/architecture.md", "..."],
  "pageMetadata": {
    "explanation/architecture.md": { "origin": "core", "diataxis": "explanation" },
    "explanation/middleware-chain.md": { "origin": "backend-api", "diataxis": "explanation" },
    "reference/api.md": { "origin": "core", "diataxis": "reference" },
    "how-to/extend.md": { "origin": "core", "diataxis": "how-to" },
    "tutorial/setup.md": { "origin": "core", "diataxis": "tutorial" }
  },
  "sourceMap": {
    "index.md": ["src/main.ts", "package.json"],
    "explanation/architecture.md": ["src/main.ts", "src/routes/", "package.json"],
    "reference/domain-model.md": ["prisma/schema.prisma", "src/domain/"],
    "how-to/extend.md": ["src/routes/", "src/controllers/"]
  }
}
```

**Fields:**
- `archetype`: which archetype was detected (`"backend-api"`, `"frontend-spa"`, `"mobile"`)
- `hint`: which language hint was used (`"node"`, `"spring-boot"`, `"go"`, `"python"`, `"react"`, `"ios"`, `"android"`)
- `pageMetadata.origin`: `"core"` for universal pages, `"{archetype-name}"` for archetype-specific
- `pageMetadata.diataxis`: which quadrant the page belongs to
- `sourceMap`: files that, if changed, make this page stale

**Incremental mode:** update `sourceMap` for regenerated pages, refresh `generatedAt` and `commitHash`. Do not modify `pageMetadata.origin` or `diataxis` for existing pages.
