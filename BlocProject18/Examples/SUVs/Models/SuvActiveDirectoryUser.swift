//
//  SuvActiveDirectoryUser.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Foundation

/// Represents an authenticated Active Directory user from the Narada authentication service.
///
/// This model is returned by the authentication endpoint after successful login.
public struct SuvActiveDirectoryUser: Codable, Equatable {
    /// The client application name (e.g., "SUVify")
    public let clientName: String
    
    /// The authenticated user's username
    public let userName: String
    
    /// Token expiry time in ISO8601 format with fractional seconds
    public let timeToLive: String
    
    /// The authentication token for subsequent API calls
    public let token: String
    
    public init(
        clientName: String,
        userName: String,
        timeToLive: String,
        token: String
    ) {
        self.clientName = clientName
        self.userName = userName
        self.timeToLive = timeToLive
        self.token = token
    }
}
