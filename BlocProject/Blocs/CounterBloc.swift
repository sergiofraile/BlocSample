//
//  CounterBloc.swift
//  BlocProject
//
//  Created by Sergio Fraile on 16/06/2025.
//

enum CounterEvent: BlocEvent {
    case increment
    case decrement
    case reset
}

class CounterBloc: Bloc<Int, CounterEvent> {
    enum Consts {
        static let initialState: Int = 0
    }
    
    override init(initialState: Int) {
        super.init(initialState: initialState)
        
        self.on(.increment) { event, emit in
            // Increment the current state by 1
            emit(self.states.value + 1)
        }
        
        self.on(.decrement) { event, emit in
            // Decrease the current state by 1
            emit(self.states.value - 1)
        }
        
        self.on(.reset) { event, emit in
            // Reset the state to the initial value
            emit(Consts.initialState)
        }
    }
}
