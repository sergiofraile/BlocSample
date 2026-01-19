//
//  SUVRepository.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Foundation

/// Concrete implementation of the SUV repository.
///
/// This repository coordinates between the Bloc and the network service,
/// handling business logic like date formatting and configuration loading.
public final class SUVRepository: SUVRepositoryProtocol, @unchecked Sendable {
    
    // MARK: - Properties
    
    private let networkService: SUVNetworkServiceProtocol
    private let clientKey: String
    private let dateFormatter: ISO8601DateFormatter
    
    // MARK: - Initialization
    
    /// Creates a new SUV repository.
    ///
    /// - Parameters:
    ///   - networkService: The network service to use for API calls
    ///   - clientKey: The API client key (defaults to loading from Suvify.plist)
    public init(
        networkService: SUVNetworkServiceProtocol = SUVNetworkService(),
        clientKey: String? = nil
    ) {
        self.networkService = networkService
        self.clientKey = clientKey ?? Self.loadClientKey()
        
        self.dateFormatter = ISO8601DateFormatter()
        self.dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }
    
    // MARK: - SUVRepositoryProtocol
    
    public func login(username: String, password: String) async throws -> SuvActiveDirectoryUser {
        // Validate inputs
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw SuvifyError.invalidCredentials(message: "Username is required")
        }
        
        guard !password.isEmpty else {
            throw SuvifyError.invalidCredentials(message: "Password is required")
        }
        
        return try await networkService.login(
            username: username,
            password: password,
            clientKey: clientKey
        )
    }
    
    public func fetchInstances(for username: String, authToken: String) async throws -> [SuvInstance] {
        return try await networkService.fetchInstances(for: username, authToken: authToken)
    }
    
    public func fetchInstance(instanceId: String, authToken: String) async throws -> SuvInstance {
        return try await networkService.fetchInstance(instanceId: instanceId, authToken: authToken)
    }
    
    public func extendInstance(instanceId: String, hours: Int, authToken: String) async throws -> SuvInstance {
        // Calculate new stop time
        let newStopTime = Date().addingTimeInterval(TimeInterval(hours * 3600))
        let formattedTime = dateFormatter.string(from: newStopTime)
        
        return try await networkService.extendInstance(
            instanceId: instanceId,
            newStopTime: formattedTime,
            authToken: authToken
        )
    }
    
    // MARK: - Private Helpers
    
    /// Loads the client key from Suvify.plist configuration.
    ///
    /// - Important: The Suvify.plist file contains sensitive API credentials and should NOT
    ///   be committed to version control. Copy `Suvify.plist.example` to `Suvify.plist` and
    ///   add your API key.
    private static func loadClientKey() -> String {
        guard let path = Bundle.main.path(forResource: "Suvify", ofType: "plist") else {
            return ""
        }
        
        guard let dict = NSDictionary(contentsOfFile: path) else {
            return ""
        }
        
        guard let key = dict["suvify_key"] as? String else {
            return ""
        }
        
        // Check for placeholder value
        if key == "YOUR_API_KEY_HERE" || key.isEmpty {
            return ""
        }
        
        return key
    }
}
