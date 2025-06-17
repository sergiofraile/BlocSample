
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
    var statePublisher: AnyPublisher<State, Never> { get }
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
    
    var states: [State] = []
    public var statePublisher: AnyPublisher<State, Never> {
        states.publisher.eraseToAnyPublisher()
    }
    
    var registeredHandlers: [E: Handler] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
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
        states.append(state)
    }
    
    public func on(_ event: E, handler: @escaping Handler) {
        registeredHandlers[event] = handler
    }
    
    func performHandler(event: E) {
        registeredHandlers[event]!(event, emit)
    }
}

@MainActor
class BlocProvider {
    static var shared: BlocProvider? = nil
    
    var registeredBlocs: [any BlocBase] = []
    
    init(with blocs: [any BlocBase]) {
        self.registeredBlocs = blocs
        BlocProvider.shared = self
    }
    
    static func bloc<S: BlocState, E: BlocEvent>(for state: S.Type, event: E.Type) throws -> any BlocBase {
        if let bloc = BlocProvider.shared?.registeredBlocs.first(where: {
            $0 is Bloc<S, E>
        }) {
            return bloc
        } else {
            throw fatalError("Bloc for \(S.self) and \(E.self) hasn't been provided")
        }
    }
}

struct BlocBuilder<S: BlocState, E: BlocEvent>: View {
    let viewBlock: (AnyPublisher<S, Never>, Bloc<S,E>) -> AnyView
    let bloc: Bloc<S,E>

    init(viewBlock: @escaping (AnyPublisher<S, Never>, Bloc<S,E>) -> AnyView) throws {
        self.viewBlock = viewBlock
        self.bloc = try BlocProvider.bloc(for: S.self, event: E.self) as! Bloc<S, E>
    }
    
    var body: some View {
        viewBlock(bloc.statePublisher, bloc)
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

