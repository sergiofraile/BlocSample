//
//  SuvifyError.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Foundation

/// Errors that can occur during SUV operations.
public enum SuvifyError: Error, Equatable {
    /// Failed to build URL from components
    case invalidUrlComponents
    
    /// JSON parsing failed
    case decodingError(String)
    
    /// Server returned an error response
    case errorResponse(SuvErrorResponse)
    
    /// 401 - Token invalid or expired
    case unauthorized(SuvErrorResponse)
    
    /// User not found
    case userNotFound
    
    /// Date parsing failed
    case dateNotFound
    
    /// Generic error fallback
    case somethingWentWrong
    
    /// Network request failed
    case networkError(String)
    
    /// Invalid credentials provided
    case invalidCredentials(message: String)
}

// MARK: - LocalizedError

extension SuvifyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidUrlComponents:
            return "Failed to build URL"
        case .decodingError(let details):
            return "Failed to parse response: \(details)"
        case .errorResponse(let response):
            return response.message
        case .unauthorized(let response):
            return "Unauthorized: \(response.message)"
        case .userNotFound:
            return "User not found"
        case .dateNotFound:
            return "Invalid date format"
        case .somethingWentWrong:
            return "Something went wrong. Please try again."
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidCredentials(let message):
            return message
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .unauthorized:
            return "Please log in again."
        case .networkError:
            return "Check your internet connection and try again."
        case .invalidCredentials:
            return "Please check your username and password."
        default:
            return nil
        }
    }
}
