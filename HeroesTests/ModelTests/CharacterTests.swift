//
//  CharacterTests.swift
//  HeroesTests
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import XCTest
@testable import Heroes

class CharacterTests: XCTestCase {
    
    var decoder: JSONDecoder!
    
    override func setUp() {
        decoder = JSONDecoder()
    }
    
    func testCharacterFromJSONDecode() throws {
        let mockCharacterJSONData = "{\n    \"id\": 1011334,\n    \"name\": \"3-D Man\",\n    \"description\": \"\",\n    \"modified\": \"2014-04-29T14:18:17-0400\",\n    \"thumbnail\": {\n        \"path\": \"http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784\",\n        \"extension\": \"jpg\"\n    },\n    \"resourceURI\": \"http://gateway.marvel.com/v1/public/characters/1011334\",\n    \"comics\": null,\n    \"series\": null,\n    \"stories\": null,\n    \"events\": null,\n    \"urls\": null\n}".data(using: .utf8)!
        
        
        let testCharacter = try decoder.decode(Character.self, from: mockCharacterJSONData)
        XCTAssertEqual(testCharacter, Character(id: 1011334, name: "3-D Man", description: "", modified: "2014-04-29T14:18:17-0400", resourceURI: "http://gateway.marvel.com/v1/public/characters/1011334", urls: nil, thumbnail: Image(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784", extension: "jpg"), comics: nil, stories: nil, events: nil, series: nil))
    }
    
    func testCharacterHashbleProtocolConformance() {
        let testCharacter = Character(id: 1010846, name: "Aegis (Trey Rollins)", description: nil, modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, events: nil, series: nil)
        XCTAssertNotNil(testCharacter.hashValue)
    }
    
    func testCharacterEquatableConformance() {
        let testCharacter = Character(id: 1010870, name: "Ajaxis", description: nil, modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, events: nil, series: nil)
        XCTAssertEqual(testCharacter, Character(id: 1010870, name: "Ajaxis", description: nil, modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, events: nil, series: nil))
    }
    
}
