//
//  FormulaOneView.swift
//  BlocProject
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Bloc
import SwiftUI

struct FormulaOneView: View {
    
    let formulaOneBloc: FormulaOneBloc = try! (BlocRegistry.bloc(for: FormulaOneState.self, event: FormulaOneEvent.self) as! FormulaOneBloc)
    
    @State var formulaOneState: FormulaOneState = .initial
    var body: some View {
        VStack(spacing: 20) {

            if formulaOneState == .initial {
                Text("This only appears in the initial state")
                    .font(.largeTitle)
                    .bold()
                    .padding()
            }
            
            switch formulaOneState {
            case .initial:
                
                Button(action: {
                    formulaOneBloc.perform(event: .loadChampionship)
                }) {
                    Text("Tap to load the Formula 1 Driver's Championship")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            case .loading:
                ProgressView("🏎️ Loading drivers championship...")
                    .progressViewStyle(CircularProgressViewStyle())
            case .loaded(let drivers):
                buildDriversList(drivers: drivers)
                    .padding()
            case .error(let error):
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Driver's Championship")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        // TODO: Avoid state mapping this way and use a BlocBuilder/BlocConsumer instead
        .onReceive(formulaOneBloc.states) { newState in
            formulaOneState = newState
        }
    }
    
    @ViewBuilder
    func buildDriversList(drivers: [DriverChampionship]) -> some View {
        List(drivers) { driver in
            HStack {
                // Driver Number
                Text("#\(driver.driver.number)")
                    .font(.system(.title2, design: .monospaced))
                    .bold()
                    .foregroundColor(.blue)
                    .frame(width: 50, alignment: .leading)
                
                // Name and Team
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(driver.driver.name) \(driver.driver.surname)")
                        .font(.headline)
                    Text(driver.team.teamName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Points
                Text("Points: \(driver.points)")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            .padding(.vertical, 8)
        }.toolbar {
            Button(action: {
                formulaOneBloc.perform(event: .clear)
            }) {
                Text("🗑️")
            }
        }
    }
}

#Preview {
    FormulaOneView()
}
