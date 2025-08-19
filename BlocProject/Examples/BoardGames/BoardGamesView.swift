//
//  BoardGamesView.swift
//  BlocProject
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Bloc
import SwiftUI

struct BoardGamesView: View {
    
    let boardGamesBloc: BoardGamesBloc = try! (BlocRegistry.bloc(for: BoardGamesState.self, event: BoardGamesEvent.self) as! BoardGamesBloc)
    
    @State var boardGamesState: BoardGamesState = .initial
    var body: some View {
        VStack(spacing: 20) {

            if boardGamesState == .initial {
                Text("This only appears in the initial state")
                    .font(.largeTitle)
                    .bold()
                    .padding()
            }
            
            switch boardGamesState {
            case .initial:
//                Text("Initial state: Waiting for events...")
//                    .foregroundColor(.gray)
//                    .onAppear() {
//                        boardGamesBloc.perform(event: .loadGames)
//                    }
                
                Button(action: {
                    boardGamesBloc.perform(event: .loadGames(userId: "fray88"))
                }) {
                    Text("Tap to Load Board Games")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            case .loading:
                ProgressView("Loading board games...")
                    .progressViewStyle(CircularProgressViewStyle())
            case .loaded(let boardGames):
                buildGamesList(boardGames: boardGames)
                    .padding()
            case .error(let error):
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        // TODO: Avoid state mapping this way and use a BlocBuilder/BlocConsumer instead
        .onReceive(boardGamesBloc.states) { newState in
            boardGamesState = newState
        }
    }
    
    @ViewBuilder
    func buildGamesList(boardGames: [BoardGameModel]) -> some View {
        List(boardGames) { game in
            Text(game.name)
                .font(.headline)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
    } 
}

#Preview {
    BoardGamesView()
}
