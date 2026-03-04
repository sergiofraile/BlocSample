//
//  BlocObserver.swift
//  Bloc
//
//  Created by Sergio Fraile on 04/03/2026.
//

/// A global observer that receives lifecycle notifications from every ``Bloc``
/// in the application.
///
/// `BlocObserver` is the recommended way to implement cross-cutting concerns such
/// as logging, analytics, crash reporting, and debugging. Set a custom observer
/// once at app startup and it automatically applies to every Bloc without any
/// changes to individual Bloc subclasses:
///
/// ```swift
/// // In your App entry point
/// BlocObserver.shared = AppBlocObserver()
/// ```
///
/// ## Implementing a custom observer
///
/// Subclass `BlocObserver` and override the hooks you care about. Always call
/// `super` so the chain is preserved for future library features:
///
/// ```swift
/// class AppBlocObserver: BlocObserver {
///
///     override func onCreate(_ bloc: any BlocBase) {
///         super.onCreate(bloc)
///         print("Created: \(type(of: bloc))")
///     }
///
///     override func onEvent(_ bloc: any BlocBase, event: Any) {
///         super.onEvent(bloc, event: event)
///         print("\(type(of: bloc)) received: \(event)")
///     }
///
///     override func onChange(_ bloc: any BlocBase, change: Any) {
///         super.onChange(bloc, change: change)
///         print("\(type(of: bloc)) changed: \(change)")
///     }
///
///     override func onTransition(_ bloc: any BlocBase, transition: Any) {
///         super.onTransition(bloc, transition: transition)
///         print("\(type(of: bloc)) transition: \(transition)")
///     }
///
///     override func onError(_ bloc: any BlocBase, error: Error) {
///         super.onError(bloc, error: error)
///         print("\(type(of: bloc)) error: \(error)")
///     }
/// }
/// ```
///
/// ## Event typing
///
/// The `event`, `change`, and `transition` parameters are typed as `Any` to keep
/// the observer non-generic. Cast to the concrete type when needed:
///
/// ```swift
/// override func onEvent(_ bloc: any BlocBase, event: Any) {
///     if let counterEvent = event as? CounterEvent {
///         Analytics.track(counterEvent)
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Setting the observer
///
/// - ``shared``
///
/// ### Lifecycle hooks
///
/// - ``onCreate(_:)``
/// - ``onEvent(_:event:)``
/// - ``onChange(_:change:)``
/// - ``onTransition(_:transition:)``
/// - ``onError(_:error:)``
@MainActor
open class BlocObserver {

    /// The global observer instance, called by every ``Bloc`` at each lifecycle point.
    ///
    /// Replace with a custom subclass at app startup before any Blocs are created:
    ///
    /// ```swift
    /// @main
    /// struct MyApp: App {
    ///     init() {
    ///         BlocObserver.shared = AppBlocObserver()
    ///     }
    /// }
    /// ```
    /// - Note: Marked `nonisolated(unsafe)` because the compiler cannot verify that
    ///   writes and reads are actor-isolated. In practice this is safe: `shared` is
    ///   written exactly once at app startup (before any Bloc is created) and is only
    ///   ever read from `@MainActor` context inside Bloc lifecycle hooks.
    nonisolated(unsafe) public static var shared: BlocObserver = BlocObserver()

    nonisolated public init() {}

    // MARK: - Lifecycle Hooks

    /// Called when a Bloc is initialised.
    ///
    /// - Parameter bloc: The Bloc that was created.
    open func onCreate(_ bloc: any BlocBase) {}

    /// Called immediately before an event is processed by a Bloc.
    ///
    /// - Parameters:
    ///   - bloc: The Bloc receiving the event.
    ///   - event: The event, typed as `Any`. Cast to the concrete event type if needed.
    open func onEvent(_ bloc: any BlocBase, event: Any) {}

    /// Called after every ``Bloc/emit(_:)``, with the previous and next state.
    ///
    /// - Parameters:
    ///   - bloc: The Bloc that emitted a new state.
    ///   - change: A ``Change`` value, typed as `Any`. Cast to `Change<SomeState>` if needed.
    open func onChange(_ bloc: any BlocBase, change: Any) {}

    /// Called for synchronous state changes, with the event that caused them.
    ///
    /// Only fires when `emit` is called synchronously inside an event handler.
    /// Async emissions (inside `Task`) reach ``onChange(_:change:)`` only.
    ///
    /// - Parameters:
    ///   - bloc: The Bloc whose state transitioned.
    ///   - transition: A ``Transition`` value, typed as `Any`.
    open func onTransition(_ bloc: any BlocBase, transition: Any) {}

    /// Called when ``Bloc/addError(_:)`` is invoked.
    ///
    /// - Parameters:
    ///   - bloc: The Bloc that signalled the error.
    ///   - error: The error that was reported.
    open func onError(_ bloc: any BlocBase, error: Error) {}
}
