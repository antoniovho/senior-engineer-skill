# iOS Hints

What to search for when documenting an **iOS (Swift)** mobile app.

---

## File Patterns

| What | Where to look |
|------|--------------|
| Entry point | `*App.swift` with `@main`, `AppDelegate.swift` |
| Navigation | `*Router.swift`, `*Coordinator.swift`, `NavigationStack`, `NavigationPath` |
| Views/screens | `*View.swift`, `*Screen.swift`, `*ViewController.swift` |
| ViewModels | `*ViewModel.swift`, `*Store.swift` |
| Models | `*Model.swift`, `*Entity.swift`, files in `Domain/` or `Models/` |
| Services | `*Service.swift`, `*Repository.swift`, `*Client.swift` |
| Config | `Info.plist`, `*.xcconfig`, `Configuration/` |
| DI | `*Container.swift`, `*Assembly.swift`, `@Injected`, Swinject/Factory usage |
| Persistence | `*.xcdatamodeld`, `*+CoreData*`, `@Model` (SwiftData), `*Store.swift` |
| Package deps | `Package.swift`, `*.xcodeproj/project.pbxproj` |

## Keywords to Search

- **Navigation:** `NavigationStack`, `NavigationLink`, `NavigationPath`, `Coordinator`, `Router`, `dismiss`, `sheet`, `fullScreenCover`
- **State:** `@State`, `@Binding`, `@Published`, `@Observable`, `@ObservedObject`, `@StateObject`, `@EnvironmentObject`
- **Concurrency:** `async`, `await`, `Task {`, `TaskGroup`, `actor`, `@MainActor`, `nonisolated`
- **DI:** `@Injected`, `Container`, `Assembly`, `Factory`, `resolve(`, `register(`
- **Data:** `@Model`, `@Attribute`, `NSManagedObject`, `@FetchRequest`, `UserDefaults`, `Keychain`
- **Network:** `URLSession`, `async let`, `Codable`, `JSONDecoder`, `APIClient`
- **UI:** `@ViewBuilder`, `some View`, `modifier(`, `PreviewProvider`, `#Preview`

## Language-Specific Patterns for `how-to/patterns.md`

- Protocol-oriented design (protocol → extension → default implementation)
- Value types (struct) preferred over reference types (class)
- `async/await` for all networking (no completion handlers in new code)
- `@Observable` (iOS 17+) or `ObservableObject` for view models
- State hoisting: Views receive bindings, don't own state
- Dependency injection via protocol + container (not singletons)
- Access control: `internal` by default, `public` only for module API

## Platform Specifics

| UI Framework | View pattern | State mechanism |
|-------------|-------------|-----------------|
| SwiftUI | `struct *View: View { var body }` | `@State`, `@Observable` |
| UIKit | `class *ViewController: UIViewController` | delegates, closures, Combine |
| Mixed | SwiftUI hosts UIKit via `UIViewControllerRepresentable` | Bridge patterns |

| Architecture | Data flow |
|-------------|-----------|
| MVVM | View ← ViewModel (Published/Observable) ← Service |
| TCA | View ← Store ← Reducer (Action → State) |
| VIPER | View ← Presenter ← Interactor ← Entity |
