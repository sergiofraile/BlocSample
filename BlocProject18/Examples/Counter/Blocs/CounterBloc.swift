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

    override init(initialState: Int = Consts.initialState) {
        super.init(initialState: initialState)

        self.on(.increment) { [weak self] event, emit in
            guard let self else { return }
            emit(self.state + 1)
        }

        self.on(.decrement) { [weak self] event, emit in
            guard let self else { return }
            emit(self.state - 1)
        }

        self.on(.reset) { _, emit in
            emit(Consts.initialState)
        }
    }
}
