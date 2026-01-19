//
//  CounterBloc.swift
//  BlocProject
//
//  Created by Sergio Fraile on 16/06/2025.
//

import Bloc

@MainActor
class CounterBloc: Bloc<Int, CounterEvent> {
    enum Consts {
        static let initialState: Int = 0
    }
    
    private static let blocName = "CounterBloc"
    private static let example = "Counter"
    
    override init(initialState: Int = Consts.initialState) {
        super.init(initialState: initialState)
        
        BlocLogger.logInit(Self.blocName, example: Self.example, initialState: initialState)
        
        self.on(.increment) { [weak self] event, emit in
            guard let self else { return }
            BlocLogger.logEvent(event, blocName: Self.blocName, example: Self.example)
            let newState = self.state + 1
            emit(newState)
            BlocLogger.logState(newState, blocName: Self.blocName, example: Self.example)
        }
        
        self.on(.decrement) { [weak self] event, emit in
            guard let self else { return }
            BlocLogger.logEvent(event, blocName: Self.blocName, example: Self.example)
            let newState = self.state - 1
            emit(newState)
            BlocLogger.logState(newState, blocName: Self.blocName, example: Self.example)
        }
        
        self.on(.reset) { event, emit in
            BlocLogger.logEvent(event, blocName: Self.blocName, example: Self.example)
            emit(Consts.initialState)
            BlocLogger.logState(Consts.initialState, blocName: Self.blocName, example: Self.example)
        }
    }
}
