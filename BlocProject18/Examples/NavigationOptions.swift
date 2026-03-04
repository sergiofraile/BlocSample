//
//  NavigationOptions.swift
//  BlocProject
//
//  Created by Sergio Fraile Carmena on 02/07/2025.
//

import SwiftUI

enum NavigationOptions: Equatable, Hashable, Identifiable {
    
    case counter, formulaOne, suvs, lorcana, calculator
    
    static let mainPages: [NavigationOptions] = [.counter, .calculator, .formulaOne, .suvs, .lorcana]
    
    var id: String {
        switch self {
        case .counter:    return "counter"
        case .formulaOne: return "formula one"
        case .suvs:       return "suvs"
        case .lorcana:    return "lorcana"
        case .calculator: return "calculator"
        }
    }
    
    var name: LocalizedStringResource {
        switch self {
        case .counter:
            return LocalizedStringResource("Counter", comment: "Title for the Counter example, shown in the sidebar.")
        case .formulaOne:
            return LocalizedStringResource("Formula One", comment: "Title for the F1 example, shown in the sidebar.")
        case .suvs:
            return LocalizedStringResource("SUVs", comment: "Title for the SUVs example, shown in the sidebar.")
        case .lorcana:
            return LocalizedStringResource("Lorcana", comment: "Title for the Lorcana TCG example, shown in the sidebar.")
        case .calculator:
            return LocalizedStringResource("Calculator", comment: "Title for the Calculator lifecycle hooks example.")
        }
    }
    
    var subtitle: String {
        switch self {
        case .counter:    return "Basic state increment/decrement"
        case .formulaOne: return "API-driven driver standings"
        case .suvs:       return "Server management dashboard"
        case .lorcana:    return "Disney TCG card browser"
        case .calculator: return "Lifecycle hooks: onEvent, onChange, onTransition, onError"
        }
    }
    
    var symbolName: String {
        switch self {
        case .counter:    return "plusminus.circle.fill"
        case .formulaOne: return "flag.checkered"
        case .suvs:       return "server.rack"
        case .lorcana:    return "wand.and.stars"
        case .calculator: return "function"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .counter:
            return [Color(red: 0.4, green: 0.7, blue: 1.0), Color(red: 0.2, green: 0.5, blue: 0.9)]
        case .formulaOne:
            return [Color(red: 1.0, green: 0.3, blue: 0.3), Color(red: 0.8, green: 0.1, blue: 0.1)]
        case .suvs:
            return [Color(red: 0.2, green: 0.8, blue: 0.6), Color(red: 0.1, green: 0.6, blue: 0.5)]
        case .lorcana:
            return [Color(red: 0.6, green: 0.3, blue: 0.9), Color(red: 0.4, green: 0.2, blue: 0.7)]
        case .calculator:
            return [Color(red: 1.0, green: 0.55, blue: 0.1), Color(red: 0.85, green: 0.35, blue: 0.0)]
        }
    }
    
    @MainActor @ViewBuilder func viewForPage() -> some View {
        switch self {
        case .counter:    CounterView()
        case .formulaOne: FormulaOneView()
        case .suvs:       SUVView()
        case .lorcana:    LorcanaView()
        case .calculator: CalculatorView()
        }
    }
}
