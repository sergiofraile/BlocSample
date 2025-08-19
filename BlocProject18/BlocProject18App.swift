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
    
    init() {
#if DEBUG
        NetworkLogger.enableProxy()
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            // TODO: Move BlocProvider away from view as it rebuilds every time rather than persist
            BlocProvider(with: [
                CounterBloc(initialState: CounterBloc.Consts.initialState),
                FormulaOneBloc(initialState: FormulaOneState.initial),
            ]){
                ExamplesSplitView()
                    .frame(minWidth: 375.0, minHeight: 600.0)
            }
        }
    }
}
