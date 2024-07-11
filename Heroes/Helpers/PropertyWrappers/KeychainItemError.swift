//
//  KeychainItemError.swift
//  Heroes
//
//  Created by Marcos Curvello on 11/07/2024.
//  Copyright © 2024 Marcos Curvello. All rights reserved.
//

import Foundation

public enum KeychainError: Error {
    case invalidData
    case keychainError(status: OSStatus)
}
