//
//  BlocBase.swift
//  Bloc
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Combine

public protocol BlocBase {
    associatedtype State: BlocState
    associatedtype Event: BlocEvent
    typealias Emitter = (State) -> Void
    typealias Handler = (Event, Emitter) -> Void
    
    var eventsPublisher: AnyPublisher<Event, BlocError> { get }
    var states: CurrentValueSubject<State, Never> { get }
    func on(_ event: Event, handler: @escaping Handler)
    func perform(event: Event)
}
