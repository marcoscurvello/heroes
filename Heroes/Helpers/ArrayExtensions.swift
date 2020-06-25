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

extension Array where Element == Url {
    func validComicUrl() -> Url? {
        self.isEmpty ? nil : self.filter({ $0 == Url.inAppLink($0.url) || $0 == Url.detail($0.url)}).first
    }
}

extension Array where Element == Price {
    func digitalPurchasePrice() -> Price? {
        self.isEmpty ? nil : self.filter({ $0 == Price.digitalPurchasePrice($0.price) }).first
    }
    
    func printPrice() -> Price? {
        self.isEmpty ? nil : self.filter({ $0 == Price.printPrice($0.price) }).first
    }
}

extension Array where Element == DateContainer {
    func onSaleDate() -> DateContainer? {
        self.isEmpty ? nil : self.filter({ $0 == DateContainer.onSaleDate($0.date) }).first
    }
}
