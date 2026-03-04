# Bloc

[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue.svg)](https://developer.apple.com/ios/)
[![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue.svg)](https://developer.apple.com/macos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Swift implementation of the [Bloc pattern](https://bloclibrary.dev/) for building applications in a consistent and understandable way, with composition, testing, and ergonomics in mind.

* [What is Bloc?](#what-is-bloc)
* [Architecture Comparison](#architecture-comparison)
* [Getting Started](#getting-started)
* [Core Concepts](#core-concepts)
* [Basic Usage](#basic-usage)
  * [Handling Events with Associated Values](#handling-events-with-associated-values)
  * [Async Operations](#async-operations)
  * [Combine Integration](#combine-integration)
  * [Error Handling](#error-handling)
* [Advanced Features](#advanced-features)
  * [BlocObserver](#blocobserver)
  * [Lifecycle Hooks](#lifecycle-hooks)
* [Examples](#examples)
* [Documentation](#documentation)
* [Installation](#installation)
* [Requirements](#requirements)
* [License](#license)

## What is Bloc?

**Bloc** (Business Logic Component) is a predictable state management pattern that helps separate presentation from business logic, making your code easier to test, maintain, and reason about.

The pattern is built around three core principles:

1. **Unidirectional Data Flow**: Events flow in → State flows out
2. **Single Source of Truth**: The Bloc holds the authoritative state
3. **Predictable State Changes**: State can only change in response to events

```
┌─────────────────────────────────────────────────────────┐
│                         View                            │
│                                                         │
│   ┌─────────────┐                    ┌──────────────┐   │
│   │   Button    │────send(event)────▶│  bloc.state  │   │
│   └─────────────┘                    └──────────────┘   │
│                                             ▲           │
└─────────────────────────────────────────────│───────────┘
                                              │
┌─────────────────────────────────────────────│───────────┐
│                        Bloc                 │           │
│                                             │           │
│   ┌─────────────┐    ┌──────────────┐    ┌──┴───────┐   │
│   │    Event    │───▶│   Handler    │───▶│  emit()  │   │
│   └─────────────┘    └──────────────┘    └──────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Architecture Comparison

Understanding how Bloc differs from other state management patterns helps you choose the right approach. Here's a visual comparison:

### Bloc Pattern

```mermaid
flowchart LR
    subgraph View["🖥️ View Layer"]
        UI[SwiftUI View]
        BlocBuilder[BlocBuilder]
    end
    
    subgraph BlocLayer["🧠 Bloc Layer"]
        Event((Event))
        Handler[Event Handler]
        State((State))
    end
    
    UI -->|"send(event)"| Event
    Event --> Handler
    Handler -->|"emit(state)"| State
    State --> BlocBuilder
    BlocBuilder -->|"rebuilds"| UI
    
    style Event fill:#f9a825,stroke:#f57f17,color:#000
    style State fill:#4caf50,stroke:#388e3c,color:#fff
    style Handler fill:#2196f3,stroke:#1976d2,color:#fff
```

**Key Characteristics:**
- **Unidirectional flow**: Events → Handler → State → View
- **Event-driven**: All state changes happen through explicit events
- **Type-safe handlers**: Each event type has its own handler
- **Reactive updates**: State changes automatically trigger view rebuilds

### MVVM Pattern

```mermaid
flowchart LR
    subgraph View["🖥️ View Layer"]
        UI[SwiftUI View]
    end
    
    subgraph ViewModel["📦 ViewModel"]
        Props["@Published properties"]
        Methods[Methods]
    end
    
    subgraph Model["💾 Model"]
        Data[Data/Services]
    end
    
    UI -->|"calls methods"| Methods
    UI <-->|"binds to"| Props
    Methods -->|"updates"| Props
    Methods <-->|"fetches/saves"| Data
    
    style Props fill:#9c27b0,stroke:#7b1fa2,color:#fff
    style Methods fill:#ff9800,stroke:#f57c00,color:#000
    style Data fill:#607d8b,stroke:#455a64,color:#fff
```

**Key Characteristics:**
- **Bidirectional binding**: View and ViewModel communicate directly
- **Method-based**: Actions are direct method calls
- **Property-driven**: State is exposed via `@Published` properties
- **Flexible**: Less structure, more freedom (and potential chaos)

### Redux Pattern

```mermaid
flowchart LR
    subgraph View["🖥️ View Layer"]
        UI[SwiftUI View]
    end
    
    subgraph ReduxStore["🏪 Redux Store"]
        Action((Action))
        Reducer[Reducer Function]
        State((State))
        Middleware[Middleware]
    end
    
    UI -->|"dispatch(action)"| Action
    Action --> Middleware
    Middleware --> Reducer
    Reducer -->|"returns new state"| State
    State -->|"subscribe"| UI
    
    style Action fill:#e91e63,stroke:#c2185b,color:#fff
    style State fill:#4caf50,stroke:#388e3c,color:#fff
    style Reducer fill:#673ab7,stroke:#512da8,color:#fff
    style Middleware fill:#ff5722,stroke:#e64a19,color:#fff
```

**Key Characteristics:**
- **Single store**: One global state tree for the entire app
- **Pure reducers**: State transitions are pure functions `(State, Action) -> State`
- **Middleware**: Side effects handled through middleware chain
- **Immutable state**: State is never mutated, always replaced

### Side-by-Side Comparison

```mermaid
flowchart TB
    subgraph Bloc["🅱️ BLOC"]
        direction TB
        B1[View sends Event]
        B2[Handler processes]
        B3[emit new State]
        B4[BlocBuilder rebuilds]
        B1 --> B2 --> B3 --> B4
    end
    
    subgraph MVVM["📱 MVVM"]
        direction TB
        M1[View calls method]
        M2[ViewModel updates]
        M3["@Published changes"]
        M4[View observes]
        M1 --> M2 --> M3 --> M4
    end
    
    subgraph Redux["🔄 REDUX"]
        direction TB
        R1[View dispatches Action]
        R2[Middleware runs]
        R3[Reducer computes]
        R4[Store updates]
        R1 --> R2 --> R3 --> R4
    end
    
    style Bloc fill:#e3f2fd,stroke:#1976d2
    style MVVM fill:#fce4ec,stroke:#c2185b
    style Redux fill:#f3e5f5,stroke:#7b1fa2
```

### Key Differences

| Aspect | Bloc | MVVM | Redux |
|--------|------|------|-------|
| **State Changes** | Via explicit events | Direct property mutation | Via dispatched actions |
| **State Location** | Per-feature Bloc | Per-view ViewModel | Single global store |
| **Side Effects** | Inside event handlers | Inside ViewModel methods | Via middleware |
| **Testability** | ✅ Excellent (event → state) | ⚠️ Moderate (mocking) | ✅ Excellent (pure reducers) |
| **Boilerplate** | Medium | Low | High |
| **Learning Curve** | Medium | Low | High |
| **Scalability** | ✅ Great (isolated blocs) | ⚠️ Can get messy | ✅ Great (predictable) |
| **Debugging** | ✅ Event trace | ⚠️ Property observation | ✅ Action log + time travel |
| **SwiftUI Fit** | ✅ Natural | ✅ Native | ⚠️ Requires adaptation |

### When to Choose Bloc

```mermaid
flowchart TD
    Start{Need State Management?}
    Start -->|Yes| Q1{Complex Business Logic?}
    Start -->|No| Simple[Use @State]
    
    Q1 -->|Yes| Q2{Need Predictable State?}
    Q1 -->|No| MVVM[Consider MVVM]
    
    Q2 -->|Yes| Q3{Multiple Features?}
    Q2 -->|No| MVVM
    
    Q3 -->|Yes| Bloc[✅ Use Bloc]
    Q3 -->|No| Q4{Need Testability?}
    
    Q4 -->|Yes| Bloc
    Q4 -->|No| MVVM
    
    style Bloc fill:#4caf50,stroke:#388e3c,color:#fff
    style MVVM fill:#2196f3,stroke:#1976d2,color:#fff
    style Simple fill:#ff9800,stroke:#f57c00,color:#000
```

**Choose Bloc when you need:**
- 🎯 **Predictable state management** with clear event → state mapping
- 🧪 **High testability** for business logic
- 📦 **Feature isolation** with independent blocs
- 🔍 **Debuggability** with traceable event streams
- 🏗️ **Scalable architecture** for growing teams and codebases

**Choose MVVM when:**
- Building simple screens with minimal business logic
- Rapid prototyping is needed
- Team is already familiar with MVVM patterns

**Choose Redux when:**
- You need time-travel debugging
- Global state coordination across the entire app is critical
- Coming from a React/Redux background

## Getting Started

### A Simple Counter

Let's build a counter to demonstrate the core concepts.

**1. Define your Events**

Events represent user actions or occurrences that can trigger state changes:

```swift
enum CounterEvent: Hashable {
    case increment
    case decrement
    case reset
}
```

**2. Create your Bloc**

The Bloc contains your business logic and manages state transitions:

```swift
import Bloc

@MainActor
class CounterBloc: Bloc<Int, CounterEvent> {
    
    init() {
        super.init(initialState: 0)
        
        on(.increment) { [weak self] event, emit in
            guard let self else { return }
            emit(self.state + 1)
        }
        
        on(.decrement) { [weak self] event, emit in
            guard let self else { return }
            emit(self.state - 1)
        }
        
        on(.reset) { event, emit in
            emit(0)
        }
    }
}
```

**3. Provide the Bloc**

Wrap your view hierarchy with `BlocProvider` to make Blocs available:

```swift
import SwiftUI
import Bloc

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            BlocProvider(with: [
                CounterBloc()
            ]) {
                ContentView()
            }
        }
    }
}
```

**4. Use in your View**

Access the Bloc and its state directly—SwiftUI automatically observes changes:

```swift
struct CounterView: View {
    let counterBloc = BlocRegistry.resolve(CounterBloc.self)
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(counterBloc.state)")
                .font(.largeTitle)
            
            HStack(spacing: 40) {
                Button("−") { counterBloc.send(.decrement) }
                Button("+") { counterBloc.send(.increment) }
            }
            .font(.title)
            
            Button("Reset") { counterBloc.send(.reset) }
        }
    }
}
```

That's it! No `@State` mirroring, no `.onReceive`—just direct state access with automatic SwiftUI updates.

## Core Concepts

### State

State represents the data your UI needs to render. States must conform to `Equatable`:

```swift
// Simple state (using a primitive type)
class CounterBloc: Bloc<Int, CounterEvent> { ... }

// Complex state (using a custom type)
struct LoginState: Equatable {
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var error: String?
}

class LoginBloc: Bloc<LoginState, LoginEvent> { ... }
```

### Events

Events are inputs to a Bloc—they trigger state changes. Events must conform to `Equatable & Hashable`:

```swift
// Simple enum events
enum CounterEvent: Hashable {
    case increment
    case decrement
}

// Events with associated values
enum LoginEvent: Hashable {
    case emailChanged(String)
    case passwordChanged(String)
    case loginButtonTapped
    case loginSucceeded(User)
    case loginFailed(String)
}
```

### Bloc

The Bloc is where your business logic lives. It receives events and emits new states:

```swift
@MainActor
class LoginBloc: Bloc<LoginState, LoginEvent> {
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
        super.init(initialState: LoginState())
        
        on(.emailChanged) { [weak self] event, emit in
            guard let self, case .emailChanged(let email) = event else { return }
            var newState = self.state
            newState.email = email
            emit(newState)
        }
        
        on(.loginButtonTapped) { [weak self] event, emit in
            guard let self else { return }
            var newState = self.state
            newState.isLoading = true
            emit(newState)
            
            Task {
                await self.performLogin()
            }
        }
    }
    
    private func performLogin() async {
        do {
            let user = try await authService.login(
                email: state.email,
                password: state.password
            )
            send(.loginSucceeded(user))
        } catch {
            send(.loginFailed(error.localizedDescription))
        }
    }
}
```

### BlocProvider

`BlocProvider` registers Blocs and makes them available throughout your view hierarchy:

```swift
BlocProvider(with: [
    CounterBloc(),
    LoginBloc(authService: LiveAuthService()),
    SettingsBloc()
]) {
    MainTabView()
}
```

### BlocRegistry

`BlocRegistry` provides type-safe access to registered Blocs:

```swift
// In any view within the BlocProvider hierarchy
let counterBloc = BlocRegistry.resolve(CounterBloc.self)
let loginBloc = BlocRegistry.resolve(LoginBloc.self)
```

If you try to resolve a Bloc that hasn't been registered, you'll get a helpful error message:

```
Bloc of type 'SettingsBloc' has not been registered.

Currently registered Blocs: [CounterBloc, LoginBloc]

Make sure to register it in your BlocProvider:

    BlocProvider(with: [
        SettingsBloc(initialState: ...),
        // ... other blocs
    ]) {
        YourContentView()
    }
```

## Basic Usage

### Handling Events with Associated Values

For events with associated values, use `mapEventToState`:

```swift
@MainActor
class SearchBloc: Bloc<SearchState, SearchEvent> {
    
    init() {
        super.init(initialState: SearchState())
        
        // Simple events can use `on(_:handler:)`
        on(.clearResults) { event, emit in
            emit(SearchState())
        }
    }
    
    // Events with associated values use `mapEventToState`
    override func mapEventToState(event: SearchEvent, emit: @escaping Emitter) {
        switch event {
        case .queryChanged(let query):
            var newState = state
            newState.query = query
            emit(newState)
            
        case .search:
            emit(SearchState(query: state.query, isLoading: true))
            Task { await performSearch() }
            
        case .resultsLoaded(let results):
            emit(SearchState(query: state.query, results: results))
            
        case .clearResults:
            break // Handled by `on(_:handler:)`
        }
    }
}
```

### Async Operations

Handle async operations by emitting loading states and using `Task`:

```swift
on(.fetchData) { [weak self] event, emit in
    guard let self else { return }
    
    // Emit loading state
    emit(.loading)
    
    // Perform async work
    Task {
        do {
            let data = try await self.api.fetchData()
            self.emit(.loaded(data))
        } catch {
            self.emit(.error(error.localizedDescription))
        }
    }
}
```

### Combine Integration

Three publishers are available for reactive pipelines:

```swift
// Observe every state change
counterBloc.statePublisher
    .removeDuplicates()
    .sink { state in print("State: \(state)") }
    .store(in: &cancellables)

// Observe every dispatched event
counterBloc.eventsPublisher
    .sink { event in print("Event: \(event)") }
    .store(in: &cancellables)

// Observe errors signalled via addError(_:)
counterBloc.errorsPublisher
    .sink { error in print("Error: \(error)") }
    .store(in: &cancellables)
```

`eventsPublisher` uses a `PassthroughSubject` internally and emits each event after it has been dispatched, in the order received.

### Error Handling

Use `addError(_:)` to surface errors without encoding them into the state type. This keeps your state model clean and lets error handling be composed separately:

```swift
on(.fetchData) { [weak self] event, emit in
    guard let self else { return }
    do {
        let data = try await api.fetchData()
        emit(.loaded(data))
    } catch {
        addError(error)   // broadcasts to errorsPublisher
        emit(.idle)       // state resets without carrying the error
    }
}
```

Observe errors centrally—for example to feed a crash reporter or a toast notification system:

```swift
bloc.errorsPublisher
    .sink { error in
        CrashReporter.log(error)
        ToastManager.show(error.localizedDescription)
    }
    .store(in: &cancellables)
```

You can use the built-in ``BlocError`` type for generic cases, or your own `Error` conforming type for domain-specific errors:

```swift
enum DataError: Error {
    case networkUnavailable
    case invalidResponse(statusCode: Int)
}

// Inside a handler:
addError(DataError.networkUnavailable)
```

## Advanced Features

### BlocObserver

`BlocObserver` is a global observer that receives lifecycle notifications from **every** Bloc in the app. It is the recommended way to implement cross-cutting concerns — logging, analytics, crash reporting — without touching individual Bloc subclasses.

#### Setting the observer

Set it once at app startup, before any Blocs are created:

```swift
@main
struct MyApp: App {
    init() {
        BlocObserver.shared = AppBlocObserver()
    }
}
```

#### Implementing a custom observer

Subclass `BlocObserver` and override the hooks you need. Always call `super`:

```swift
class AppBlocObserver: BlocObserver {

    override func onCreate(_ bloc: any BlocBase) {
        super.onCreate(bloc)
        print("Created: \(type(of: bloc))")
    }

    override func onEvent(_ bloc: any BlocBase, event: Any) {
        super.onEvent(bloc, event: event)
        print("\(type(of: bloc)) ← \(event)")
    }

    override func onChange(_ bloc: any BlocBase, change: Any) {
        super.onChange(bloc, change: change)
        print("\(type(of: bloc)) \(change)")
    }

    override func onTransition(_ bloc: any BlocBase, transition: Any) {
        super.onTransition(bloc, transition: transition)
        print("\(type(of: bloc)) \(transition)")
    }

    override func onError(_ bloc: any BlocBase, error: Error) {
        super.onError(bloc, error: error)
        CrashReporter.log(error)
    }
}
```

With this in place, every existing and future Bloc — `CounterBloc`, `LoginBloc`, anything new — is automatically observed. No per-Bloc logging code needed.

#### Observer hooks

| Hook | When it fires | Parameters |
|------|---------------|------------|
| `onCreate` | Bloc is initialised | `bloc` |
| `onEvent` | Before an event is dispatched | `bloc`, `event: Any` |
| `onChange` | After every `emit()` | `bloc`, `change: Any` (cast to `Change<S>`) |
| `onTransition` | After sync `emit()` with event context | `bloc`, `transition: Any` (cast to `Transition<E,S>`) |
| `onError` | When `addError()` is called | `bloc`, `error: Error` |

#### Redacting sensitive event data

When an event carries sensitive values such as passwords, conform the event to `CustomStringConvertible` so that `String(describing:)` — used by the observer — emits a safe representation:

```swift
extension LoginEvent: CustomStringConvertible {
    var description: String {
        switch self {
        case .login(let email, _):
            return "login(email: \"\(email)\", password: [REDACTED])"
        default:
            return "\(self)"
        }
    }
}
```

### Lifecycle Hooks

Every `Bloc` exposes four overridable lifecycle methods that let you observe its internal activity without modifying the state or handler logic. They are the foundation for features like `BlocObserver`, `HydratedBloc`, and per-bloc logging.

```
Event sent
    │
    ▼
onEvent(_:)          ← called before processing begins
    │
    ▼
Handler / mapEventToState
    │
    ▼
emit(_:) called
    │
    ├──▶ onTransition(_:)   ← includes the triggering event (sync only)
    └──▶ onChange(_:)       ← always fired, sync or async
```

#### `onEvent(_:)`

Called immediately before an event is dispatched to its handler.

```swift
override func onEvent(_ event: CounterEvent) {
    super.onEvent(event)
    print("Processing: \(event)")
}
```

#### `onChange(_:)`

Called after every `emit(_:)`, synchronous or async, with a `Change` value containing the previous and next states.

```swift
override func onChange(_ change: Change<Int>) {
    super.onChange(change)
    print(change)
    // Change { currentState: 0, nextState: 1 }
}
```

#### `onTransition(_:)`

A superset of `onChange` that also carries the event. Only fires when `emit` is called synchronously within an event handler — emissions from `Task` blocks reach `onChange` but not `onTransition`.

```swift
override func onTransition(_ transition: Transition<CounterEvent, Int>) {
    super.onTransition(transition)
    print(transition)
    // Transition { currentState: 0, event: increment, nextState: 1 }
}
```

#### `onError(_:)`

Called whenever `addError(_:)` is invoked, giving you a central place to log or react to Bloc-level errors.

```swift
override func onError(_ error: Error) {
    super.onError(error)
    CrashReporter.log(error)
}
```

#### Always call `super`

Each hook calls `super` to ensure the chain is preserved as the library grows (e.g. `BlocObserver` wiring, coming in a later release, is inserted at the `super` call site).

#### Calculator Example

The **Calculator** example in `Examples/Calculator/` demonstrates all four hooks live. As you operate the calculator, the right-hand panel displays a colour-coded log of every hook invocation in real time:

| Badge | Hook | When it fires |
|-------|------|---------------|
| `EVENT` (green) | `onEvent` | Every button tap |
| `TRANSITION` (purple) | `onTransition` | Synchronous state change with event context |
| `CHANGE` (cyan) | `onChange` | Every `emit()` call |
| `ERROR` (red) | `onError` | Division by zero via `addError()` |

```swift
@MainActor
class CalculatorBloc: Bloc<CalculatorState, CalculatorEvent> {

    let lifecycleLog = BlocLifecycleLog()

    override func onEvent(_ event: CalculatorEvent) {
        super.onEvent(event)
        lifecycleLog.append(kind: .event, message: "\(event)")
    }

    override func onChange(_ change: Change<CalculatorState>) {
        super.onChange(change)
        lifecycleLog.append(
            kind: .change,
            message: "\(change.currentState.displayValue) → \(change.nextState.displayValue)"
        )
    }

    override func onTransition(_ transition: Transition<CalculatorEvent, CalculatorState>) {
        super.onTransition(transition)
        lifecycleLog.append(
            kind: .transition,
            message: "\(transition.currentState.displayValue) — \(transition.event) → \(transition.nextState.displayValue)"
        )
    }

    override func onError(_ error: Error) {
        super.onError(error)
        lifecycleLog.append(kind: .error, message: error.localizedDescription ?? "\(error)")
    }
}
```

> The `BlocLifecycleLog` is a simple `@Observable` class that the view observes directly — it is not part of the Bloc state. This keeps logging concerns separate from business logic.

## Examples

The project includes four example implementations that demonstrate different complexity levels:

### 🔢 Counter Example

A simple counter that demonstrates the fundamentals:

| Aspect | Details |
|--------|---------|
| **State** | `Int` (primitive type) |
| **Events** | `increment`, `decrement`, `reset` |
| **Patterns** | Basic event handlers with `on(_:handler:)` |

**Location:** `Examples/Counter/`

```swift
// Simple state access
Text("Counter: \(counterBloc.state)")

// Send events
counterBloc.send(.increment)
```

### 🏎️ Formula One Example

A more complex example with async operations and enum-based states:

| Aspect | Details |
|--------|---------|
| **State** | `enum` with cases: `initial`, `loading`, `loaded([Driver])`, `error` |
| **Events** | `loadChampionship`, `clear` |
| **Patterns** | Async network calls, `mapEventToState`, state-driven UI |

**Location:** `Examples/FormulaOne/`

```swift
// State-driven UI with switch
switch formulaOneBloc.state {
case .initial:
    Button("Load") { formulaOneBloc.send(.loadChampionship) }
case .loading:
    ProgressView("Loading...")
case .loaded(let drivers):
    DriversList(drivers: drivers)
case .error(let error):
    ErrorView(error: error)
}
```

**Key Learnings:**
- Use enum states for mutually exclusive UI modes
- Emit `.loading` immediately before async work
- Pattern match on state for declarative UI

### 🔐 Login Example

A comprehensive authentication example demonstrating dependency injection and the repository pattern:

| Aspect | Details |
|--------|---------|
| **State** | `enum` with cases: `initial`, `loading`, `success(token)`, `error(LoginError)` |
| **Events** | `login(email, password)`, `logout` |
| **Patterns** | Repository pattern, dependency injection, protocol-based networking, comprehensive error handling |

**Location:** `Examples/Login/`

```swift
// Protocol-based repository for testability
protocol LoginRepositoryProtocol: Sendable {
    func login(email: String, password: String) async throws -> String
}

// Bloc depends on abstraction, not concrete type
@MainActor
class LoginBloc: Bloc<LoginState, LoginEvent> {
    private let repository: LoginRepositoryProtocol
    
    init(repository: LoginRepositoryProtocol) {
        self.repository = repository
        super.init(initialState: .initial)
    }
    
    override func mapEventToState(event: LoginEvent, emit: @escaping Emitter) {
        switch event {
        case .login(let email, let password):
            emit(.loading)
            Task { await performLogin(email: email, password: password) }
        case .logout:
            emit(.initial)
        }
    }
}

// Production usage
LoginBloc(repository: LoginNetworkService())

// Testing usage
let mockRepo = MockLoginRepository()
mockRepo.mockResult = .success("test-token")
LoginBloc(repository: mockRepo)
```

**Key Learnings:**
- Use protocols to abstract dependencies (Dependency Inversion Principle)
- Inject dependencies via initializer for testability
- Create mock implementations for unit testing
- Handle multiple error cases with custom error types
- Validate inputs before making network requests

**File Structure:**
```
Login/
├── Blocs/
│   ├── LoginBloc.swift       # Business logic
│   ├── LoginEvent.swift      # Events with associated values
│   └── LoginState.swift      # Enum-based states
├── Models/
│   └── LoginError.swift      # Custom error type
├── LoginRepository.swift      # Protocol (abstraction)
├── LoginNetworkService.swift  # Production implementation
├── MockLoginRepository.swift  # Test mock
└── LoginView.swift            # SwiftUI view
```

### 🖥️ SUVs Example

A comprehensive example demonstrating enterprise-level architecture with authentication flow, repository pattern, and protocol-based networking:

| Aspect | Details |
|--------|---------|
| **State** | `enum` with cases: `initial`, `authenticating`, `authenticated(user)`, `loadingInstances`, `loaded(user, instances)`, `extending`, `error` |
| **Events** | `login(username, password)`, `logout`, `fetchInstances`, `refreshInstances`, `extendInstance(id, hours)`, `selectInstance` |
| **Patterns** | Repository pattern, dependency injection, protocol-based network layer, complex state machine, Active Directory auth |

**Location:** `Examples/SUVs/`

```swift
// Protocol-based network service for testability
public protocol SUVNetworkServiceProtocol: Sendable {
    func login(username: String, password: String, clientKey: String) async throws -> SuvActiveDirectoryUser
    func fetchInstances(for username: String, authToken: String) async throws -> [SuvInstance]
    func extendInstance(instanceId: String, newStopTime: String, authToken: String) async throws -> SuvInstance
}

// Repository abstracts data access
public protocol SUVRepositoryProtocol: Sendable {
    func login(username: String, password: String) async throws -> SuvActiveDirectoryUser
    func fetchInstances(for username: String, authToken: String) async throws -> [SuvInstance]
    func extendInstance(instanceId: String, hours: Int, authToken: String) async throws -> SuvInstance
}

// Bloc with dependency injection
@MainActor
class SUVBloc: Bloc<SUVState, SUVEvent> {
    private let repository: SUVRepositoryProtocol
    
    init(
        initialState: SUVState = .initial,
        repository: SUVRepositoryProtocol = SUVRepository()
    ) {
        self.repository = repository
        super.init(initialState: initialState)
        registerHandlers()
    }
    
    override func mapEventToState(event: SUVEvent, emit: @escaping Emitter) {
        switch event {
        case .login(let username, let password):
            emit(.authenticating)
            Task { await performLogin(username: username, password: password, emit: emit) }
        case .extendInstance(let instanceId, let hours):
            handleExtendInstance(instanceId: instanceId, hours: hours, emit: emit)
        // ... other events
        }
    }
}

// Testing with mock repository
let mockRepo = MockSUVRepository()
mockRepo.mockInstances = [SuvInstance(...)]
let testBloc = SUVBloc(repository: mockRepo)
```

**Key Learnings:**
- **Layered Architecture**: Network → Repository → Bloc → View
- **Protocol-Based Design**: Both network service and repository are protocol-based for testability
- **Complex State Machine**: Multi-step flow from login → authenticated → loading → loaded
- **Automatic Flow**: Login automatically triggers instance fetching
- **Mock Support**: `MockSUVRepository` included for testing and previews
- **Error Handling**: Separate auth errors from general errors for better UX

**File Structure:**
```
SUVs/
├── Blocs/
│   ├── SUVBloc.swift          # Business logic with DI
│   ├── SUVEvent.swift         # Events with associated values
│   └── SUVState.swift         # Complex state machine
├── Models/
│   ├── SuvActiveDirectoryUser.swift  # Auth response model
│   ├── SuvInstance.swift             # Instance model with state enum
│   ├── SuvErrorResponse.swift        # API error model
│   └── SuvifyError.swift             # Custom error type
├── Repository/
│   ├── SUVRepositoryProtocol.swift   # Repository abstraction
│   ├── SUVRepository.swift           # Production implementation
│   └── MockSUVRepository.swift       # Test mock
├── Services/
│   ├── SUVNetworkServiceProtocol.swift  # Network abstraction
│   └── SUVNetworkService.swift          # URLSession implementation
└── SUVView.swift              # SwiftUI view with login + list
```

**API Integration:**
- **Authentication**: `POST https://narada.inday.io/narada/token` with AD credentials
- **Instances**: `GET https://api-suv.megaleo.com/suvapi/instances/users/{username}`
- **Extend**: `PUT https://api-suv.megaleo.com/suvapi/instances/{instanceId}`

### ✨ Lorcana Example

A comprehensive trading card game browser demonstrating search, pagination with infinite scroll, and multi-screen navigation:

| Aspect | Details |
|--------|---------|
| **State** | `struct` with cards, sets, pagination, loading states, and search query |
| **Events** | `fetchAllCards`, `search(query)`, `loadNextPage`, `loadSet(name)`, `clear` |
| **Patterns** | Debounced search, infinite scroll pagination, async image loading, multi-screen navigation, ink color theming |

**Location:** `Examples/Lorcana/`

```swift
// State with pagination support
struct LorcanaState: Equatable {
    var cards: [LorcanaCard]
    var sets: [LorcanaSet]
    var searchQuery: String
    var currentPage: Int
    var hasMorePages: Bool
    var isLoading: Bool
    var isLoadingMore: Bool
    var error: LorcanaError?
}

// Events for search and pagination
enum LorcanaEvent: BlocEvent {
    case clear
    case fetchAllCards
    case loadNextPage
    case search(query: String)
    case loadSet(setName: String)
}

// Bloc with async operations
@MainActor
class LorcanaBloc: Bloc<LorcanaState, LorcanaEvent> {
    private let networkService: LorcanaNetworkService
    
    override func mapEventToState(event: LorcanaEvent, emit: @escaping Emitter) {
        switch event {
        case .fetchAllCards:
            Task { await fetchAllCards(emit: emit) }
        case .loadNextPage:
            Task { await loadNextPage(emit: emit) }
        case .search(let query):
            Task { await searchCards(query: query, emit: emit) }
        // ...
        }
    }
}
```

**Key Features:**

1. **Debounced Search** - Searches after 3+ characters with debounce:
```swift
private func handleSearchChange(_ newValue: String) {
    searchTask?.cancel()
    guard newValue.count >= 3 else { return }
    
    searchTask = Task {
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s debounce
        guard !Task.isCancelled else { return }
        lorcanaBloc.send(.search(query: newValue))
    }
}
```

2. **Infinite Scroll Pagination** - Loads 100 cards per page:
```swift
ForEach(lorcanaBloc.state.cards) { card in
    cardRow(card: card)
        .onAppear {
            if card == lorcanaBloc.state.cards.last {
                lorcanaBloc.send(.loadNextPage)
            }
        }
}
```

3. **Multi-Screen Navigation** - Card detail → Set detail flow:
```swift
// Card Detail navigates to Set Detail
NavigationLink(destination: LorcanaSetDetailView(setName: setName)) {
    SetSection(setName: setName)
}
```

4. **Ink Color Theming** - Each card's UI adapts to its ink color:
```swift
enum InkColor: String {
    case amber, amethyst, emerald, ruby, sapphire, steel
}

func inkColorForCard(_ card: LorcanaCard) -> Color {
    switch card.inkColor {
    case .amber: return Color(red: 1.0, green: 0.75, blue: 0.2)
    case .amethyst: return Color(red: 0.6, green: 0.3, blue: 0.9)
    // ...
    }
}
```

**Key Learnings:**
- **Debounced Search**: Cancel pending tasks and wait before triggering API calls
- **Infinite Scroll**: Check if last item is visible to trigger next page load
- **Pagination State**: Track `currentPage`, `hasMorePages`, and `isLoadingMore` separately
- **Multi-View Navigation**: Pass data between views via NavigationLink
- **Theming**: Use card properties to customize UI colors dynamically

**File Structure:**
```
Lorcana/
├── Blocs/
│   ├── LorcanaBloc.swift       # Business logic with pagination
│   ├── LorcanaEvent.swift      # Search/pagination events
│   └── LorcanaState.swift      # State with cards, pagination, loading
├── Models/
│   ├── LorcanaCard.swift       # Card model with ink colors
│   ├── LorcanaSet.swift        # Set model
│   └── LorcanaError.swift      # Custom error type
├── Services/
│   └── LorcanaNetworkService.swift  # API integration with Alamofire
├── LorcanaView.swift           # Main view with search + infinite scroll
├── LorcanaCardDetailView.swift # Card detail with set navigation
└── LorcanaSetDetailView.swift  # Set detail with card grid
```

**API Integration:**
- **All Cards**: `GET https://api.lorcana-api.com/cards/all?page=1&pagesize=100`
- **Search by Name**: `GET https://api.lorcana-api.com/cards/{cardName}`
- **Cards by Set**: `GET https://api.lorcana-api.com/cards/fetch?search=set_name={setName}`

> 📖 See the DocC documentation for a complete walkthrough of each example.

## Documentation

The documentation is built with DocC. Generate it in Xcode via **Product → Build Documentation** (or `⌃⇧⌘D`).

### Articles

- **Getting Started**: Your first Bloc in 5 minutes
- **Examples**: Complete walkthrough of Counter and Formula One examples
- **State Management**: Designing effective state types
- **Event Handling**: Patterns for complex event logic
- **Best Practices**: SOLID principles and architecture tips

## Installation

### Swift Package Manager

Add Bloc to your `Package.swift`:

```swift
dependencies: [
    .package(path: "../Bloc")  // Local package
    // Or from a repository:
    // .package(url: "https://github.com/user/Bloc.git", from: "1.0.0")
]
```

Or in Xcode:

1. **File → Add Package Dependencies...**
2. Enter the package URL or path
3. Add `Bloc` to your target

## Requirements

| Platform | Minimum Version |
|----------|-----------------|
| iOS      | 17.0+           |
| macOS    | 14.0+           |
| tvOS     | 17.0+           |
| watchOS  | 10.0+           |
| Swift    | 5.9+            |

## Inspiration

This library is inspired by:

- [bloclibrary.dev](https://bloclibrary.dev/) - The original Bloc pattern for Flutter/Dart
- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) - Point-Free's state management library
- [Redux](https://redux.js.org/) - Predictable state container for JS apps

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.

---

**Built with ❤️ for the Swift community**
