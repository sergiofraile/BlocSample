//
//  BoardGameModel.swift
//  BlocProject
//
//  Created by Sergio Fraile on 25/06/2025.
//

import Foundation

struct BoardGameModel: Decodable, Equatable, Hashable, Identifiable {
    let id: String = UUID().uuidString
    let name: String
}
