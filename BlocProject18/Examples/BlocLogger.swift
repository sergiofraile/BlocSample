//
//  BlocLogger.swift
//  BlocProject18
//
//  Created by Cursor on 19/01/2026.
//

import Foundation

#if DEBUG
import Pulse

/// A logger utility for Bloc events and state changes using Pulse.
///
/// This logger uses the "bloc" label to categorize all Bloc-related logs,
/// making it easy to filter and inspect Bloc activity in the Pulse console.
///
/// ## Usage
///
/// ```swift
/// // Log an event
/// BlocLogger.logEvent(.increment, blocName: "CounterBloc", example: "Counter")
///
/// // Log a state change
/// BlocLogger.logState(newCount, blocName: "CounterBloc", example: "Counter")
///
/// // Log an error
/// BlocLogger.logError(error, blocName: "FormulaOneBloc", example: "FormulaOne", context: "Loading championship")
/// ```
enum BlocLogger {
    
    /// The label used for all Bloc logs in Pulse
    private static let label = "bloc"
    
    // MARK: - Event Logging
    
    /// Logs a Bloc event being received.
    ///
    /// - Parameters:
    ///   - event: The event that was received
    ///   - blocName: The name of the Bloc processing the event
    ///   - example: The name of the example/screen where this Bloc is used
    static func logEvent<E>(_ event: E, blocName: String, example: String) {
        LoggerStore.shared.storeMessage(
            label: label,
            level: .debug,
            message: "[\(example)] 📨 \(blocName) received: \(event)",
            metadata: [
                "example": .string(example),
                "blocName": .string(blocName),
                "eventType": .string(String(describing: type(of: event))),
                "event": .string(String(describing: event))
            ]
        )
    }
    
    // MARK: - State Logging
    
    /// Logs a Bloc state emission.
    ///
    /// - Parameters:
    ///   - state: The new state being emitted
    ///   - blocName: The name of the Bloc emitting the state
    ///   - example: The name of the example/screen where this Bloc is used
    static func logState<S>(_ state: S, blocName: String, example: String) {
        LoggerStore.shared.storeMessage(
            label: label,
            level: .info,
            message: "[\(example)] 🔄 \(blocName) → \(state)",
            metadata: [
                "example": .string(example),
                "blocName": .string(blocName),
                "stateType": .string(String(describing: type(of: state))),
                "state": .string(String(describing: state))
            ]
        )
    }
    
    /// Logs a Bloc state transition (from old state to new state).
    ///
    /// - Parameters:
    ///   - from: The previous state
    ///   - to: The new state being emitted
    ///   - blocName: The name of the Bloc emitting the state
    ///   - example: The name of the example/screen where this Bloc is used
    static func logStateTransition<S>(from: S, to: S, blocName: String, example: String) {
        LoggerStore.shared.storeMessage(
            label: label,
            level: .info,
            message: "[\(example)] 🔄 \(blocName): \(from) → \(to)",
            metadata: [
                "example": .string(example),
                "blocName": .string(blocName),
                "stateType": .string(String(describing: type(of: to))),
                "fromState": .string(String(describing: from)),
                "toState": .string(String(describing: to))
            ]
        )
    }
    
    // MARK: - Error Logging
    
    /// Logs an error that occurred in a Bloc.
    ///
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - blocName: The name of the Bloc where the error occurred
    ///   - example: The name of the example/screen where this Bloc is used
    ///   - context: Optional context describing what was happening when the error occurred
    static func logError(_ error: Error, blocName: String, example: String, context: String? = nil) {
        var metadata: [String: LoggerStore.MetadataValue] = [
            "example": .string(example),
            "blocName": .string(blocName),
            "errorType": .string(String(describing: type(of: error))),
            "errorDescription": .string(error.localizedDescription)
        ]
        
        if let context = context {
            metadata["context"] = .string(context)
        }
        
        let contextInfo = context != nil ? " (\(context!))" : ""
        let message = "[\(example)] ❌ \(blocName)\(contextInfo): \(error.localizedDescription)"
        
        LoggerStore.shared.storeMessage(
            label: label,
            level: .error,
            message: message,
            metadata: metadata
        )
    }
    
    // MARK: - Lifecycle Logging
    
    /// Logs when a Bloc is initialized.
    ///
    /// - Parameters:
    ///   - blocName: The name of the Bloc being initialized
    ///   - example: The name of the example/screen where this Bloc is used
    ///   - initialState: The initial state of the Bloc
    static func logInit<S>(_ blocName: String, example: String, initialState: S) {
        LoggerStore.shared.storeMessage(
            label: label,
            level: .notice,
            message: "[\(example)] 🚀 \(blocName) initialized",
            metadata: [
                "example": .string(example),
                "blocName": .string(blocName),
                "initialState": .string(String(describing: initialState))
            ]
        )
    }
}

#else

/// No-op implementation for release builds
enum BlocLogger {
    @inline(__always)
    static func logEvent<E>(_ event: E, blocName: String, example: String) {}
    
    @inline(__always)
    static func logState<S>(_ state: S, blocName: String, example: String) {}
    
    @inline(__always)
    static func logStateTransition<S>(from: S, to: S, blocName: String, example: String) {}
    
    @inline(__always)
    static func logError(_ error: Error, blocName: String, example: String, context: String? = nil) {}
    
    @inline(__always)
    static func logInit<S>(_ blocName: String, example: String, initialState: S) {}
}

#endif
