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
        
    typealias Keys = (public: String, private: String)?
    
    enum ServerError: Error, Equatable {
        case Unauthenticated(String)
    }
    
    public var baseURL: URL
    public var authenticated: Bool { _auth != nil }
    
    private var _auth: Auth? = nil
    private var _credentials = Credentials()
    
    init(_ baseURL: URL = URL(string: "https://gateway.marvel.com")!) {
        self.baseURL = baseURL
        guard let keys = _credentials.keys else {
            return
        }
        self._auth = Auth(keys: keys)
    }
    
    func authenticate(keys: ServerKeysFromDisk) {
        _credentials = Credentials(keys: (public: keys.public, private: keys.private))
        _auth = Auth(keys: _credentials.keys)
    }
    
    func invalidateCredentials() {
        _credentials.keys = nil
        _auth = nil
    }
    
    private func authQueryItems() throws -> [Query] {
        guard let parameters = _auth?.parameters else {
            throw ServerError.Unauthenticated("Attempting to authenticate request without a valid Auth instance.")
        }
        return parameters
    }
    
    // MARK: - Character Requests
    
    /// CharacterRequest for Character
    /// - Parameter id: String identifier of character
    /// - Returns: Authenticated request with matching Character type
    func characterBaseRequest() throws -> CharacterRequest<Character> {
        return CharacterRequest(baseURL, path: .base, auth: try authQueryItems())
    }
    
    /// CharacterRequest for Cbaracters
    /// - Parameter id: String identifier of character
    /// - Returns: Authenticated request with matching Character type
    func characterDetailRequest(id: String) throws -> CharacterRequest<Character> {
        return CharacterRequest(baseURL, path: .detail(id), auth: try authQueryItems())
    }
    
    /// CharacterRequest for Comics
    /// - Parameter id: String identifier of character
    /// - Returns: Authenticated request with matching Comic model type
    func characterComicsRequest(id: String) throws -> CharacterRequest<Comic> {
        return CharacterRequest(baseURL, path: .comics(id), auth: try authQueryItems())
    }
    
    /// CharacterRequest for Events
    /// - Parameter id: String identifier of character
    /// - Returns: Authenticated request with matching Event model type
    func characterEventsRequest(id: String) throws -> CharacterRequest<Event> {
        return CharacterRequest(baseURL, path: .events(id), auth: try authQueryItems())
    }
    
    /// CharacterRequest for Series
    /// - Parameter id: String identifier of character
    /// - Returns: Authenticated request with matching Serie model type
    func characterSeriesRequest(id: String) throws -> CharacterRequest<Serie> {
        return CharacterRequest(baseURL, path: .series(id), auth: try authQueryItems())
    }
    
    /// CharacterRequest for Stories
    /// - Parameter id: String identifier of character
    /// - Returns: Authenticated request with matching Storie model type
    func characterStoriesRequest(id: String) throws -> CharacterRequest<Storie> {
        return CharacterRequest(baseURL, path: .stories(id), auth: try authQueryItems())
    }
    

    // MARK: - Resource Requests
    
    func resourceComicRequest(id: String) throws -> ResourceRequest<Comic> {
        return ResourceRequest(baseURL, path: .comic(id), auth: try authQueryItems())
    }
    
    func resourceSerieRequest(id: String) throws -> ResourceRequest<Serie> {
        return ResourceRequest(baseURL, path: .serie(id), auth: try authQueryItems())
    }
    
    func resourceStorieRequest(id: String) throws -> ResourceRequest<Storie> {
        return ResourceRequest(baseURL, path: .storie(id), auth: try authQueryItems())
    }
    
    func resourceEventRequest(id: String) throws -> ResourceRequest<Event> {
        return ResourceRequest(baseURL, path: .event(id), auth: try authQueryItems())
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
