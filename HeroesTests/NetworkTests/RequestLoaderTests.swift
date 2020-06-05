//
//  RequestLoaderTests.swift
//  HeroesTests
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import XCTest
@testable import Heroes

class RequestLoaderTests: XCTestCase {
    
    var loader: RequestLoader<CharacterRequest>!
    let mockResponseJSON = "{\r\n    \"code\": 200,\r\n    \"status\": \"Ok\",\r\n    \"copyright\": \"2020 MARVEL\",\r\n    \"attributionText\": \"Data provided by Marvel. 2020 MARVEL\",\r\n    \"attributionHTML\": null,\r\n    \"etag\": \"3e75dea9d816b42f2fe5e6a37cccd2a04ada8568\",\r\n    \"data\": {\r\n        \"offset\": 0,\r\n        \"limit\": 20,\r\n        \"total\": 1493,\r\n        \"count\": 20,\r\n        \"results\": [{\r\n            \"id\": 1011334,\r\n            \"name\": \"3-D Man\",\r\n            \"description\": \"\",\r\n            \"modified\": \"2014-04-29T14:18:17-0400\",\r\n            \"thumbnail\": {\r\n                \"path\": \"http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784\",\r\n                \"extension\": \"jpg\"\r\n            },\r\n            \"resourceURI\": \"http://gateway.marvel.com/v1/public/characters/1011334\",\r\n            \"comics\": null,\r\n            \"series\": null,\r\n            \"stories\": null,\r\n            \"events\": null,\r\n            \"urls\": null\r\n        }]\r\n    }\r\n}\r\n".data(using: .utf8)

    override func setUp() {
        let baseURL = URL(string: "https://gateway.marvel.com")!
        let mockAuthQueryItems = [Query(name: "apikey", value: "1953195314397341439734")]
        let request = CharacterRequest(baseURL, auth: mockAuthQueryItems)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        
        loader = RequestLoader(request: request, session: session)
    }
    
    func testRequestLoaderSuccess() {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.query?.contains("1953195314397341439734"), true)
            return (HTTPURLResponse(), self.mockResponseJSON)
        }
        
        let expectation = XCTestExpectation(description: "response")
        loader.load(data: []) { result in
            do {
                
                let response = try result.get()
                
                print("Response: \(response)")
                XCTAssertEqual(response.data.results.first, Character(id: 1011334, name: "3-D Man", description: "", modified: "2014-04-29T14:18:17-0400", resourceURI: "http://gateway.marvel.com/v1/public/characters/1011334", urls: nil, thumbnail: Image(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784", extension: "jpg"), comics: nil, stories: nil, events: nil, series: nil))
                
                expectation.fulfill()
            } catch {
                XCTAssertNil(error)
            }
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testRequestLoaderServerSideError() {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.query?.contains("19531439734"), true)
            return (HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!, Data())
        }
        
        let expectation = XCTestExpectation(description: "response")
        loader.load(data: []) { result in
            
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, RequestLoaderError.ServerSide(ServerSideError(statusCode: 401, response: HTTPURLResponse())))
            default:
                XCTFail("No Error")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testRequestLoaderDecodingError() {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.query?.contains("19531439734"), true)
            return (HTTPURLResponse(), Data())
        }
        
        let expectation = XCTestExpectation(description: "response")
        loader.load(data: []) { result in
            
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .Decoding(error))
            default:
                XCTFail("No Error Available")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
}
