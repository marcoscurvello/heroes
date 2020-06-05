//
//  HashedItem.swift
//  Heroes
//
//  Created by Marcos Curvello on 02/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation
import CryptoKit

@propertyWrapper
public struct HashedItem<Value: StringProtocol> {
    private var storage: Value?
    
    public init() { storage = nil }
    
    public var wrappedValue: Value? {
        get {
            guard let value = storage else {
                return nil
            }
            return value
        }
        set {
            if let v = newValue {
                storage = hashedValue(v)
            } else {
                storage = nil
            }
        }
    }
    
    private func hashedValue(_ value: Value) -> Value {
        let data = value.data(using: .utf8)!
        let hashedValue = hash(data: data)
        return hashedValue as! Value
    }
    
    private func hash(data: Data) -> String {
        let digest = Insecure.MD5.hash(data: data)
        let hashedString = digest.map { String(format: "%02hhx", $0) }.joined()
        return hashedString
    }
    
}
