//
//  Bloc.swift
//  Bloc
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Combine

@MainActor
open class Bloc<S: BlocState, E: BlocEvent>: BlocBase {
    
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
    
    public init(initialState: State) {
        states = CurrentValueSubject<S, Never>(initialState)
        subscribeToEvents()
    }
    
    func subscribeToEvents() {
        eventsPublisher
            .sink { error in
                // TODO: handle error
            } receiveValue: { [weak self] event in
                self?.perform(event: event)
            }.store(in: &cancellables)
    }
    
    public func emit(_ state: State) {
        states.send(state)
    }
    
    public func on(_ event: E, handler: @escaping Handler) {
        registeredHandlers[event] = handler
    }
    
    open func mapEventToState(event: E, emit: @escaping Emitter) {
        // This method can be used to register a custom handler that doesn't depend on a specific event
        // It can be useful for handling events dynamically or in a more generic way
        // For example, you could use it to handle multiple events with the same logic
        // registeredHandlers[event] = handler
        print("Custom handler registered")
    }
    
    public func perform(event: E) {
        if let handler = registeredHandlers[event] {
            handler(event, emit)
        } else {
            print("No handler registered for event: \(event)")
            print("Attempting mapEventToState for event: \(event)")
            mapEventToState(event: event, emit: emit)
        }
    }
    
//    LoggerStore.shared.storeMessage(
//        label: "auth",
//        level: .debug,
//        message: "Will login user",
//        metadata: ["userId": .string("uid-1")]
//    )
}


//func onCase<T>(
//    _ pattern: @escaping (MyEvent) -> T?,
//    handler: @escaping (T, (MyEvent) -> Void) -> Void
//) -> ((MyEvent, (MyEvent) -> Void) -> Void) {
//    return { event, emit in
//        if let value = pattern(event) {
//            handler(value, emit)
//        }
//    }
//}

//extension MyEvent {
//    func on<T>(_ pattern: @escaping (MyEvent) -> T?, perform: (MyEvent, (MyEvent) -> Void) -> Void) -> ((MyEvent, (MyEvent) -> Void) -> Void)? {
//        return { event, emit in
//            if let value = pattern(event) {
//                perform(event, emit)
//            }
//        }
//    }
//}

enum LOL {
    case lolito(name: String)
    case lolito2(name: String)
}

struct Paco {
    
    func paco(lol: LOL) {
        if case .lolito(let name) = lol {
            print("Paco with lolito name: \(name)")
        } else if case .lolito2(let name) = lol {
            print("Paco with lolito2 name: \(name)")
        } else {
            print("Paco with unknown lol")
        }
    }
}
