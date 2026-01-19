//
//  SUVNetworkServiceProtocol.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Foundation

/// Protocol defining the network operations for SUV management.
///
/// This protocol enables dependency injection and mocking for testing.
/// Implement this protocol to create different network backends (real, mock, etc.).
public protocol SUVNetworkServiceProtocol: Sendable {
    
    /// Authenticates a user with Active Directory credentials.
    ///
    /// - Parameters:
    ///   - username: The user's AD username
    ///   - password: The user's AD password
    ///   - clientKey: The API client key from configuration
    /// - Returns: An authenticated user with token
    /// - Throws: `SuvifyError` on failure
    func login(
        username: String,
        password: String,
        clientKey: String
    ) async throws -> SuvActiveDirectoryUser
    
    /// Fetches all SUV instances for a specific user.
    ///
    /// - Parameters:
    ///   - username: The username to fetch instances for
    ///   - authToken: The authentication token
    /// - Returns: Array of SUV instances
    /// - Throws: `SuvifyError` on failure
    func fetchInstances(
        for username: String,
        authToken: String
    ) async throws -> [SuvInstance]
    
    /// Fetches a specific SUV instance by ID.
    ///
    /// - Parameters:
    ///   - instanceId: The unique instance identifier
    ///   - authToken: The authentication token
    /// - Returns: The requested SUV instance
    /// - Throws: `SuvifyError` on failure
    func fetchInstance(
        instanceId: String,
        authToken: String
    ) async throws -> SuvInstance
    
    /// Extends the auto-stop time for a SUV instance.
    ///
    /// - Parameters:
    ///   - instanceId: The unique instance identifier
    ///   - newStopTime: The new auto-stop time as ISO8601 date string
    ///   - authToken: The authentication token
    /// - Returns: The updated SUV instance
    /// - Throws: `SuvifyError` on failure
    func extendInstance(
        instanceId: String,
        newStopTime: String,
        authToken: String
    ) async throws -> SuvInstance
}
