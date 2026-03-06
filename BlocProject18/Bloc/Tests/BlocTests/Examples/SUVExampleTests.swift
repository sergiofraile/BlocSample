// SUVExampleTests.swift
//
// Faithful inline replica of the SUV example from BlocProject18/Examples/SUVs.
//
// SUVBloc is the most architecturally complete example in the project:
//   - Protocol-based repository injection (SUVRepositoryProtocol)
//   - Complex async state machine (initial → authenticating → authenticated
//     → loadingInstances → loaded)
//   - Separate error cases for auth failures vs. operational failures
//
// These tests use a zero-delay mock repository, so the async state
// transitions complete after a single Task.yield() — no real waiting needed.

import Testing
import Combine
@testable import Bloc

// MARK: - Domain types (mirrors SUVs/Models)

private struct User: Equatable {
    let userName: String
    let token: String
}

private struct Instance: Equatable, Identifiable {
    let id: String
    let state: String
}

private enum AuthError: Error, Equatable {
    case invalidCredentials
    case serverError
}

// MARK: - State machine (mirrors SUVState)

private enum SUVState: BlocState {
    case initial
    case authenticating
    case authenticated(user: User)
    case loadingInstances(user: User)
    case loaded(user: User, instances: [Instance])
    case authError(AuthError)
    case error(AuthError)

    var currentUser: User? {
        switch self {
        case .authenticated(let u), .loadingInstances(let u), .loaded(let u, _): return u
        default: return nil
        }
    }

    var instances: [Instance]? {
        if case .loaded(_, let list) = self { return list }
        return nil
    }
}

private enum SUVEvent: BlocEvent {
    case login(username: String, password: String)
    case logout
    case fetchInstances
}

// MARK: - Repository protocol (enables mocking — mirrors SUVRepositoryProtocol)

private protocol SUVRepositoryProtocol: Sendable {
    func login(username: String, password: String) async throws -> User
    func fetchInstances(for username: String, token: String) async throws -> [Instance]
}

// MARK: - Mock repository implementations

private struct SuccessRepository: SUVRepositoryProtocol {
    let user: User
    let instances: [Instance]

    func login(username: String, password: String) async throws -> User { user }
    func fetchInstances(for username: String, token: String) async throws -> [Instance] { instances }
}

private struct FailingAuthRepository: SUVRepositoryProtocol {
    func login(username: String, password: String) async throws -> User {
        throw AuthError.invalidCredentials
    }
    func fetchInstances(for username: String, token: String) async throws -> [Instance] { [] }
}

// MARK: - Inline replica of SUVBloc

@MainActor
private class SUVBloc: Bloc<SUVState, SUVEvent> {

    private let repository: any SUVRepositoryProtocol

    init(repository: any SUVRepositoryProtocol) {
        self.repository = repository
        super.init(initialState: .initial)

        on(.logout) { [weak self] _, _ in self?.emit(.initial) }
        on(.fetchInstances) { [weak self] _, _ in
            guard let self else { return }
            Task { await self.handleFetchInstances() }
        }
    }

    override func mapEventToState(event: SUVEvent, emit: @escaping Emitter) {
        if case .login(let username, let password) = event {
            emit(.authenticating)
            Task { [weak self] in await self?.performLogin(username: username, password: password) }
        }
    }

    private func performLogin(username: String, password: String) async {
        do {
            let user = try await repository.login(username: username, password: password)
            emit(.authenticated(user: user))
            await fetchInstances(for: user)
        } catch let err as AuthError {
            addError(err)
            emit(.authError(err))
        } catch {
            addError(error)
            emit(.authError(.serverError))
        }
    }

    private func handleFetchInstances() async {
        guard let user = state.currentUser else { return }
        await fetchInstances(for: user)
    }

    private func fetchInstances(for user: User) async {
        emit(.loadingInstances(user: user))
        do {
            let list = try await repository.fetchInstances(for: user.userName, token: user.token)
            emit(.loaded(user: user, instances: list))
        } catch let err as AuthError {
            addError(err)
            emit(.error(err))
        } catch {
            addError(error)
            emit(.error(.serverError))
        }
    }
}

// MARK: - Tests

@MainActor
struct SUVExampleTests {

    private let mockUser = User(userName: "test.user", token: "tok-abc")
    private let mockInstances = [
        Instance(id: "suv-001", state: "running"),
        Instance(id: "suv-002", state: "stopped"),
    ]

    private func successRepo() -> any SUVRepositoryProtocol {
        SuccessRepository(user: mockUser, instances: mockInstances)
    }

    @Test("SUVBloc starts in initial state")
    func initialStateIsInitial() {
        let bloc = SUVBloc(repository: successRepo())
        if case .initial = bloc.state { } else { Issue.record("Expected .initial") }
    }

    @Test("Successful login transitions: initial → authenticating → authenticated → loadingInstances → loaded")
    func loginSuccessFollowedByInstanceFetch() async throws {
        let bloc = SUVBloc(repository: successRepo())

        bloc.send(.login(username: "test.user", password: "pw"))
        if case .authenticating = bloc.state { } else { Issue.record("Expected .authenticating synchronously") }

        try await Task.sleep(for: .milliseconds(20))

        if case .loaded(let user, let instances) = bloc.state {
            #expect(user == mockUser)
            #expect(instances == mockInstances)
        } else {
            Issue.record("Expected .loaded after login Tasks complete — got \(bloc.state)")
        }
    }

    @Test("Login failure emits .authError and publishes on errorsPublisher")
    func loginFailureEmitsAuthError() async throws {
        let bloc = SUVBloc(repository: FailingAuthRepository())
        var errors: [Error] = []
        var cancellables = Set<AnyCancellable>()
        bloc.errorsPublisher.sink { errors.append($0) }.store(in: &cancellables)

        bloc.send(.login(username: "bad.user", password: "wrong"))
        try await Task.sleep(for: .milliseconds(20))

        if case .authError(let err) = bloc.state {
            #expect(err == .invalidCredentials)
        } else {
            Issue.record("Expected .authError — got \(bloc.state)")
        }
        #expect(errors.count == 1)
    }

    @Test("logout resets state back to initial")
    func logoutResetsToInitial() async throws {
        let bloc = SUVBloc(repository: successRepo())

        bloc.send(.login(username: "test.user", password: "pw"))
        try await Task.sleep(for: .milliseconds(20))

        bloc.send(.logout)
        if case .initial = bloc.state { } else { Issue.record("Expected .initial after logout") }
    }

    @Test("fetchInstances triggers loadingInstances → loaded when user is authenticated")
    func fetchInstancesWhileAuthenticated() async throws {
        let bloc = SUVBloc(repository: successRepo())

        bloc.send(.login(username: "test.user", password: "pw"))
        try await Task.sleep(for: .milliseconds(20))

        bloc.send(.fetchInstances)
        try await Task.sleep(for: .milliseconds(20))

        if case .loaded(_, let instances) = bloc.state {
            #expect(instances.count == mockInstances.count)
        } else {
            Issue.record("Expected .loaded after fetchInstances")
        }
    }
}
