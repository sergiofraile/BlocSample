//
//  SUVState.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Bloc

/// Represents the different states of the SUV management flow.
///
/// The state machine progresses from initial → authenticating → authenticated,
/// then to loading → loaded for fetching instances.
enum SUVState: BlocState {
    
    /// Initial state - user has not logged in yet.
    case initial
    
    /// Authentication in progress.
    case authenticating
    
    /// User is authenticated but instances not yet loaded.
    /// - Parameter user: The authenticated user information
    case authenticated(user: SuvActiveDirectoryUser)
    
    /// Loading SUV instances for the authenticated user.
    /// - Parameter user: The authenticated user information
    case loadingInstances(user: SuvActiveDirectoryUser)
    
    /// Successfully loaded SUV instances.
    /// - Parameters:
    ///   - user: The authenticated user information
    ///   - instances: The list of SUV instances
    ///   - selectedInstance: Optional selected instance for detail view
    case loaded(
        user: SuvActiveDirectoryUser,
        instances: [SuvInstance],
        selectedInstance: SuvInstance? = nil
    )
    
    /// Extending a SUV instance.
    /// - Parameters:
    ///   - user: The authenticated user information
    ///   - instances: The current list of SUV instances
    ///   - extendingInstanceId: The ID of the instance being extended
    case extending(
        user: SuvActiveDirectoryUser,
        instances: [SuvInstance],
        extendingInstanceId: String
    )
    
    /// Error occurred during an operation.
    /// - Parameter error: The error that occurred
    case error(SuvifyError)
    
    /// Authentication error - separate to allow showing login form.
    /// - Parameter error: The authentication error
    case authError(SuvifyError)
}

// MARK: - Convenience Properties

extension SUVState {
    
    /// Returns the authenticated user if available.
    var currentUser: SuvActiveDirectoryUser? {
        switch self {
        case .authenticated(let user),
             .loadingInstances(let user),
             .loaded(let user, _, _),
             .extending(let user, _, _):
            return user
        default:
            return nil
        }
    }
    
    /// Returns the current instances if available.
    var instances: [SuvInstance]? {
        switch self {
        case .loaded(_, let instances, _),
             .extending(_, let instances, _):
            return instances
        default:
            return nil
        }
    }
    
    /// Returns true if the user is authenticated.
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    /// Returns true if currently loading.
    var isLoading: Bool {
        switch self {
        case .authenticating, .loadingInstances:
            return true
        default:
            return false
        }
    }
    
    /// Returns the selected instance if any.
    var selectedInstance: SuvInstance? {
        if case .loaded(_, _, let selected) = self {
            return selected
        }
        return nil
    }
    
    /// A short description of the state for logging purposes.
    var shortDescription: String {
        switch self {
        case .initial:
            return "initial"
        case .authenticating:
            return "authenticating"
        case .authenticated(let user):
            return "authenticated(\(user.userName))"
        case .loadingInstances(let user):
            return "loadingInstances(\(user.userName))"
        case .loaded(_, let instances, let selected):
            let selectedInfo = selected != nil ? ", selected: \(selected!.instanceId)" : ""
            return "loaded(\(instances.count) instances\(selectedInfo))"
        case .extending(_, _, let extendingId):
            return "extending(\(extendingId))"
        case .error(let error):
            return "error(\(error.localizedDescription))"
        case .authError(let error):
            return "authError(\(error.localizedDescription))"
        }
    }
}
