//
//  Price.swift
//  Heroes
//
//  Created by Marcos Curvello on 24/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

// MARK: - Price

struct Price: Decodable, Equatable {
    let type: String
    let price: Decimal
}

extension Price {
    static let getTypeValue: KeyPath<Price, String> = \.type
    static let getPriceValue: KeyPath<Price, Decimal> = \.price
    
    static func printPrice(_ price: Decimal) -> Price {
        Price(type: "printPrice", price: price)
    }
    
    static func digitalPurchasePrice(_ price: Decimal) -> Price {
        Price(type: "digitalPurchasePrice", price: price)
    }
}
