//
//  BlocProvider.swift
//  Bloc
//
//  Created by Sergio Fraile on 24/06/2025.
//

import SwiftUI

public struct BlocProvider<Content: View>: View {
    let content: () -> Content
    
    public init(with blocs: [any BlocBase], @ViewBuilder content: @escaping () -> Content) {
        _ = BlocRegistry(with: blocs)
        self.content = content
    }
    
    public var body: some View {
        content()
    }
} 
