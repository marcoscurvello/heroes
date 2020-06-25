//
//  ComicRequest.swift
//  Heroes
//
//  Created by Marcos Curvello on 22/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct ResourceRequest<A: Decodable>: Request {
        
    typealias ResponseDataType = Response<DataContainer<A>>
    
    enum Path {
        case comic(String)
        case event(String)
        case serie(String)
        case storie(String)
        
        var string: String {
            switch self {
                case .comic(let id): return "/v1/public/comics/\(id)"
                case .serie(let id): return "/v1/public/series/\(id)"
                case .event(let id): return "/v1/public/events/\(id)"
                case .storie(let id): return "/v1/public/stories/\(id)"
            }
        }
    }
    
    let baseURL: URL
    let path: Path
    let auth: [Query]?
    
    init(_ baseURL: URL, path: Path, auth: [Query]? = nil) {
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
    
    func parse(data: Data?) throws -> Response<DataContainer<A>> {
        return try JSONDecoder().decode(ResponseDataType.self, from: data!)
    }
    
}
