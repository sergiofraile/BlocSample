//
//  BlocBuilder.swift
//  Bloc
//
//  Created by Sergio Fraile on 24/06/2025.
//

import SwiftUI

/// A view that provides a Bloc to its content builder.
///
/// `BlocBuilder` is a convenience view that resolves a Bloc from the registry
/// and passes it to a content closure. With iOS 17+ and the `@Observable` macro,
/// this is **optional**—you can access Blocs directly in your views.
///
/// ## Overview
///
/// There are two ways to access Blocs in your views:
///
/// ### Direct Access (Recommended)
///
/// Simply resolve the Bloc as a property:
///
/// ```swift
/// struct CounterView: View {
///     let counterBloc = BlocRegistry.resolve(CounterBloc.self)
///
///     var body: some View {
///         Text("Count: \(counterBloc.state)")
///         Button("+") { counterBloc.send(.increment) }
///     }
/// }
/// ```
///
/// ### Using BlocBuilder
///
/// For cases where you prefer a builder pattern:
///
/// ```swift
/// struct CounterView: View {
///     var body: some View {
///         BlocBuilder(CounterBloc.self) { bloc in
///             Text("Count: \(bloc.state)")
///             Button("+") { bloc.send(.increment) }
///         }
///     }
/// }
/// ```
///
/// ## When to Use BlocBuilder
///
/// While direct access is simpler, `BlocBuilder` can be useful for:
///
/// - **Scoping**: Limiting where the Bloc reference is available
/// - **Clarity**: Making dependencies explicit in the view structure
/// - **Migration**: Transitioning from older patterns
///
/// ## Topics
///
/// ### Creating a Builder
///
/// - ``init(_:content:)``
/// - ``init(bloc:content:)``
public struct BlocBuilder<B: BlocBase, Content: View>: View {
    
    private let bloc: B
    private let content: (B) -> Content
    
    /// Creates a BlocBuilder that resolves a Bloc from the registry.
    ///
    /// The Bloc is resolved using ``BlocRegistry/resolve(_:)`` and passed
    /// to the content closure.
    ///
    /// ```swift
    /// BlocBuilder(CounterBloc.self) { bloc in
    ///     Text("Count: \(bloc.state)")
    ///     Button("+") { bloc.send(.increment) }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - blocType: The type of Bloc to resolve.
    ///   - content: A view builder that receives the resolved Bloc.
    public init(
        _ blocType: B.Type,
        @ViewBuilder content: @escaping (B) -> Content
    ) {
        self.bloc = BlocRegistry.resolve(B.self)
        self.content = content
    }
    
    /// Creates a BlocBuilder with an explicit Bloc instance.
    ///
    /// Use this initializer when you already have a Bloc reference or
    /// want to provide a specific instance:
    ///
    /// ```swift
    /// let myBloc = CounterBloc()
    ///
    /// BlocBuilder(bloc: myBloc) { bloc in
    ///     Text("Count: \(bloc.state)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - bloc: The Bloc instance to use.
    ///   - content: A view builder that receives the Bloc.
    public init(
        bloc: B,
        @ViewBuilder content: @escaping (B) -> Content
    ) {
        self.bloc = bloc
        self.content = content
    }
    
    public var body: some View {
        content(bloc)
    }
}
