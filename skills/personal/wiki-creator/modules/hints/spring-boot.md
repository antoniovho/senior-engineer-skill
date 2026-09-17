# Spring Boot Hints

What to search for when documenting a **Spring Boot (Java/Kotlin)** backend.

---

## File Patterns

| What | Where to look |
|------|--------------|
| Entry point | `*Application.java/kt` with `@SpringBootApplication` |
| Controllers | `*Controller.java/kt`, classes with `@RestController` or `@Controller` |
| Services | `*Service.java/kt`, classes with `@Service` |
| Repositories | `*Repository.java/kt`, interfaces extending `JpaRepository`/`CrudRepository` |
| Entities | `*Entity.java/kt`, classes with `@Entity` |
| Config | `application*.yml`, `*Config.java/kt`, `@Configuration` classes |
| Security | `*SecurityConfig*`, `SecurityFilterChain`, `@EnableWebSecurity` |
| Migrations | `db/migration/`, `V*__*.sql` (Flyway), `changelog*.xml` (Liquibase) |
| DTOs | `*Dto.java/kt`, `*Request.java/kt`, `*Response.java/kt` |
| Mappers | `*Mapper.java/kt` (MapStruct), manual mapping methods |

## Keywords to Search

- **DI:** `@Autowired`, `@Component`, `@Service`, `@Repository`, `@Configuration`, `@Bean`, `@ConditionalOn*`
- **Persistence:** `@Entity`, `@Table`, `@Column`, `@OneToMany`, `@ManyToOne`, `@Transactional`, `@Query`
- **Security:** `SecurityFilterChain`, `@PreAuthorize`, `@Secured`, `hasRole`, `httpSecurity`
- **Config:** `@Value`, `@ConfigurationProperties`, `@Profile`, `application.yml`
- **Middleware/Filters:** `OncePerRequestFilter`, `HandlerInterceptor`, `@ControllerAdvice`
- **Validation:** `@Valid`, `@NotNull`, `@Size`, `ConstraintValidator`
- **Async:** `@Async`, `@Scheduled`, `CompletableFuture`

## Language-Specific Patterns for `how-to/patterns.md`

- Constructor injection (never field injection)
- `@ControllerAdvice` for centralized error handling
- `@ConfigurationProperties` over `@Value` for grouped config
- Profiles for environment separation
- Interface for each service/repository (testability)
- Records/data classes for DTOs
- Builder pattern for complex objects

## Framework Specifics

| Concern | Pattern | File location |
|---------|---------|--------------|
| Route definition | `@GetMapping`, `@PostMapping` on controller methods | `*Controller.java/kt` |
| Middleware | `OncePerRequestFilter`, `HandlerInterceptor` | `*Filter.java/kt`, `*Interceptor.java/kt` |
| Error handling | `@ControllerAdvice` + `@ExceptionHandler` | `*ExceptionHandler.java/kt` |
| Config binding | `@ConfigurationProperties(prefix = "...")` | `*Properties.java/kt` |
| Bean lifecycle | `@PostConstruct`, `@PreDestroy`, `InitializingBean` | Any `@Component` |
