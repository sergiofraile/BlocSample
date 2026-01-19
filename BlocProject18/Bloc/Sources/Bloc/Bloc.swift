//
//  Bloc.swift
//  Bloc
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Combine
import Observation

/// A predictable state management class that processes events and emits state changes.
///
/// `Bloc` is the core building block of the Bloc pattern. It receives ``BlocEvent``s,
/// processes them through registered handlers, and emits new ``BlocState``s that
/// SwiftUI automatically observes.
///
/// ## Overview
///
/// A Bloc encapsulates your business logic and manages state transitions in a predictable way.
/// You create a Bloc by subclassing and registering event handlers:
///
/// ```swift
/// @MainActor
/// class CounterBloc: Bloc<Int, CounterEvent> {
///
///     init() {
///         super.init(initialState: 0)
///
///         on(.increment) { [weak self] event, emit in
///             guard let self else { return }
///             emit(self.state + 1)
///         }
///
///         on(.decrement) { [weak self] event, emit in
///             guard let self else { return }
///             emit(self.state - 1)
///         }
///     }
/// }
/// ```
///
/// ## State Observation
///
/// Thanks to the `@Observable` macro, SwiftUI views automatically re-render when
/// the ``state`` property changes. No manual subscription is required:
///
/// ```swift
/// struct CounterView: View {
///     let counterBloc = BlocRegistry.resolve(CounterBloc.self)
///
///     var body: some View {
///         Text("Count: \(counterBloc.state)")  // Automatically updates
///         Button("+") { counterBloc.send(.increment) }
///     }
/// }
/// ```
///
/// ## Combine Integration
///
/// For advanced reactive patterns, subscribe to ``statePublisher``:
///
/// ```swift
/// counterBloc.statePublisher
///     .sink { state in
///         print("State changed: \(state)")
///     }
///     .store(in: &cancellables)
/// ```
///
/// ## Topics
///
/// ### Creating a Bloc
///
/// - ``init(initialState:)``
///
/// ### Accessing State
///
/// - ``state``
/// - ``statePublisher``
///
/// ### Handling Events
///
/// - ``on(_:handler:)``
/// - ``mapEventToState(event:emit:)``
/// - ``send(_:)``
///
/// ### Emitting State
///
/// - ``emit(_:)``
@Observable
@MainActor
open class Bloc<S: BlocState, E: BlocEvent>: BlocBase {
    
    /// The state type managed by this Bloc.
    public typealias State = S
    
    /// The event type processed by this Bloc.
    public typealias Event = E
    
    // MARK: - Observable State
    
    @ObservationIgnored
    private var _state: S
    
    /// The current state of the Bloc.
    ///
    /// This property is automatically observed by SwiftUI. When you access it
    /// in a view's `body`, SwiftUI registers a dependency and re-renders the
    /// view when the state changes.
    ///
    /// ```swift
    /// Text("Count: \(counterBloc.state)")  // View updates when state changes
    /// ```
    ///
    /// - Note: This property is read-only from outside the Bloc. Use ``emit(_:)``
    ///   to update state from within event handlers.
    public var state: S {
        get {
            access(keyPath: \.state)
            return _state
        }
        set {
            withMutation(keyPath: \.state) {
                _state = newValue
            }
        }
    }
    
    // MARK: - Combine Support
    
    @ObservationIgnored
    private var statesSubject: CurrentValueSubject<S, Never>
    
