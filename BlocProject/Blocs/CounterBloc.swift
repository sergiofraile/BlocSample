//
//  CounterBloc.swift
//  BlocProject
//
//  Created by Sergio Fraile on 16/06/2025.
//

enum CounterEvent : BlocEvent {
    case initial
    case increment
    case decrement
}



class CounterBloc: Bloc<Int, CounterEvent> {
    enum Consts {
        static let initialState: Int = 0
    }
    
    override init() {
        super.init()
        
        self.on(.initial) { event, emit in
            // Emit the initial state when the bloc is initialized
            emit(Consts.initialState)
        }
        
        self.on(.increment) { event, emit in
            // Increment the current state by 1
            if let currentState = self.states.last {
                emit(currentState + 1)
            }
        }
        
        on(.decrement) { event, emit in
            // Decrease the current state by 1
            if let currentState = self.states.last {
                emit(currentState - 1)
            }
        }
    }
}
