//
//  CharacterRequest.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct CharacterRequest<A: Decodable>: Request {
    
    typealias ResponseDataType = Response<DataContainer<A>>
    
    enum Path {
        case base
        case detail(String)
        case comics(String)
        case events(String)
        case series(String)
        case stories(String)
        var string: String {
            switch self {
            case .base: return "/v1/public/characters"
            case .detail(let id): return "/v1/public/characters/\(id)"
            case .comics(let id): return "/v1/public/characters/\(id)/comics"
            case .events(let id): return "/v1/public/characters/\(id)/events"
            case .series(let id): return "/v1/public/characters/\(id)/series"
            case .stories(let id): return "/v1/public/characters/\(id)/stories"
            }
        }
    }
    
    let baseURL: URL
    let path: Path
    let auth: [Query]?
    
    init(_ baseURL: URL, path: Path = .base, auth: [Query]? = nil) {
        self.baseURL = baseURL
        self.path = path
        self.auth = auth
    }
    
    func composeRequest(with parameters: [Query] = []) throws -> URLRequest {
        let queryItems = auth == nil ? parameters : parameters + auth!
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = path.string
        components.queryItems = queryItems.toItems()
        return URLRequest(url: components.url!)
    }
    
    func parse(data: Data?) throws -> ResponseDataType {
        return try JSONDecoder().decode(ResponseDataType.self, from: data!)
    }
    
}
