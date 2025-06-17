//
//  BlocProjectApp.swift
//  BlocProject
//
//  Created by Sergio Fraile on 28/04/2025.
//

import SwiftUI

@main
struct BlocProjectApp: App {
    
    init() {
        _ = BlocProvider(with: [
            CounterBloc()
        ])
        
        do {
            guard let counterBloc = try BlocProvider.bloc(for: Int.self, event: CounterEvent.self) as? CounterBloc
            else {
                print("LOL")
                return
            }
            
//            guard let pacoBloc = try BlocProvider.bloc(for: Int.self, event: PacoEvent.self) as? CounterBloc
//            else {
//                print("LOL")
//                return
//            }
            counterBloc.performHandler(event: .initial)
            counterBloc.performHandler(event: .increment)
            counterBloc.performHandler(event: .decrement)
        } catch {
            print("Failed to retrieve CounterBloc: \(error)")
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
