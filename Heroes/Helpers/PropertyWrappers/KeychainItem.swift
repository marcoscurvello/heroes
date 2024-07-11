//
//  KeychainItem.swift
//  Heroes
//
//  Created by Marcos Curvello on 02/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation
import Security

public enum KeychainError: Error {
    case invalidData
    case keychainError(status: OSStatus)
}

private func throwIfNotZero(_ status: OSStatus) throws {
    guard status != 0 else { return }
    throw KeychainError.keychainError(status: status)
}

@propertyWrapper
final public class KeychainItem {
    private let account: String
    
    public init(account: String) {
        self.account = account
    }
    
    private var baseDictionary: [String:AnyObject] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account as AnyObject
        ]
    }
    
    private var query: [String:AnyObject] {
        return baseDictionary.adding(key: kSecMatchLimit as String, value: kSecMatchLimitOne)
    }
    
    public var wrappedValue: String? {
        get {
            try! read()
        }
        set {
            if let v = newValue {
                if try! read() == nil {
                    try! add(v)
                } else {
                    try! update(v)
                }
            } else {
                try! delete()
            }
        }
    }
    
    private func delete() throws {
        let status = SecItemDelete(baseDictionary as CFDictionary)
        guard status != errSecItemNotFound else { return }
        try throwIfNotZero(status)
    }
    
    private func read() throws -> String? {
        let query = self.query.adding(key: kSecReturnData as String, value: true as AnyObject)
        var result: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status != errSecItemNotFound else { return nil }
        try throwIfNotZero(status)
        guard let data = result as? Data, let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        return string
    }
    
    private func update(_ secret: String) throws {
        let dictionary: [String:AnyObject] = [
            kSecValueData as String: secret.data(using: String.Encoding.utf8)! as AnyObject
        ]
        try throwIfNotZero(SecItemUpdate(baseDictionary as CFDictionary, dictionary as CFDictionary))
    }
    
    private func add(_ secret: String) throws {
        let dictionary = baseDictionary.adding(key: kSecValueData as String, value: secret.data(using: .utf8)! as AnyObject)
        try throwIfNotZero(SecItemAdd(dictionary as CFDictionary, nil))
    }
}
