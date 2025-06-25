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
                CounterBloc(initialState: CounterBloc.Consts.initialState)
            ]){
                NavigationSplitView {
                    ForEach(Examples.allCases, id: \.self) { example in
                        NavigationLink(example.name, value: example)
                    }
//                    List(Examples, id: \.self, selection: $selection) { example in
//                        NavigationLink(example.name, value: example)
//                    }
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
