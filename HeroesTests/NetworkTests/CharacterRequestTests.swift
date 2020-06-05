//
//  CharacterRequestTests.swift
//  HeroesTests
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import XCTest
@testable import Heroes

class CharacterRequestTests: XCTestCase {

    var baseURL: URL!
    
    override func setUp() {
        baseURL = URL(string: "https://gateway.marvel.com")!
    }
        
    func testCharactersRequestBase() throws {
        let characterBase = CharacterRequest(baseURL)
        let request = try characterBase.composeRequest()
        XCTAssertEqual(request.url?.path, "/v1/public/characters")
        
        let charactersBaseURL = URL(string: "https://gateway.marvel.com/v1/public/characters")
        XCTAssertEqual(request.url!, charactersBaseURL)
    }

    func testCharactersRequestDetail() throws {
        let characterDetail = CharacterRequest(baseURL, path: .detail("1016823"))
        let request = try characterDetail.composeRequest()
        XCTAssertEqual(request.url?.path, "/v1/public/characters/1016823")
        
        let charactersDetailURL = URL(string: "https://gateway.marvel.com/v1/public/characters/1016823")
        XCTAssertEqual(request.url!, charactersDetailURL)
    }

    func testCharactersRequestComics() throws {
        let characterComics = CharacterRequest(baseURL, path: .comics("1010846"))
        let request = try characterComics.composeRequest()
        XCTAssertEqual(request.url?.path, "/v1/public/characters/1010846/comics")
        
        let charactersDetailURL = URL(string: "https://gateway.marvel.com/v1/public/characters/1010846/comics")
        XCTAssertEqual(request.url!, charactersDetailURL)
    }
    
    func testCharactersRequestEvents() throws {
        let characterEvents = CharacterRequest(baseURL, path: .events("1011266"))
        let request = try characterEvents.composeRequest()
        XCTAssertEqual(request.url?.path, "/v1/public/characters/1011266/events")
        
        let charactersDetailURL = URL(string: "https://gateway.marvel.com/v1/public/characters/1011266/events")
        XCTAssertEqual(request.url!, charactersDetailURL)
    }
    
    func testCharactersRequestStories() throws {
        let characterStories = CharacterRequest(baseURL, path: .stories("1009146"))
        let request = try characterStories.composeRequest()
        XCTAssertEqual(request.url?.path, "/v1/public/characters/1009146/stories")
        
        let charactersDetailURL = URL(string: "https://gateway.marvel.com/v1/public/characters/1009146/stories")
        XCTAssertEqual(request.url!, charactersDetailURL)
    }
    
    
    

}
