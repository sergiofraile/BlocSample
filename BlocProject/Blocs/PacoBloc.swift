//
//  PacoEvent.swift
//  BlocProject
//
//  Created by Sergio Fraile on 17/06/2025.
//

enum PacoEvent : BlocEvent {
    case initial
    case increment
    case decrement
}

class PacoBloc: Bloc<Int, PacoEvent> {
    enum Consts {
        static let initialState: Int = 0
    }
    
    override init() {
        super.init()
        
        self.on(.initial) { event, emit in
            // Emit the initial state when the bloc is initialized
            emit(Consts.initialState)
        }
    }
}
