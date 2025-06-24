//
//  Bloc.swift
//  Bloc
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Combine

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
    
    public func perform(event: E) {
        registeredHandlers[event]!(event, emit)
    }
}
