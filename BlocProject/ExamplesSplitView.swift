//
//  ExamplesSplitView.swift
//  BlocProject
//
//  Created by Sergio Fraile Carmena on 02/07/2025.
//

import SwiftUI

struct ExamplesSplitView: View {
    
    @State var selection: Examples? = nil
    @State var isConsoleViewPresenting = false
    
    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    ForEach(NavigationOptions.mainPages) { page in
                        NavigationLink(value: page) {
                            Text(page.name)
//                            Label(page.name, systemImage: page.symbolName)
                        }
                    }
                }
            }.navigationDestination(for: NavigationOptions.self) { page in
                page.viewForPage()
            }
//            List(Examples.allCases, selection: $selection) { example in
//                NavigationLink(example.name, value: example)
//            }
//            .listStyle(.sidebar)
//            .navigationTitle("Sections")
        } detail: {
//            if let selection {
//                switch selection {
//                case .counter:
//                    CounterView()
//                case .boardGames:
//                    BoardGamesView()
//                case .login:
//                    LoginView()
//                }
//            } else {
                Text("Pick an example")
//            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
//                        NavigationLink(destination: <#T##() -> View#>, label: <#T##() -> View#>)
//                        NavigationLink(destination: ConsoleView(), isActive: $isConsoleViewPresenting) {
                Button("Console Inspection", systemImage: "network") {
                        print("LOL")
//                                //                            isConsoleViewPresenting = true
                    }
//                        }
            }
        }
    }
}
