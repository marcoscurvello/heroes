//
//  ArrayExtensions.swift
//  Heroes
//
//  Created by Marcos Curvello on 18/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

extension Array where Element == CharacterObject {
    func toCharacters() -> Array<Character>? {
        self.isEmpty ? nil : self.map { Character(managedObject: $0) }
    }
}

extension Array where Element == Query {
    func toItems() -> Array<URLQueryItem>? {
        self.isEmpty ? nil : self.map { $0.item() }
    }
}

extension Array where Element: Displayable {
    func toDisplayable() -> Array<DisplayableResource> {
        self.isEmpty ? [] : self.map { $0.convert(type: $0) }
    }
}
