//
//  QueryTests.swift
//  HeroesTests
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import XCTest
@testable import Heroes

class QueryTests: XCTestCase {

    func testQueryConstruction() {
        let testQuery = Query(name: "ts", value: "1953195314397341439734")
        XCTAssertEqual(testQuery.name, "ts")
        XCTAssertEqual(testQuery.value, "1953195314397341439734")
    }
    
    func testQueryToURLQueryItemConversion() {
        let testQuery = Query(name: "ts", value: "1953195314397341439734")
        XCTAssertEqual(testQuery.item(), URLQueryItem(name: "ts", value: "1953195314397341439734"))
    }
    
    func testQueryStaticTimestampCreation() {
        let testTimestamp = UUID().uuidString
        let testQuery: Query = .ts(testTimestamp)
        XCTAssertEqual(testQuery, Query(name: "ts", value: testTimestamp))
        XCTAssertEqual(testQuery.item(), URLQueryItem(name: "ts", value: testTimestamp))
    }
    
    func testQueryStaticApikeyCreation() {
        let testKey = UUID().uuidString
        let testQuery: Query = .apikey(testKey)
        XCTAssertEqual(testQuery, Query(name: "apikey", value: testKey))
        XCTAssertEqual(testQuery.item(), URLQueryItem(name: "apikey", value: testKey))
    }
    
    func testQueryStaticHashCreation() {
        let testHash = UUID().uuidString
        let testQuery: Query = .hash(testHash)
        XCTAssertEqual(testQuery, Query(name: "hash", value: testHash))
        XCTAssertEqual(testQuery.item(), URLQueryItem(name: "hash", value: testHash))
    }
    
    func testQueryStaticOffsetCreation() {
        let testOffset = "58"
        let testQuery: Query = .offset(testOffset)
        XCTAssertEqual(testQuery, Query(name: "offset", value: testOffset))
        XCTAssertEqual(testQuery.item(), URLQueryItem(name: "offset", value: testOffset))
    }
    
    func testQueryStaticNameCreation() {
        let testName = "Hello World"
        let testQuery: Query = .name(testName)
        XCTAssertEqual(testQuery, Query(name: "name", value: testName))
        XCTAssertEqual(testQuery.item(), URLQueryItem(name: "name", value: testName))
    }
    
    func testQueryStaticNameStartsWithCreation() {
        let testNameCase = "DeadPoo"
        let testQuery: Query = .nameStartsWith(testNameCase)
        XCTAssertEqual(testQuery, Query(name: "nameStartsWith", value: testNameCase))
        XCTAssertEqual(testQuery.item(), URLQueryItem(name: "nameStartsWith", value: testNameCase))
    }
    
    func testQueryStaticModifiedSinceCreation() {
        let testDate = "1969-12-31T19:00:00-0500"
        let testQuery: Query = .modifiedSince(testDate)
        XCTAssertEqual(testQuery, Query(name: "modifiedSince", value: testDate))
        XCTAssertEqual(testQuery.item(), URLQueryItem(name: "modifiedSince", value: testDate))
    }
    
    func testQueryArrayConversionToURLQueryItemArray() {
        let emptyQueryItems: [Query] = []
        XCTAssertNil(emptyQueryItems.toItems())
        
        let queryItems: [Query] = [.apikey("1953195314397341439734"), .modifiedSince("1969-12-31T19:00:00-0500")]
        let urlQueryItems = queryItems.toItems()
        
        XCTAssertNotNil(urlQueryItems)
        XCTAssertEqual(urlQueryItems?.last, URLQueryItem(name: "modifiedSince", value: "1969-12-31T19:00:00-0500"))
    }

}
