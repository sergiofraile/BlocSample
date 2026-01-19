//
//  SUVRepositoryProtocol.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Foundation

/// Protocol defining the repository operations for SUV management.
///
/// The repository pattern provides an abstraction layer between the Bloc
/// and the network layer. This enables:
/// - Easy mocking for unit tests
/// - Swapping implementations (e.g., adding caching)
/// - Cleaner separation of concerns
public protocol SUVRepositoryProtocol: Sendable {
    
    /// Authenticates a user and returns the authenticated user object.
    ///
    /// - Parameters:
    ///   - username: The user's AD username
    ///   - password: The user's AD password
    /// - Returns: The authenticated user with token
    /// - Throws: `SuvifyError` on failure
    func login(username: String, password: String) async throws -> SuvActiveDirectoryUser
    
    /// Fetches all SUV instances for the authenticated user.
    ///
    /// - Parameters:
    ///   - username: The username to fetch instances for
    ///   - authToken: The authentication token
    /// - Returns: Array of SUV instances
    /// - Throws: `SuvifyError` on failure
    func fetchInstances(for username: String, authToken: String) async throws -> [SuvInstance]
    
    /// Fetches a specific SUV instance.
    ///
    /// - Parameters:
    ///   - instanceId: The instance to fetch
    ///   - authToken: The authentication token
    /// - Returns: The requested SUV instance
    /// - Throws: `SuvifyError` on failure
    func fetchInstance(instanceId: String, authToken: String) async throws -> SuvInstance
    
    /// Extends the auto-stop time for a SUV instance.
    ///
    /// - Parameters:
    ///   - instanceId: The instance to extend
    ///   - hours: Number of hours to extend by
    ///   - authToken: The authentication token
    /// - Returns: The updated SUV instance
    /// - Throws: `SuvifyError` on failure
    func extendInstance(instanceId: String, hours: Int, authToken: String) async throws -> SuvInstance
}
