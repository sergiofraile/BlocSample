//
//  BlocError.swift
//  Bloc
//
//  Created by Sergio Fraile on 24/06/2025.
//

/// Errors that can occur during Bloc operations.
///
/// `BlocError` represents errors that may occur within the Bloc pattern,
/// such as during event processing or state emission.
///
/// ## Overview
///
/// Currently, `BlocError` provides a default error case. As the library
/// evolves, more specific error cases may be added.
///
/// ## Usage
///
/// You can observe errors through the ``Bloc/eventsPublisher``:
///
/// ```swift
/// bloc.eventsPublisher
///     .sink(
///         receiveCompletion: { completion in
///             if case .failure(let error) = completion {
///                 print("Bloc error: \(error)")
///             }
///         },
///         receiveValue: { event in
///             print("Event: \(event)")
///         }
///     )
///     .store(in: &cancellables)
/// ```
///
/// ## Topics
///
/// ### Error Cases
///
/// - ``defaultError``
public enum BlocError: Error {
    
    /// A generic error that occurred during Bloc operations.
    ///
    /// This is a placeholder error case. In future versions, more specific
    /// error types may be introduced for better error handling.
    case defaultError
}
