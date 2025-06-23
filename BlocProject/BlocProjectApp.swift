//
//  BlocProjectApp.swift
//  BlocProject
//
//  Created by Sergio Fraile on 28/04/2025.
//

import SwiftUI

@main
struct BlocProjectApp: App {
    var body: some Scene {
        WindowGroup {
            BlocProvider(with: [
                CounterBloc(initialState: CounterBloc.Consts.initialState)
            ]){
                ContentView()
            }
        }
    }
}
