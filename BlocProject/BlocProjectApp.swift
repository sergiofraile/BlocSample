//
//  BlocProjectApp.swift
//  BlocProject
//
//  Created by Sergio Fraile on 28/04/2025.
//

import Bloc
import SwiftUI

@main
struct BlocProjectApp: App {
    
    @State var selection: Examples? = nil
    
    var body: some Scene {
        WindowGroup {
            BlocProvider(with: [
                CounterBloc(initialState: CounterBloc.Consts.initialState),
                BoardGamesBloc(initialState: BoardGamesState.initial),
            ]){
                NavigationSplitView {
                    List(Examples.allCases, selection: $selection) { example in
                        Button(action: {
                            selection = example
                        }) {
                            Text("View \(example.name)")
                                .fontWeight(.bold)
                        }
                    }
                    .listStyle(.sidebar)
                    .navigationTitle("Sections")
                } detail: {
                    if let selection {
                        switch selection {
                        case .counter:
                            CounterView()
                        case .boardGames:
                            BoardGamesView()
                        case .login:
                            LoginView()
                        }
                    } else {
                        Text("Pick an example")
                    }
                   
                }
            }
        }
    }
}
