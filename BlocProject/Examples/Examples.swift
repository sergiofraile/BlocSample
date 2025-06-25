//
//  Examples.swift
//  BlocProject
//
//  Created by Sergio Fraile Carmena on 25/06/2025.
//

enum Examples {
    case counter, boardGames, login
    
    var name: String {
        switch self {
        case .counter: return "Counter"
        case .boardGames: return "Board Games"
        case .login: return "Login"
        }
    }
}

extension Examples: CaseIterable {}
