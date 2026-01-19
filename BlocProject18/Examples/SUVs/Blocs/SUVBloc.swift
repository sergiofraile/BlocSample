//
//  SUVBloc.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Bloc
import Foundation

/// A Bloc that manages SUV (Single-User Version) instance management.
///
/// This Bloc demonstrates:
/// - Protocol-based dependency injection for testability
/// - Repository pattern for data access
/// - Complex state machine with multiple transitions
/// - Authentication flow integrated with data fetching
///
/// ## Architecture
///
/// ```
/// SUVBloc
///    │
///    └── SUVRepository (Protocol)
///            │
///            └── SUVNetworkService (Protocol)
/// ```
///
/// ## Usage
///
/// ```swift
/// // Create with default dependencies
/// let bloc = SUVBloc()
///
/// // Or inject mock dependencies for testing
/// let mockRepo = MockSUVRepository()
/// let testBloc = SUVBloc(repository: mockRepo)
///
/// // Send events
/// bloc.send(.login(username: "user", password: "pass"))
/// bloc.send(.fetchInstances)
/// ```
@MainActor
class SUVBloc: Bloc<SUVState, SUVEvent> {
    
    // MARK: - Logging
    
    private static let blocName = "SUVBloc"
    private static let example = "SUVs"
    
    /// Returns a safe description of an event, redacting sensitive information like passwords.
    private func safeEventDescription(_ event: SUVEvent) -> String {
        switch event {
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
    
    // MARK: - Dependencies
    
    private let repository: SUVRepositoryProtocol
    
    // MARK: - Initialization
    
    /// Creates a new SUVBloc with the specified dependencies.
    ///
    /// - Parameters:
    ///   - initialState: The starting state (defaults to `.initial`)
    ///   - repository: The repository for data operations (defaults to production implementation)
    init(
        initialState: SUVState = .initial,
        repository: SUVRepositoryProtocol = SUVRepository()
    ) {
        self.repository = repository
        super.init(initialState: initialState)
        
        // Register simple event handlers
        registerHandlers()
        
        BlocLogger.logInit(Self.blocName, example: Self.example, initialState: initialState)
    }
    
    // MARK: - Event Registration
    
    private func registerHandlers() {
        // Logout handler
        self.on(.logout) { [weak self] event, _ in
            BlocLogger.logEvent(event, blocName: Self.blocName, example: Self.example)
            self?.handleLogout()
        }
        
        // Fetch instances handler
        self.on(.fetchInstances) { [weak self] event, _ in
            guard let self else { return }
            BlocLogger.logEvent(event, blocName: Self.blocName, example: Self.example)
            Task {
                await self.handleFetchInstances()
            }
        }
        
        // Refresh instances handler
        self.on(.refreshInstances) { [weak self] event, _ in
            guard let self else { return }
            BlocLogger.logEvent(event, blocName: Self.blocName, example: Self.example)
            Task {
                await self.handleFetchInstances()
            }
        }
        
        // Dismiss detail handler
        self.on(.dismissInstanceDetail) { [weak self] event, _ in
            BlocLogger.logEvent(event, blocName: Self.blocName, example: Self.example)
            self?.handleDismissDetail()
        }
    }
    
    // MARK: - Event Mapping
    
    override func mapEventToState(event: SUVEvent, emit: @escaping Emitter) {
        // Log the event with safe description (passwords redacted)
        BlocLogger.logEvent(safeEventDescription(event), blocName: Self.blocName, example: Self.example)
        
        switch event {
        case .login(let username, let password):
            handleLogin(username: username, password: password)
            
        case .extendInstance(let instanceId, let hours):
            handleExtendInstance(instanceId: instanceId, hours: hours)
            
        case .selectInstance(let instance):
            handleSelectInstance(instance)
            
        default:
            // Other events are handled by registered handlers
            break
        }
    }
    
    // MARK: - State Emission Helper
    
    private func emitState(_ newState: SUVState) {
        BlocLogger.logStateTransition(from: state, to: newState, blocName: Self.blocName, example: Self.example)
        emit(newState)
    }
    
    // MARK: - Event Handlers
    
    private func handleLogin(username: String, password: String) {
        emitState(.authenticating)
        
        Task {
            await performLogin(username: username, password: password)
        }
    }
    
    private func performLogin(username: String, password: String) async {
        do {
            let user = try await repository.login(username: username, password: password)
            emitState(.authenticated(user: user))
            
            // Automatically fetch instances after successful login
            await fetchInstances(for: user)
        } catch let error as SuvifyError {
            BlocLogger.logError(error, blocName: Self.blocName, example: Self.example, context: "Login")
            emitState(.authError(error))
        } catch {
            BlocLogger.logError(error, blocName: Self.blocName, example: Self.example, context: "Login")
            emitState(.authError(.somethingWentWrong))
        }
    }
    
    private func handleLogout() {
        emitState(.initial)
    }
    
    private func handleFetchInstances() async {
        guard let user = state.currentUser else {
            emitState(.authError(.invalidCredentials(message: "Please log in first")))
            return
        }
        
        await fetchInstances(for: user)
    }
    
    private func fetchInstances(for user: SuvActiveDirectoryUser) async {
        emitState(.loadingInstances(user: user))
        
        do {
            let instances = try await repository.fetchInstances(
                for: user.userName,
                authToken: user.token
            )
            emitState(.loaded(user: user, instances: instances))
        } catch let error as SuvifyError {
            BlocLogger.logError(error, blocName: Self.blocName, example: Self.example, context: "Fetching instances")
            emitState(.error(error))
        } catch {
            BlocLogger.logError(error, blocName: Self.blocName, example: Self.example, context: "Fetching instances")
            emitState(.error(.somethingWentWrong))
        }
    }
    
    private func handleExtendInstance(instanceId: String, hours: Int) {
        guard let user = state.currentUser,
              let instances = state.instances else {
            return
        }
        
        emitState(.extending(user: user, instances: instances, extendingInstanceId: instanceId))
        
        Task {
            await performExtendInstance(
                instanceId: instanceId,
                hours: hours,
                user: user
            )
        }
    }
    
    private func performExtendInstance(
        instanceId: String,
        hours: Int,
        user: SuvActiveDirectoryUser
    ) async {
        do {
            let updatedInstance = try await repository.extendInstance(
                instanceId: instanceId,
                hours: hours,
                authToken: user.token
            )
            
            // Refresh instances to get updated list
            let instances = try await repository.fetchInstances(
                for: user.userName,
                authToken: user.token
            )
            
            emitState(.loaded(user: user, instances: instances, selectedInstance: updatedInstance))
        } catch let error as SuvifyError {
            BlocLogger.logError(error, blocName: Self.blocName, example: Self.example, context: "Extending instance")
            emitState(.error(error))
        } catch {
            BlocLogger.logError(error, blocName: Self.blocName, example: Self.example, context: "Extending instance")
            emitState(.error(.somethingWentWrong))
        }
    }
    
    private func handleSelectInstance(_ instance: SuvInstance) {
        guard let user = state.currentUser,
              let instances = state.instances else {
            return
        }
        
        emitState(.loaded(user: user, instances: instances, selectedInstance: instance))
    }
    
    private func handleDismissDetail() {
        guard let user = state.currentUser,
              let instances = state.instances else {
            return
        }
        
        emitState(.loaded(user: user, instances: instances, selectedInstance: nil))
    }
}
