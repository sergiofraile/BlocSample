//
//  BlocProjectApp.swift
//  BlocProject
//
//  Created by Sergio Fraile on 28/04/2025.
//

import Bloc
import SwiftUI
import Pulse
import PulseProxy
import PulseUI

@main
struct BlocProjectApp: App {
    
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
                BoardGamesBloc(initialState: BoardGamesState.initial),
            ]){
                ExamplesSplitView()
                    .frame(minWidth: 375.0, minHeight: 600.0)
            }
        }
    }
}


