//
//  CounterView.swift
//  BlocProject
//
//  Created by Sergio Fraile on 28/04/2025.
//

import Bloc
import SwiftUI

struct CounterView: View {
    let counterBloc = BlocRegistry.resolve(CounterBloc.self)
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Counter: \(counterBloc.state)")
                .font(.largeTitle)
                .bold()
            
            HStack(spacing: 50) {
                Button(action: {
                    counterBloc.send(.decrement)
                }) {
                    Image(systemName: "minus.circle")
                        .font(.largeTitle)
                }
                
                Button(action: {
                    counterBloc.send(.increment)
                }) {
                    Image(systemName: "plus.circle")
                        .font(.largeTitle)
                }
            }
            
            Button(action: {
                counterBloc.send(.reset)
            }) {
                Text("Reset Counter")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Counter Sample")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    CounterView()
}
