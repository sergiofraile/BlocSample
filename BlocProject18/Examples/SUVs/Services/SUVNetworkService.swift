//
//  SUVNetworkService.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Foundation

/// Concrete implementation of the SUV network service.
///
/// This service handles all network communication with the Narada authentication
/// service and the SUV instance management API.
public final class SUVNetworkService: SUVNetworkServiceProtocol, @unchecked Sendable {
    
    // MARK: - Constants
    
    private enum Constants {
        static let authBaseURL = "https://narada.ark.gowday.com"
        static let suvBaseURL = "https://suv-api.ark.gowday.com/instances"
        static let clientId = "SUVify"
        
        // Required headers per Suvify API specification
        static let contentTypeKey = "Content-Type"
        static let acceptKey = "Accept"
        static let applicationJsonValue = "application/json; charset=utf-8"
    }
    
    // MARK: - Properties
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    public init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    /// Applies canonical headers to a request per Suvify API specification.
    private func canonicalizeHeaders(for request: inout URLRequest) {
        request.setValue(Constants.applicationJsonValue, forHTTPHeaderField: Constants.contentTypeKey)
        request.setValue(Constants.applicationJsonValue, forHTTPHeaderField: Constants.acceptKey)
    }
    
    // MARK: - Authentication
    
    public func login(
        username: String,
        password: String,
        clientKey: String
    ) async throws -> SuvActiveDirectoryUser {
        guard var urlComponents = URLComponents(string: "\(Constants.authBaseURL)/token") else {
            throw SuvifyError.invalidUrlComponents
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "clientId", value: Constants.clientId),
            URLQueryItem(name: "clientKey", value: clientKey)
        ]
        
        guard let url = urlComponents.url else {
            throw SuvifyError.invalidUrlComponents
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        canonicalizeHeaders(for: &request)
        
        let body = ["username": username, "password": password]
        request.httpBody = try JSONEncoder().encode(body)
        
        return try await performRequest(request)
    }
    
    // MARK: - Instance Operations
    
    public func fetchInstances(
        for username: String,
        authToken: String
    ) async throws -> [SuvInstance] {
        let request = try buildSUVRequest(
            path: "/users/\(username)",
            method: "GET",
            authToken: authToken
        )
        
        return try await performRequest(request)
    }
    
    public func fetchInstance(
        instanceId: String,
        authToken: String
    ) async throws -> SuvInstance {
        let request = try buildSUVRequest(
            path: "/\(instanceId)",
            method: "GET",
            authToken: authToken
        )
        
        return try await performRequest(request)
    }
    
    public func extendInstance(
        instanceId: String,
        newStopTime: String,
        authToken: String
    ) async throws -> SuvInstance {
        var request = try buildSUVRequest(
            path: "/\(instanceId)",
            method: "PUT",
            authToken: authToken
        )
        
        let body = ["wdAutoStopTime": newStopTime]
        request.httpBody = try JSONEncoder().encode(body)
        
        return try await performRequest(request)
    }
    
    // MARK: - Private Helpers
    
    private func buildSUVRequest(
        path: String,
        method: String,
        authToken: String
    ) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: "\(Constants.suvBaseURL)\(path)") else {
            throw SuvifyError.invalidUrlComponents
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "clientId", value: Constants.clientId),
            URLQueryItem(name: "authtoken", value: authToken)
        ]
        
        guard let url = urlComponents.url else {
            throw SuvifyError.invalidUrlComponents
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        canonicalizeHeaders(for: &request)
        
        return request
    }
    
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SuvifyError.somethingWentWrong
        }
        
        // Handle error responses
        if httpResponse.statusCode == 401 {
            if let errorResponse = try? decoder.decode(SuvErrorResponse.self, from: data) {
                throw SuvifyError.unauthorized(errorResponse)
            }
            throw SuvifyError.unauthorized(
                SuvErrorResponse(
                    message: "Unauthorized",
                    detail: "Invalid or expired token",
                    traceId: ""
                )
            )
        }
        
        if httpResponse.statusCode == 404 {
            throw SuvifyError.userNotFound
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? decoder.decode(SuvErrorResponse.self, from: data) {
                throw SuvifyError.errorResponse(errorResponse)
            }
            throw SuvifyError.somethingWentWrong
        }
        
        // Check for redirect to maintenance page or non-JSON response
        let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") ?? ""
        if !contentType.contains("application/json") {
            // Check if redirected to a different domain (maintenance page)
            if let requestHost = request.url?.host,
               let responseHost = httpResponse.url?.host,
               requestHost != responseHost {
                // Check for maintenance page
                if let responseURL = httpResponse.url?.absoluteString,
                   responseURL.contains("maintenance") {
                    throw SuvifyError.networkError("Service is temporarily unavailable (maintenance). Please try again later.")
                }
            }
            
            throw SuvifyError.decodingError("Server returned \(contentType) instead of JSON. The service may be unavailable.")
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw SuvifyError.decodingError(error.localizedDescription)
        }
    }
}
