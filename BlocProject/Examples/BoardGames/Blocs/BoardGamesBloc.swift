//
//  BoardGamesBloc.swift
//  BlocProject
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Bloc

class BoardGamesBloc: Bloc<[BoardGame], BoardGamesEvent> {
    
    override init(initialState: [BoardGame]) {
        super.init(initialState: initialState)
        
        self.on(.loading) { event, emit in
            // Increment the current state by 1
            emit([])
        }
        
        self.on(.loaded([])) { event, emit in
            // Decrease the current state by 1
            emit([])
        }
        
        self.on(.error("paco")) { event, emit in
            // Reset the state to the initial value
            emit([])
        }
    }
}
