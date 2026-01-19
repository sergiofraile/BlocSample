//
//  FormulaOneBloc.swift
//  BlocProject
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Bloc
import Foundation

@MainActor
class FormulaOneBloc: Bloc<FormulaOneState, FormulaOneEvent> {
    
    private static let blocName = "FormulaOneBloc"
    private static let example = "Formula One"
    
    override init(initialState: FormulaOneState = .initial) {
        super.init(initialState: initialState)
        
        BlocLogger.logInit(Self.blocName, example: Self.example, initialState: initialState)
        
        self.on(.clear) { event, emit in
            BlocLogger.logEvent(event, blocName: Self.blocName, example: Self.example)
            emit(.initial)
            BlocLogger.logState(FormulaOneState.initial, blocName: Self.blocName, example: Self.example)
        }
    }
    
    override func mapEventToState(event: FormulaOneEvent, emit: @escaping (Bloc<FormulaOneState, FormulaOneEvent>.State) -> Void) {
        BlocLogger.logEvent(event, blocName: Self.blocName, example: Self.example)
        
        if case .loadChampionship = event {
            emit(.loading)
            BlocLogger.logState(FormulaOneState.loading, blocName: Self.blocName, example: Self.example)
            Task {
                await loadChampionship()
            }
        }
    }
    
    fileprivate func loadChampionship() async {
        do {
            let networkService = FormulaOneNetworkService()
            let drivers = try await networkService.fetchDriversChampionship()
            let newState = FormulaOneState.loaded(drivers)
            emit(newState)
            BlocLogger.logState(newState, blocName: Self.blocName, example: Self.example)
        } catch {
            let errorState = FormulaOneState.error(FormulaOneError())
            emit(errorState)
            BlocLogger.logError(error, blocName: Self.blocName, example: Self.example, context: "Loading championship")
            BlocLogger.logState(errorState, blocName: Self.blocName, example: Self.example)
        }
    }
}
