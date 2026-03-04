//
//  AppBlocObserver.swift
//  BlocProject18
//

import Bloc
import Foundation

#if DEBUG
import Pulse

/// The application-wide Bloc observer that routes all lifecycle events to Pulse.
///
/// Set as the global observer once at app startup — every Bloc is then logged
/// automatically with no per-Bloc boilerplate:
///
/// ```swift
/// BlocObserver.shared = AppBlocObserver()
/// ```
///
/// All log entries use the `"bloc"` label in Pulse, making it easy to filter
/// Bloc activity in the console.
@MainActor
final class AppBlocObserver: BlocObserver {

    private let label = "bloc"

    override func onCreate(_ bloc: any BlocBase) {
        super.onCreate(bloc)
        LoggerStore.shared.storeMessage(
            label: label,
            level: .notice,
            message: "🚀 \(type(of: bloc)) initialized",
            metadata: [
                "blocName": .string("\(type(of: bloc))"),
                "initialState": .string("\(bloc.state)")
            ]
        )
    }

    override func onEvent(_ bloc: any BlocBase, event: Any) {
        super.onEvent(bloc, event: event)
        LoggerStore.shared.storeMessage(
            label: label,
            level: .debug,
            message: "📨 \(type(of: bloc)) received: \(event)",
            metadata: [
                "blocName": .string("\(type(of: bloc))"),
                "eventType": .string("\(type(of: event))"),
                "event": .string("\(event)")
            ]
        )
    }

    override func onChange(_ bloc: any BlocBase, change: Any) {
        super.onChange(bloc, change: change)
        LoggerStore.shared.storeMessage(
            label: label,
            level: .info,
            message: "🔄 \(type(of: bloc)): \(change)",
            metadata: [
                "blocName": .string("\(type(of: bloc))"),
                "change": .string("\(change)")
            ]
        )
    }

    override func onTransition(_ bloc: any BlocBase, transition: Any) {
        super.onTransition(bloc, transition: transition)
        LoggerStore.shared.storeMessage(
            label: label,
            level: .info,
            message: "➡️ \(type(of: bloc)): \(transition)",
            metadata: [
                "blocName": .string("\(type(of: bloc))"),
                "transition": .string("\(transition)")
            ]
        )
    }

    override func onError(_ bloc: any BlocBase, error: Error) {
        super.onError(bloc, error: error)
        LoggerStore.shared.storeMessage(
            label: label,
            level: .error,
            message: "❌ \(type(of: bloc)): \(error.localizedDescription)",
            metadata: [
                "blocName": .string("\(type(of: bloc))"),
                "errorType": .string("\(type(of: error))"),
                "errorDescription": .string(error.localizedDescription)
            ]
        )
    }
}

#else

/// No-op observer for release builds.
@MainActor
final class AppBlocObserver: BlocObserver {}

#endif
