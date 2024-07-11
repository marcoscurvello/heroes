//
//  DictionaryExtensions.swift
//  Heroes
//
//  Created by Marcos Curvello on 11/07/2024.
//  Copyright © 2024 Marcos Curvello. All rights reserved.
//

import Foundation

extension Dictionary {
    func adding(key: Key, value: Value) -> Dictionary {
        var copy = self
        copy[key] = value
        return copy
    }
}
