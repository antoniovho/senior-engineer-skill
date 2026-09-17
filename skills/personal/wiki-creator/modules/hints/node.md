# Node.js Hints

What to search for when documenting a **Node.js/TypeScript** backend.

---

## File Patterns

| What | Where to look |
|------|--------------|
| Entry point | `src/main.ts`, `src/index.ts`, `index.js`, `server.ts` |
| Routes | `src/routes/`, `src/controllers/`, files with `router.get`/`router.post` |
| Middleware | `src/middleware/`, `app.use(` calls |
| Services/Use cases | `src/service/`, `src/application/`, `src/usecase/` |
| Repositories | `src/repository/`, `src/infrastructure/`, `*Repository.ts` |
| Models/entities | `src/domain/`, `src/model/`, `src/entity/`, `prisma/schema.prisma` |
| Config | `src/config/`, `config/application*.yml`, `src/utils/config.ts` |
| DI container | `src/container.ts`, `src/ioc.ts`, files with `createContainer`/`asClass` |
| Migrations | `prisma/migrations/`, `migrations/`, `db/migrations/` |

## Keywords to Search

- **Middleware:** `app.use(`, `router.use(`, `middleware`, `koaBody`, `cors()`, `helmet()`
- **DI:** `createContainer`, `asClass`, `asValue`, `asFunction`, `InjectionMode`, `container.resolve`
- **Data access:** `prisma.`, `@prisma/client`, `TypeORM`, `Sequelize`, `Knex`, `pg.Pool`
- **Config:** `fwkconfig`, `dotenv`, `config.get`, `env.`, `process.env`
- **Auth:** `jwt`, `passport`, `bearer`, `ctx.state.user`, `req.user`
- **Errors:** `extends Error`, `extends AmigaError`, custom error classes
- **Validation:** `zod`, `joi`, `class-validator`, `yup`

## Language-Specific Patterns for `how-to/patterns.md`

- Interface-first design (domain interfaces, infrastructure implementations)
- Repository pattern (abstract data access behind interface)
- Error class hierarchy (extend base error with status codes)
- Async/await everywhere (no callbacks, no uncaught promises)
- Constructor injection (Awilix CLASSIC relies on parameter names)
- Config typing (TypeScript types for all config shapes)
- Path aliases (`@/` or `#/` for clean imports)

## Framework Specifics

| Framework | Route registration | Middleware pattern |
|-----------|-------------------|-------------------|
| Koa | `router.get('/path', handler)` | `app.use(middleware)` |
| Express | `app.get('/path', handler)` | `app.use(middleware)` |
| Fastify | `fastify.get('/path', handler)` | `fastify.register(plugin)` |
| Hono | `app.get('/path', handler)` | `app.use(middleware)` |
| Amiga Node | `router().prefix('/path').get('/', handler)` | framework middleware |
