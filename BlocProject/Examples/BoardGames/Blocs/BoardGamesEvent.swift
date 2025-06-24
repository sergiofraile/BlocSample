//
//  BoardGamesEvent.swift
//  BlocProject
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Bloc

enum BoardGamesEvent: BlocEvent {
    case loading
    case loaded([BoardGame])
    case error(String)
}
