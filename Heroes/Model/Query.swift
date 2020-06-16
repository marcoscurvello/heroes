//
//  Query.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct Query: Equatable, Hashable {
    let name: String
    let value: String
}

extension Query {
    func item() -> URLQueryItem {
        URLQueryItem(name: name, value: value)
    }
    
    static func ts(_ value: String) -> Query {
        Query(name: "ts", value: value)
    }
    
    static func apikey(_ value: String) -> Query {
        Query(name: "apikey", value: value)
    }
    
    static func hash(_ value: String) -> Query {
        Query(name: "hash", value: value)
    }
    
    static func offset(_ value: String) -> Query {
        Query(name: "offset", value: value)
    }
    
    static func name(_ value: String) -> Query {
        Query(name: "name", value: value)
    }
    
    static func nameStartsWith(_ value: String) -> Query {
        Query(name: "nameStartsWith", value: value)
    }
    
    static func modifiedSince(_ value: String) -> Query {
        Query(name: "modifiedSince", value: value)
    }
}

extension Array where Element == Query {
    func toItems() -> Array<URLQueryItem>? {
        self.isEmpty ? nil : self.map { $0.item() }
    }
}
