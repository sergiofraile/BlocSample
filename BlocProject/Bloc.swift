
//
//  Bloc.swift
//  BlocProject
//
//  Created by Sergio Fraile on 28/04/2025.
//

import Combine
import SwiftUI

/// Bloc definition
///     - States are equatable types, so they can be differenciated of each other by specific type or by props
///      - Events are equatable as well
///      - Bloc receives events and triggers states. For that
///          * Needs a method to add events to a stream (add)
///          * Needs an init that pairs events to methods
///          * Methods paired to events need a particular code signature, where they receive a emitter
///          * The emitter outputs a new state to the state stream (emit)

public typealias BlocState = Equatable
public typealias BlocEvent = Equatable & Hashable

public enum BlocError: Error {
    case defaultError
}

public protocol BlocBase {
    associatedtype State: BlocState
    associatedtype Event: BlocEvent
    typealias Emitter = (State) -> Void
    typealias Handler = (Event, Emitter) -> Void
    
    var eventsPublisher: AnyPublisher<Event, BlocError> { get }
    var states: CurrentValueSubject<State, Never> { get }
//    var statePublisher: AnyPublisher<State, Never> { get }
//    func emit(_ state: State)
    func on(_ event: Event, handler: @escaping Handler)
}

public class Bloc<S: BlocState, E: BlocEvent>: BlocBase {
    
    public typealias State = S
    public typealias Event = E
    
    var events: [Event] = []
    public var eventsPublisher: AnyPublisher<Event, BlocError> {
        events.publisher
            .setFailureType(to:BlocError.self)
            .eraseToAnyPublisher()
    }
    
    public var states: CurrentValueSubject<S, Never>
    var registeredHandlers: [E: Handler] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    init(initialState: State) {
        states = CurrentValueSubject<S, Never>(initialState)
        subscribeToEvents()
    }
    
    func subscribeToEvents() {
        eventsPublisher
            .sink { error in
                // TODO: handle error
            } receiveValue: { [weak self] event in
                self?.performHandler(event: event)
            }.store(in: &cancellables)
    }
    
    public func emit(_ state: State) {
        states.send(state)
    }
    
    public func on(_ event: E, handler: @escaping Handler) {
        registeredHandlers[event] = handler
    }
    
    func performHandler(event: E) {
        registeredHandlers[event]!(event, emit)
    }
}

@MainActor
class BlocRegistry {
    static var shared: BlocRegistry? = nil
    
    var registeredBlocs: [any BlocBase] = []
    
    @usableFromInline
    init(with blocs: [any BlocBase]) {
        self.registeredBlocs = blocs
        BlocRegistry.shared = self
    }
    
    static func bloc<S: BlocState, E: BlocEvent>(for state: S.Type, event: E.Type) throws -> any BlocBase {
        if let bloc = BlocRegistry.shared?.registeredBlocs.first(where: {
            $0 is Bloc<S, E>
        }) {
            return bloc
        } else {
            throw fatalError("Bloc for \(S.self) and \(E.self) hasn't been provided")
        }
    }
}

struct BlocProvider<Content: View>: View {
    let content: () -> Content
    
    init(with blocs: [any BlocBase], @ViewBuilder content: @escaping () -> Content) {
        _ = BlocRegistry(with: blocs)
        self.content = content
    }
    
    var body: some View {
        content()
    }
}
    

struct BlocBuilder<S: BlocState, E: BlocEvent>: View {
    let viewBlock: (CurrentValueSubject<S, Never>, Bloc<S,E>) -> AnyView
    let bloc: Bloc<S,E>

    init(viewBlock: @escaping (CurrentValueSubject<S, Never>, Bloc<S,E>) -> AnyView) throws {
        self.viewBlock = viewBlock
        self.bloc = try BlocRegistry.bloc(for: S.self, event: E.self) as! Bloc<S, E>
    }
    
    var body: some View {
        viewBlock(bloc.states, bloc)
    }
}

//
//struct BlocListener {
//    init() {}
//}
//
//class BlocListener<BlocState: Equatable> {
//    static func
//}


// Given a SwiftuI view you are able to consume a bloc

// BlocProvider(
//    [BlocA(), BlocB()]
// ) {
//    SwiftUI View Top Level
// }
//
// struct MyConsumerView {
//    .environment(./)
//
//    consumeBloc<BlocA>(observe: state) {
//        if state is Loading {
//            D///
//        }
//        if state .
//            AnotherView()
//            Button {
//            BlocA.send(.loginButtonTapped)
//        }
//        }
//    }
// }
//

