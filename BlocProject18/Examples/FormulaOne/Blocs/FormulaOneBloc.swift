//
//  FormulaOneBloc.swift
//  BlocProject
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Bloc
import Foundation

class FormulaOneBloc: Bloc<FormulaOneState, FormulaOneEvent> {
    
    override init(initialState: FormulaOneState) {
        super.init(initialState: initialState)
        
        self.on(.clear) { event, emit in
            emit(.initial)
        }
        //        self.on(.loadChampionship) { event, emit in
        //            emit(.loading)
        //            Task { [weak self] in
        //                await self?.loadChampionship()
        //                emit(.loaded)
        //            }
        //        }
    }
    
    override func mapEventToState(event: FormulaOneEvent, emit: @escaping (Bloc<FormulaOneState, FormulaOneEvent>.State) -> Void) {
        if case .loadChampionship = event {
            emit(.loading)
            Task {
                await loadChampionship()
            }
        }
    }
    
    fileprivate func loadChampionship() async {
        do {
            let networkService = FormulaOneNetworkService()
            let drivers = try await networkService.fetchDriversChampionship()
            emit(.loaded(drivers))
        } catch {
            emit(.error(FormulaOneError()))
        }
    }
    
}
