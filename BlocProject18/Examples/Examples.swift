//
//  Examples.swift
//  BlocProject
//
//  Created by Sergio Fraile Carmena on 25/06/2025.
//

enum Examples {
    case counter, login, suvs
    
    var name: String {
        switch self {
        case .counter: return "Counter"
        case .login: return "Login"
        case .suvs: return "SUVs"
        }
    }
}

extension Examples: CaseIterable {}
extension Examples: Identifiable {
    var id: String { name }
}
