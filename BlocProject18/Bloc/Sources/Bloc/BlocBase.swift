//
//  BlocBase.swift
//  Bloc
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Combine

/// A protocol that defines the interface for all Bloc types.
///
/// `BlocBase` provides a common interface that all Blocs conform to, enabling
/// type-erased storage and generic operations. The ``Bloc`` class provides the
/// concrete implementation.
///
/// ## Overview
///
/// You typically don't interact with `BlocBase` directly—instead, you subclass
/// ``Bloc`` and use ``BlocRegistry`` to resolve concrete Bloc types. However,
/// `BlocBase` is useful for:
///
/// - Storing heterogeneous Bloc collections
/// - Creating generic utilities that work with any Bloc
/// - Defining custom Bloc-like types
///
/// ## Type Aliases
///
/// The protocol defines two type aliases for convenience:
///
/// - ``Emitter``: A closure type `(State) -> Void` for emitting new states
/// - ``Handler``: A closure type `(Event, Emitter) -> Void` for handling events
///
/// ## Topics
///
/// ### Associated Types
///
/// - ``State``
/// - ``Event``
///
/// ### Type Aliases
///
/// - ``Emitter``
/// - ``Handler``
///
/// ### Accessing State
///
/// - ``state``
/// - ``statePublisher``
///
/// ### Handling Events
///
/// - ``on(_:handler:)``
/// - ``send(_:)``
public protocol BlocBase: AnyObject {
    
    /// The type of state managed by this Bloc.
    ///
    /// Must conform to ``BlocState`` (which is `Equatable`).
    associatedtype State: BlocState
    
    /// The type of events processed by this Bloc.
    ///
    /// Must conform to ``BlocEvent`` (which is `Equatable & Hashable`).
    associatedtype Event: BlocEvent
    
    /// A closure type for emitting new states.
    ///
    /// ```swift
    /// let emit: Emitter = { newState in
    ///     // State has been updated
    /// }
    /// emit(newState)
    /// ```
    typealias Emitter = (State) -> Void
    
    /// A closure type for handling events.
    ///
    /// Handlers receive the event and an emitter to output new states:
    ///
    /// ```swift
    /// let handler: Handler = { event, emit in
    ///     // Process event and emit new state
    ///     emit(newState)
    /// }
    /// ```
    typealias Handler = (Event, Emitter) -> Void
    
    /// The current state of the Bloc.
    ///
    /// This property is observable by SwiftUI when accessed in a view's `body`.
    /// State changes automatically trigger view updates.
    ///
    /// ```swift
    /// Text("Count: \(bloc.state)")  // Updates when state changes
    /// ```
    var state: State { get }
    
    /// A Combine publisher that emits state changes.
    ///
    /// Use this for reactive patterns or Combine integration:
    ///
    /// ```swift
    /// bloc.statePublisher
    ///     .sink { state in
    ///         print("New state: \(state)")
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    var statePublisher: AnyPublisher<State, Never> { get }
    
    /// A Combine publisher that emits events as they are received.
    var eventsPublisher: AnyPublisher<Event, BlocError> { get }
    
    /// Registers a handler for a specific event.
    ///
    /// - Parameters:
    ///   - event: The event to handle.
    ///   - handler: A closure that processes the event and emits new states.
    func on(_ event: Event, handler: @escaping Handler)
    
    /// Sends an event to the Bloc for processing.
    ///
    /// - Parameter event: The event to send.
    func send(_ event: Event)
}
