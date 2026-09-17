# Go Hints

What to search for when documenting a **Go** backend.

---

## File Patterns

| What | Where to look |
|------|--------------|
| Entry point | `cmd/*/main.go`, `main.go` |
| Routes/handlers | `internal/handler/`, `internal/api/`, files with `http.HandleFunc` or router registration |
| Middleware | `internal/middleware/`, `func(next http.Handler)` pattern |
| Services | `internal/service/`, `internal/usecase/` |
| Repositories | `internal/repository/`, `internal/store/` |
| Models/entities | `internal/model/`, `internal/domain/`, `internal/entity/` |
| Config | `internal/config/`, `config.go`, `viper` usage |
| Migrations | `migrations/`, `db/migrations/`, `*.sql` files |
| DI wiring | `cmd/*/main.go` (manual), `fx.New()` (Uber Fx), `wire.Build()` (Wire) |

## Keywords to Search

- **Middleware:** `func.*http\.Handler`, `Use(`, `middleware`, `chi.Use`, `gin.Use`, `echo.Use`
- **DI:** `fx.Provide`, `fx.Invoke`, `wire.Build`, `wire.NewSet`, constructor functions
- **Concurrency:** `go func`, `chan`, `sync.Mutex`, `sync.WaitGroup`, `errgroup`, `context.WithCancel`
- **Data access:** `sql.DB`, `sqlx`, `pgx`, `gorm.Model`, `ent.Schema`
- **Config:** `viper.Get`, `envconfig.Process`, `os.Getenv`
- **Auth:** `jwt`, `middleware.Auth`, `token`, bearer handling
- **Errors:** `errors.New`, `fmt.Errorf`, `%w`, custom error types

## Language-Specific Patterns for `how-to/patterns.md`

- Accept interfaces, return structs
- Table-driven tests
- Context as first parameter
- Error handling: always check, always wrap with `%w`
- Package naming: short, lowercase, no underscores
- Interface segregation: define interfaces at point of use, not at implementation

## Framework Specifics

| Framework | Router registration | Middleware pattern |
|-----------|-------------------|-------------------|
| chi | `r.Route("/path", func(r chi.Router) { r.Get("/", handler) })` | `r.Use(middleware)` |
| gin | `r.GET("/path", handler)` | `r.Use(middleware)` |
| echo | `e.GET("/path", handler)` | `e.Use(middleware)` |
| net/http | `http.HandleFunc("/path", handler)` | Wrapper functions |
| fiber | `app.Get("/path", handler)` | `app.Use(middleware)` |
