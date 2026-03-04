//
//  SUVEvent.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Bloc

/// Events that can be sent to the SUVBloc.
///
/// These events represent all user actions and system triggers
/// that can affect the SUV management state.
enum SUVEvent: BlocEvent {
    
    /// User submitted login credentials.
    /// - Parameters:
    ///   - username: The user's AD username
    ///   - password: The user's AD password
    case login(username: String, password: String)
    
    /// User requested to log out and clear the session.
    case logout
    
    /// Request to fetch all SUV instances for the current user.
    case fetchInstances
    
    /// Request to refresh the SUV instances list.
    case refreshInstances
    
    /// Request to extend a specific SUV instance.
    /// - Parameters:
    ///   - instanceId: The instance to extend
    ///   - hours: Number of hours to extend by
    case extendInstance(instanceId: String, hours: Int)
    
    /// User selected a specific instance to view details.
    /// - Parameter instance: The selected SUV instance
    case selectInstance(SuvInstance)
    
    /// User dismissed the instance detail view.
    case dismissInstanceDetail
}

extension SUVEvent: CustomStringConvertible {
    /// Returns a safe description that redacts sensitive values such as passwords.
    var description: String {
        switch self {
        case .login(let username, _):
            return "login(username: \"\(username)\", password: [REDACTED])"
        case .logout:
            return "logout"
        case .fetchInstances:
            return "fetchInstances"
        case .refreshInstances:
            return "refreshInstances"
        case .extendInstance(let instanceId, let hours):
            return "extendInstance(instanceId: \"\(instanceId)\", hours: \(hours))"
        case .selectInstance(let instance):
            return "selectInstance(\(instance.instanceId))"
        case .dismissInstanceDetail:
            return "dismissInstanceDetail"
        }
    }
}
