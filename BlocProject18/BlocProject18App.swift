//
//  BlocProject18App.swift
//  BlocProject18
//
//  Created by Sergio Fraile Carmena on 06/08/2025.
//

import Bloc
import SwiftUI
import Pulse
import PulseProxy
import PulseUI

@main
struct BlocProject18App: App {

    // Blocs are stored as properties so they survive body re-evaluations.
    // Declaring them inside body would create fresh instances on every render,
    // causing BlocRegistry to be replaced and all Bloc state to be lost.
    private let counterBloc    = CounterBloc()
    private let calculatorBloc = CalculatorBloc()
    private let formulaOneBloc = FormulaOneBloc()
    private let lorcanaBloc    = LorcanaBloc(networkService: LorcanaNetworkService())
    private let suvBloc        = SUVBloc()
    private let scoreBloc      = ScoreBloc()

    init() {
        BlocObserver.shared = AppBlocObserver()
#if DEBUG
        NetworkLogger.enableProxy()
#endif
    }

    var body: some Scene {
        WindowGroup {
            BlocProvider(with: [counterBloc, calculatorBloc, formulaOneBloc, lorcanaBloc, suvBloc, scoreBloc]) {
                ExamplesSplitView()
                    .frame(minWidth: 375.0, minHeight: 600.0)
            }
        }
    }
}