    /// A Combine publisher that emits state changes.
    ///
    /// Use this publisher for advanced reactive patterns or when you need
    /// to integrate with existing Combine pipelines:
    ///
    /// ```swift
    /// counterBloc.statePublisher
    ///     .removeDuplicates()
    ///     .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
    ///     .sink { state in
    ///         print("Debounced state: \(state)")
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    ///
    /// - Note: For SwiftUI views, prefer accessing ``state`` directly—it's
    ///   simpler and automatically handles observation.
    public var statePublisher: AnyPublisher<S, Never> {
        statesSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Events
    
    @ObservationIgnored
    var events: [Event] = []
    
    /// A Combine publisher that emits events as they are sent to the Bloc.
    ///
    /// This can be useful for debugging or logging purposes:
    ///
    /// ```swift
    /// counterBloc.eventsPublisher
    ///     .sink { event in
    ///         print("Event received: \(event)")
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    public var eventsPublisher: AnyPublisher<Event, BlocError> {
        events.publisher
            .setFailureType(to: BlocError.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Handlers
    
    @ObservationIgnored
    var registeredHandlers: [E: Handler] = [:]
    
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Creates a new Bloc with the specified initial state.
    ///
    /// After initialization, register event handlers using ``on(_:handler:)``
    /// or override ``mapEventToState(event:emit:)`` for dynamic event handling.
    ///
    /// ```swift
    /// @MainActor
    /// class CounterBloc: Bloc<Int, CounterEvent> {
    ///
    ///     init() {
    ///         super.init(initialState: 0)
    ///
    ///         on(.increment) { [weak self] event, emit in
    ///             guard let self else { return }
    ///             emit(self.state + 1)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter initialState: The starting state for the Bloc.
    public init(initialState: State) {
        _state = initialState
        statesSubject = CurrentValueSubject<S, Never>(initialState)
        subscribeToEvents()
    }
    
    private func subscribeToEvents() {
        eventsPublisher
            .sink { error in
                // TODO: handle error
            } receiveValue: { [weak self] event in
                self?.send(event)
            }.store(in: &cancellables)
    }
    
    // MARK: - State Emission
    
    /// Emits a new state, triggering UI updates.
    ///
    /// Call this method from within event handlers to transition to a new state.
    /// This updates both the observable ``state`` property and the ``statePublisher``.
    ///
    /// ```swift
    /// on(.increment) { [weak self] event, emit in
    ///     guard let self else { return }
    ///     emit(self.state + 1)  // Emits the new state
    /// }
    /// ```
    ///
    /// You can also call `emit` directly on the Bloc instance for async operations:
    ///
    /// ```swift
    /// Task {
    ///     let data = try await api.fetchData()
    ///     self.emit(.loaded(data))  // Update state from async context
    /// }
    /// ```
    ///
    /// - Parameter state: The new state to emit.
    public func emit(_ state: State) {
        self.state = state
        statesSubject.send(state)
    }
    
    // MARK: - Event Handling
    
    /// Registers a handler for a specific event.
    ///
    /// Use this method to define how the Bloc responds to events. The handler
    /// receives the event and an `emit` function to output new states.
    ///
    /// ```swift
    /// on(.increment) { [weak self] event, emit in
    ///     guard let self else { return }
    ///     emit(self.state + 1)
    /// }
    ///
    /// on(.reset) { event, emit in
    ///     emit(0)  // No need for self if not accessing state
    /// }
    /// ```
    ///
    /// - Important: Always use `[weak self]` in handlers that capture `self`
    ///   to avoid retain cycles.
    ///
    /// - Parameters:
    ///   - event: The event to handle.
    ///   - handler: A closure that processes the event and emits new states.
    public func on(_ event: E, handler: @escaping Handler) {
        registeredHandlers[event] = handler
    }
    
    /// Override this method for custom or dynamic event-to-state mapping.
    ///
    /// Use `mapEventToState` when you need to handle events with associated
    /// values or when you prefer a switch-based approach:
    ///
    /// ```swift
    /// override func mapEventToState(event: SearchEvent, emit: @escaping Emitter) {
    ///     switch event {
    ///     case .queryChanged(let query):
    ///         var newState = state
    ///         newState.query = query
    ///         emit(newState)
    ///
    ///     case .search:
    ///         emit(SearchState(isLoading: true))
    ///         Task { await performSearch() }
    ///
    ///     case .resultsLoaded(let results):
    ///         emit(SearchState(results: results))
    ///     }
    /// }
    /// ```
    ///
    /// - Note: This method is called only when no handler is registered for
    ///   the event via ``on(_:handler:)``.
    ///
    /// - Parameters:
    ///   - event: The event to process.
    ///   - emit: A closure to call with the new state.
    open func mapEventToState(event: E, emit: @escaping Emitter) {
        // Override in subclasses for custom event handling
        print("No handler found for event: \(event)")
    }
    
    /// Sends an event to the Bloc for processing.
    ///
    /// This is the primary way to trigger state changes from your UI:
    ///
    /// ```swift
    /// Button("+") {
    ///     counterBloc.send(.increment)
    /// }
    /// ```
    ///
    /// Events are processed synchronously. If a handler is registered for the
    /// event via ``on(_:handler:)``, it will be called. Otherwise,
    /// ``mapEventToState(event:emit:)`` is invoked.
    ///
    /// - Parameter event: The event to send.
    public func send(_ event: E) {
        if let handler = registeredHandlers[event] {
            handler(event, emit)
        } else {
            mapEventToState(event: event, emit: emit)
        }
    }
}
