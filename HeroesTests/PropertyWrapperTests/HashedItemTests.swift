//
//  HashedItemTests.swift
//  HeroesTests
//
//  Created by Marcos Curvello on 02/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import XCTest
@testable import Heroes

class HashedItemTests: XCTestCase {
    
    var globalValue: String!
    @HashedItem private var testValue: String!

    override func setUp() {
        let timestamp = Int(Date().timeIntervalSince1970)
        let testKey = UUID()
        
        let value = "ts=\(timestamp)&apikey=\(testKey)"
        testValue = value
    }
    
    func testHashedItemNotNil() {
        XCTAssertNotNil(testValue)
    }
    
    func testHashedItemNil() {
        testValue = nil
        XCTAssertNil(testValue)
    }

}
