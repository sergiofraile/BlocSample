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
        registerHandlers()
    }

    // MARK: - Event Registration

    private func registerHandlers() {
        self.on(.logout) { [weak self] _, _ in
            self?.handleLogout()
        }

        self.on(.fetchInstances) { [weak self] _, _ in
            guard let self else { return }
            Task { await self.handleFetchInstances() }
        }

        self.on(.refreshInstances) { [weak self] _, _ in
            guard let self else { return }
            Task { await self.handleFetchInstances() }
        }

        self.on(.dismissInstanceDetail) { [weak self] _, _ in
            self?.handleDismissDetail()
        }
    }

    // MARK: - Event Mapping

    override func mapEventToState(event: SUVEvent, emit: @escaping Emitter) {
        switch event {
        case .login(let username, let password):
            handleLogin(username: username, password: password)
        case .extendInstance(let instanceId, let hours):
            handleExtendInstance(instanceId: instanceId, hours: hours)
        case .selectInstance(let instance):
            handleSelectInstance(instance)
        default:
            break
        }
    }

    // MARK: - Event Handlers

    private func handleLogin(username: String, password: String) {
        emit(.authenticating)
        Task { await performLogin(username: username, password: password) }
    }

    private func performLogin(username: String, password: String) async {
        do {
            let user = try await repository.login(username: username, password: password)
            emit(.authenticated(user: user))
            await fetchInstances(for: user)
        } catch let error as SuvifyError {
            addError(error)
            emit(.authError(error))
        } catch {
            addError(error)
            emit(.authError(.somethingWentWrong))
        }
    }

    private func handleLogout() {
        emit(.initial)
    }

    private func handleFetchInstances() async {
        guard let user = state.currentUser else {
            emit(.authError(.invalidCredentials(message: "Please log in first")))
            return
        }
        await fetchInstances(for: user)
    }

    private func fetchInstances(for user: SuvActiveDirectoryUser) async {
        emit(.loadingInstances(user: user))
        do {
            let instances = try await repository.fetchInstances(
                for: user.userName,
                authToken: user.token
            )
            emit(.loaded(user: user, instances: instances))
        } catch let error as SuvifyError {
            addError(error)
            emit(.error(error))
        } catch {
            addError(error)
            emit(.error(.somethingWentWrong))
        }
    }

    private func handleExtendInstance(instanceId: String, hours: Int) {
        guard let user = state.currentUser, let instances = state.instances else { return }
        emit(.extending(user: user, instances: instances, extendingInstanceId: instanceId))
        Task { await performExtendInstance(instanceId: instanceId, hours: hours, user: user) }
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
            let instances = try await repository.fetchInstances(
                for: user.userName,
                authToken: user.token
            )
            emit(.loaded(user: user, instances: instances, selectedInstance: updatedInstance))
        } catch let error as SuvifyError {
            addError(error)
            emit(.error(error))
        } catch {
            addError(error)
            emit(.error(.somethingWentWrong))
        }
    }

    private func handleSelectInstance(_ instance: SuvInstance) {
        guard let user = state.currentUser, let instances = state.instances else { return }
        emit(.loaded(user: user, instances: instances, selectedInstance: instance))
    }

    private func handleDismissDetail() {
        guard let user = state.currentUser, let instances = state.instances else { return }
        emit(.loaded(user: user, instances: instances, selectedInstance: nil))
    }
}
