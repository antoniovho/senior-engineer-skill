# Android Hints

What to search for when documenting an **Android (Kotlin)** mobile app.

---

## File Patterns

| What | Where to look |
|------|--------------|
| Entry point | `*Application.kt`, `MainActivity.kt` |
| Navigation | `*NavGraph.kt`, `NavHost(`, `*Navigation.kt`, `nav_graph.xml` |
| Screens | `*Screen.kt` (Compose), `*Fragment.kt`, `*Activity.kt` |
| ViewModels | `*ViewModel.kt`, classes extending `ViewModel()` |
| Models | `*Entity.kt`, `*Model.kt`, files in `domain/model/` |
| Repositories | `*Repository.kt`, `*RepositoryImpl.kt` |
| Services/UseCases | `*UseCase.kt`, `*Interactor.kt` |
| Config | `AndroidManifest.xml`, `build.gradle.kts`, `gradle.properties` |
| DI | `*Module.kt` with `@Module`, `@Provides`, `@Inject`, `@HiltViewModel` |
| Persistence | `*Database.kt`, `*Dao.kt`, `*Entity.kt` (Room), `*DataStore.kt` |
| Network | `*Api.kt`, `*Service.kt` (Retrofit interfaces) |

## Keywords to Search

- **Navigation:** `NavHost`, `composable(`, `navigate(`, `NavController`, `NavGraphBuilder`, `deepLink`, `navArgument`
- **State:** `StateFlow`, `MutableStateFlow`, `collectAsState`, `mutableStateOf`, `remember`, `rememberSaveable`
- **Concurrency:** `viewModelScope`, `lifecycleScope`, `withContext(Dispatchers.`, `flow {`, `suspend fun`
- **DI:** `@HiltViewModel`, `@Inject`, `@Module`, `@Provides`, `@Singleton`, `@InstallIn`
- **Data:** `@Entity`, `@Dao`, `@Database`, `@Query`, `DataStore`, `Room`
- **Network:** `@GET`, `@POST`, `@Body`, `@Path`, `@Query` (Retrofit), `HttpClient` (Ktor)
- **UI:** `@Composable`, `Modifier`, `LazyColumn`, `Scaffold`, `Material3`

## Language-Specific Patterns for `how-to/patterns.md`

- Coroutines: structured concurrency, `CoroutineScope` per lifecycle
- Flow: cold flows for data streams, `StateFlow` for UI state, `SharedFlow` for events
- Compose: stateless composables, state hoisting, stability annotations
- Hilt: constructor injection always, never field injection in new code
- Sealed classes for UI state (`Loading`, `Success`, `Error`)
- Extension functions for utility (avoid inheritance for behavior)
- Kotlin idioms: `let`/`run`/`apply` for scoping, data classes for models

## Platform Specifics

| UI Framework | View pattern | State mechanism |
|-------------|-------------|-----------------|
| Jetpack Compose | `@Composable fun *Screen(viewModel: *ViewModel)` | `StateFlow.collectAsState()` |
| XML Views | `Fragment` with ViewBinding/DataBinding | `LiveData.observe()` |
| Mixed | ComposeView in Fragment, or Fragment in Compose via AndroidViewBinding | Bridge patterns |

| Architecture | Data flow |
|-------------|-----------|
| MVVM | UI Event → ViewModel → UiState (StateFlow) → Composable |
| MVI | Intent → Reducer → State → UI (unidirectional) |
| Clean | UI → ViewModel → UseCase → Repository → DataSource |
