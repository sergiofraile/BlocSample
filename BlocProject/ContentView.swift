//
//  ContentView.swift
//  BlocProject
//
//  Created by Sergio Fraile on 28/04/2025.
//

import SwiftUI

struct ContentView: View {
    let counterBloc: CounterBloc = try! (BlocRegistry.bloc(for: Int.self, event: CounterEvent.self) as! CounterBloc)
    
    @State var count = 0
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Counter: \(count)")
                .font(.largeTitle)
                .bold()
            
            HStack(spacing: 50) {
                Button(action: {
                    counterBloc.performHandler(event: .decrement)
                }) {
                    Image(systemName: "minus.circle")
                        .font(.largeTitle)
                }
                
                Button(action: {
                    counterBloc.performHandler(event: .increment)
                }) {
                    Image(systemName: "plus.circle")
                        .font(.largeTitle)
                }
            }
            
            Button(action: {
                counterBloc.performHandler(event: .reset)
            }) {
                Text("Reset Counter")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onReceive(counterBloc.states) { newCount in
            count = newCount
        }
    }
    
}

#Preview {
    ContentView()
}
