//
//  BlocBuilder.swift
//  Bloc
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Combine
import SwiftUI

struct BlocBuilder<S: BlocState, E: BlocEvent>: View {
    let viewBlock: (CurrentValueSubject<S, Never>, Bloc<S,E>) -> AnyView
    let bloc: Bloc<S,E>

    init(viewBlock: @escaping (CurrentValueSubject<S, Never>, Bloc<S,E>) -> AnyView) throws {
        self.viewBlock = viewBlock
        self.bloc = try BlocRegistry.bloc(for: S.self, event: E.self) as! Bloc<S, E>
    }
    
    var body: some View {
        viewBlock(bloc.states, bloc)
    }
}
