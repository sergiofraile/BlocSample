//
//  NavigationOptions.swift
//  BlocProject
//
//  Created by Sergio Fraile Carmena on 02/07/2025.
//

import SwiftUI

enum NavigationOptions: Equatable, Hashable, Identifiable {
    
    case counter, formulaOne, login
    
    static let mainPages: [NavigationOptions] = [.counter, .formulaOne, .login]
    
    var id: String {
        switch self {
        case .counter:
            return "counter"
        case .formulaOne:
            return "formula one"
        case .login:
            return "login"
        }
    }
    
    var name: LocalizedStringResource {
        switch self {
        case .counter:
            return LocalizedStringResource("Counter", comment: "Title for the Counter example, shown in the sidebar.")
        case .formulaOne:
            return LocalizedStringResource("Formula One", comment: "Title for the F1 example, shown in the sidebar.")
        case .login:
            return LocalizedStringResource("Login", comment: "Title for the Logins example, shown in the sidebar.")
        }
    }
    
    var symbolName: String {
        switch self {
        case .counter: "arrow.trianglehead.counterclockwise"
        case .formulaOne: "racecar"
        case .login: "rectangle.and.pencil.and.ellipsis"
        }
    }
    
    @MainActor @ViewBuilder func viewForPage() -> some View {
        switch self {
        case .counter: CounterView()
        case .formulaOne: FormulaOneView()
        case .login: LoginView()
        }
        
    }
}
