//
//  KeychainItemTests.swift
//  HeroesTests
//
//  Created by Marcos Curvello on 02/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import XCTest
@testable import Heroes

class KeychainItemTests: XCTestCase {

    @KeychainItem(account: "testKey") private var testKey
    
    override func setUp() {
        let uuid = UUID()
        testKey = uuid.uuidString
    }

    func testKeychainItemNotNil() {
        XCTAssertNotNil(testKey)
    }
    
    func testKeychainItemAddKey() {
        let key = UUID()
        testKey = key.uuidString
        
        XCTAssertEqual(key.uuidString, testKey)
    }
    
    func testKeychainItemDeleteKey() {
        testKey = nil
        XCTAssertNil(testKey)
    }
    
    func testKeychainItemAddNewKey() {
        let key = UUID()
        testKey = key.uuidString
        XCTAssertEqual(key.uuidString, testKey)
        
        let newKey = "6031fa35-ff79-41d8-bd1f-5952ee899082"
        testKey = newKey
        XCTAssertEqual(testKey, newKey)
    }
    
}
