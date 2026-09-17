# Python Hints

What to search for when documenting a **Python** backend (FastAPI, Flask, Django).

---

## File Patterns

| What | Where to look |
|------|--------------|
| Entry point | `main.py`, `app.py`, `src/main.py`, `manage.py` (Django) |
| Routes/endpoints | `routers/`, `routes/`, `views/`, files with `@app.get`/`@router.post` |
| Middleware | `middleware/`, `app.add_middleware(`, `MIDDLEWARE` list (Django) |
| Services | `services/`, `usecases/`, `application/` |
| Repositories | `repositories/`, `infrastructure/`, `*_repository.py` |
| Models | `models/`, `schemas/`, `entities/`, files with `class.*BaseModel` |
| Config | `config.py`, `settings.py`, `core/config.py`, `.env` |
| DI | `dependencies.py`, `deps.py`, `Depends(` usage, `container.py` |
| Migrations | `alembic/versions/`, `migrations/` (Django) |

## Keywords to Search

- **Middleware:** `app.add_middleware`, `@app.middleware`, `BaseHTTPMiddleware`, `MIDDLEWARE`
- **DI:** `Depends(`, `dependency_overrides`, `yield`, `get_db`, `get_current_user`
- **Data access:** `Session`, `AsyncSession`, `Base.metadata`, `@declared_attr`, `Column(`, `relationship(`
- **Config:** `BaseSettings`, `@lru_cache`, `os.environ`, `dotenv`, `config()`
- **Auth:** `OAuth2PasswordBearer`, `HTTPBearer`, `get_current_user`, `jwt.decode`
- **Errors:** `HTTPException`, `raise`, custom exception handlers
- **Validation:** `BaseModel`, `Field(`, `validator`, `field_validator`
- **Async:** `async def`, `await`, `asyncio.gather`, `BackgroundTasks`

## Language-Specific Patterns for `how-to/patterns.md`

- Type hints everywhere (function signatures, variables)
- Pydantic models for API schemas (over dataclasses)
- `async def` for I/O-bound, `def` for CPU-bound or blocking libs
- Dependency injection via `Depends()` over global state
- Generator dependencies (`yield`) for resource cleanup
- Separation: schemas (API) vs. models (DB) vs. domain entities
- Path operations grouped in routers with prefixes

## Framework Specifics

| Framework | Route registration | Middleware pattern | DI pattern |
|-----------|-------------------|-------------------|------------|
| FastAPI | `@router.get("/path")` | `app.add_middleware(cls)` | `Depends(callable)` |
| Flask | `@app.route("/path")` | `@app.before_request` | Manual / Flask-Injector |
| Django | `urlpatterns = [path("/", view)]` | `MIDDLEWARE` list | Manual / django-injector |
| Litestar | `@get("/path")` | `Middleware` list | Built-in DI |
