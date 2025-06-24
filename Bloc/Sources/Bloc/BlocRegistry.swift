//
//  BlocRegistry.swift
//  Bloc
//
//  Created by Sergio Fraile on 24/06/2025.
//

@MainActor
public class BlocRegistry {
    static var shared: BlocRegistry? = nil
    
    var registeredBlocs: [any BlocBase] = []
    
    @usableFromInline
    init(with blocs: [any BlocBase]) {
        self.registeredBlocs = blocs
        BlocRegistry.shared = self
    }
    
    public static func bloc<S: BlocState, E: BlocEvent>(for state: S.Type, event: E.Type) throws -> any BlocBase {
        if let bloc = BlocRegistry.shared?.registeredBlocs.first(where: {
            $0 is Bloc<S, E>
        }) {
            return bloc
        } else {
            throw fatalError("Bloc for \(S.self) and \(E.self) hasn't been provided")
        }
    }
}
