//
//  MockSUVRepository.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Foundation

/// Mock implementation of the SUV repository for testing and previews.
///
/// This mock can be configured to return specific responses or errors
/// for testing different scenarios.
///
/// ## Usage
///
/// ```swift
/// // Create with default mock data
/// let mockRepo = MockSUVRepository()
///
/// // Configure for error testing
/// let errorRepo = MockSUVRepository()
/// errorRepo.loginError = .unauthorized(SuvErrorResponse(...))
///
/// // Use in tests
/// let bloc = SUVBloc(repository: mockRepo)
/// ```
public final class MockSUVRepository: SUVRepositoryProtocol, @unchecked Sendable {
    
    // MARK: - Configuration
    
    /// Delay to simulate network latency (in seconds)
    public var simulatedDelay: TimeInterval = 0.5
    
    /// Error to throw on login (nil for success)
    public var loginError: SuvifyError?
    
    /// Error to throw on fetch instances (nil for success)
    public var fetchError: SuvifyError?
    
    /// Error to throw on extend instance (nil for success)
    public var extendError: SuvifyError?
    
    /// Mock user to return on successful login
    public var mockUser: SuvActiveDirectoryUser = SuvActiveDirectoryUser(
        clientName: "SUVify",
        userName: "mock.user",
        timeToLive: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)),
        token: "mock-jwt-token-abc123"
    )
    
    /// Mock instances to return
    public var mockInstances: [SuvInstance] = [
        SuvInstance(
            instanceId: "suv-12345",
            wdHostname: "suv-12345.workday.com",
            wdPassword: "demo-password",
            wdCurrentState: "running",
            wdAutoStopTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(7200)),
            state: "running",
            wdDescription: "Development SUV for testing new features",
            wdAutoRestartTime: nil,
            wdAutoTerminateTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(604800))
        ),
        SuvInstance(
            instanceId: "suv-67890",
            wdHostname: "suv-67890.workday.com",
            wdPassword: "demo-password-2",
            wdCurrentState: "building",
            wdAutoStopTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)),
            state: "building",
            wdDescription: "QA SUV for regression testing",
            wdAutoRestartTime: nil,
            wdAutoTerminateTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(604800))
        ),
        SuvInstance(
            instanceId: "suv-11111",
            wdHostname: "suv-11111.workday.com",
            wdPassword: "demo-password-3",
            wdCurrentState: "stopped",
            wdAutoStopTime: nil,
            state: "stopped",
            wdDescription: "Staging SUV",
            wdAutoRestartTime: nil,
            wdAutoTerminateTime: nil
        )
    ]
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - SUVRepositoryProtocol
    
    public func login(username: String, password: String) async throws -> SuvActiveDirectoryUser {
        try await simulateDelay()
        
        if let error = loginError {
            throw error
        }
        
        // Validate inputs
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw SuvifyError.invalidCredentials(message: "Username is required")
        }
        
        guard !password.isEmpty else {
            throw SuvifyError.invalidCredentials(message: "Password is required")
        }
        
        // Return mock user with the provided username
        return SuvActiveDirectoryUser(
            clientName: mockUser.clientName,
            userName: username,
            timeToLive: mockUser.timeToLive,
            token: mockUser.token
        )
    }
    
    public func fetchInstances(for username: String, authToken: String) async throws -> [SuvInstance] {
        try await simulateDelay()
        
        if let error = fetchError {
            throw error
        }
        
        return mockInstances
    }
    
    public func fetchInstance(instanceId: String, authToken: String) async throws -> SuvInstance {
        try await simulateDelay()
        
        if let error = fetchError {
            throw error
        }
        
        guard let instance = mockInstances.first(where: { $0.instanceId == instanceId }) else {
            throw SuvifyError.userNotFound
        }
        
        return instance
    }
    
    public func extendInstance(instanceId: String, hours: Int, authToken: String) async throws -> SuvInstance {
        try await simulateDelay()
        
        if let error = extendError {
            throw error
        }
        
        guard let index = mockInstances.firstIndex(where: { $0.instanceId == instanceId }) else {
            throw SuvifyError.userNotFound
        }
        
        let existing = mockInstances[index]
        let formatter = ISO8601DateFormatter()
        let newStopTime = Date().addingTimeInterval(TimeInterval(hours * 3600))
        
        let updated = SuvInstance(
            instanceId: existing.instanceId,
            wdHostname: existing.wdHostname,
            wdPassword: existing.wdPassword,
            wdCurrentState: existing.wdCurrentState,
            wdAutoStopTime: formatter.string(from: newStopTime),
            state: existing.state,
            wdDescription: existing.wdDescription,
            wdAutoRestartTime: existing.wdAutoRestartTime,
            wdAutoTerminateTime: existing.wdAutoTerminateTime
        )
        
        mockInstances[index] = updated
        return updated
    }
    
    // MARK: - Private Helpers
    
    private func simulateDelay() async throws {
        if simulatedDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
    }
}
