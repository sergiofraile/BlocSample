//
//  SuvErrorResponse.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Foundation

/// Represents an error response from the SUV API.
public struct SuvErrorResponse: Codable, Equatable {
    /// Error message title
    public let message: String
    
    /// Detailed error description
    public let detail: String
    
    /// Trace ID for debugging
    public let traceId: String
    
    public init(message: String, detail: String, traceId: String) {
        self.message = message
        self.detail = detail
        self.traceId = traceId
    }
}
