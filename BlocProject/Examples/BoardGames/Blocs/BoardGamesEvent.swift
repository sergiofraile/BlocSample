//
//  BoardGamesEvent.swift
//  BlocProject
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Bloc

enum BoardGamesEvent: BlocEvent {
    case clearGames
    case loadGames(userId: String)
}
