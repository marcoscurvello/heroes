//
//  ServerTests.swift
//  HeroesTests
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import XCTest
@testable import Heroes

class ServerTests: XCTestCase {
    
    func testServerDefaultBaseURL() {
        let localTestServer = Server()
        XCTAssertEqual(localTestServer.baseURL, URL(string: "https://gateway.marvel.com"))
    }
    
    func testServerDefaultAuthenticationStatus() {
        let localTestServer = Server()
        if localTestServer.authenticated {
            localTestServer.invalidateCredentials()
        }
        XCTAssertFalse(localTestServer.authenticated)
    }
    
    func testServerCharacterRequestCreationWithoutAuthentication() throws {
        let localTestServer = Server()
        if localTestServer.authenticated {
            localTestServer.invalidateCredentials()
        }
        XCTAssertThrowsError(try localTestServer.authenticatedCharacterRequest()) { error in
            XCTAssertEqual(error as! Server.ServerError, Server.ServerError.Unauthenticated("Attempting to authenticate request without a valid Auth instance."))
        }
    }
    
    func testServerAuthenticate() throws {
        let testServerKeys = ServerKeysFromDisk(private: "2543c3ff5796cc4f4d4862549f24316a", public: "2543c3ff5796cc4f4d4862549f24316a")
        let localTestServer = Server()
        localTestServer.authenticate(keys: testServerKeys)
        XCTAssertTrue(localTestServer.authenticated)
    }
    
    func testServerCharacterRequestCreationWithAuthentication() throws {
        let localTestServer = Server()
        let testServerKeys = ServerKeysFromDisk(private: "2543c3ff5796cc4f4d4862549f24316a", public: "2543c3ff5796cc4f4d4862549f24316a")
        localTestServer.authenticate(keys: testServerKeys)

        let testCharactersRequest = try localTestServer.authenticatedCharacterRequest()
        XCTAssertNotNil(testCharactersRequest.auth)
    }
    
}
