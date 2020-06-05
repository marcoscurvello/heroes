//
//  Server.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct ServerKeysFromDisk: Decodable { let `private`: String; let `public`: String }

class Server {
        
    static let shared = Server()
    public var baseURL: URL
    public var authenticated: Bool { auth != nil }
    typealias Keys = (public: String, private: String)?
    
    private var auth: Auth? = nil
    private var _credentials = Credentials()
    
    init(_ baseURL: URL = URL(string: "https://gateway.marvel.com")!) {
        self.baseURL = baseURL
        guard let keys = _credentials.keys else {
            return
        }
        self.auth = Auth(keys: keys)
    }
    
    func authenticate(keys: ServerKeysFromDisk) {
        _credentials = Credentials(keys: (public: keys.public, private: keys.private))
        auth = Auth(keys: _credentials.keys)
    }
    
    func authenticatedCharacterRequest() -> CharacterRequest {
        guard let parameters = auth?.parameters else {
            fatalError("Attempting to create authenticated request without a valid auth instance")
        }
        return CharacterRequest(baseURL, auth: parameters)
    }
    
}

extension Server {
    
    struct Auth {
        @HashedItem private var hash: String?
        var parameters: [Query]?
        var timestamp: Int { Int(Date().timeIntervalSince1970) }

        init(keys: Keys) {
            guard let ks = keys else { return }
            hash = String(format: "%D%@%@", timestamp, ks.private, ks.public)
            parameters = [.ts("\(timestamp)"), .apikey(ks.public), .hash(hash!)]
        }
    }
    
    struct Credentials {
        @KeychainItem(account: "publicKey") private var publicKey
        @KeychainItem(account: "privateKey") private var privateKey

        var keys: Keys {
            get {
                guard let pu = publicKey, let pr = privateKey else { return nil }
                return (pu, pr)
            }
            set {
                guard let pu = newValue?.public, let pr = newValue?.private else { return }
                publicKey = pu
                privateKey = pr
            }
        }
        
        init(keys: Keys? = nil) {
            guard let keys = keys, let publicKey = keys?.public, let privateKey = keys?.private else {
                return
            }
            
            self.publicKey = publicKey
            self.privateKey = privateKey
        }
    }
    
}
