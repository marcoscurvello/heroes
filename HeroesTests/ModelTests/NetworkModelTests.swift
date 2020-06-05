//
//  NetworkModelTests.swift
//  HeroesTests
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import XCTest
@testable import Heroes

class NetworkModelTests: XCTestCase {
    
    let mockResponseJSON = "{\r\n    \"code\": 200,\r\n    \"status\": \"Ok\",\r\n    \"copyright\": \"2020 MARVEL\",\r\n    \"attributionText\": \"Data provided by Marvel. 2020 MARVEL\",\r\n    \"attributionHTML\": null,\r\n    \"etag\": \"3e75dea9d816b42f2fe5e6a37cccd2a04ada8568\",\r\n    \"data\": null\r\n}\r\n".data(using: .utf8)!
    
    var decoder: JSONDecoder!
    struct MockStructure: Decodable { }
    
    override func setUp() {
        decoder = JSONDecoder()
    }

    func testResponseNetworkModelDecode() throws {
        let testResponse = try decoder.decode(Response<MockStructure>.self, from: mockResponseJSON)
        XCTAssertNotNil(testResponse)
    }

    func testImageAbsolute() {
        let image = Image(path: "http://i.annihil.us/u/prod/marvel/i/mg/b/70/4c0035adc7d3a", extension: "jpg")
        XCTAssertEqual(image.absoluteString, "http://i.annihil.us/u/prod/marvel/i/mg/b/70/4c0035adc7d3a.jpg")
    }
    
}
