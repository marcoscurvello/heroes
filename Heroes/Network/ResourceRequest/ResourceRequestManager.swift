//
//  ResourceRequestsManager.swift
//  Heroes
//
//  Created by Marcos Curvello on 22/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

class ResourceRequestManager {
    
    let server: Server!
    var resource: DisplayableResource?
    
    var comicRequest: ResourceRequest<Comic>?
    var comicRequestLoader: RequestLoader<ResourceRequest<Comic>>!
    
    init(server: Server) {
        self.server = server
    }
    
    func request(comic resource: DisplayableResource, completion: @escaping (Result<Comic, UserFriendlyError>) -> Void) {
        let identifier = String(resource.id)
        
        comicRequest = try? server.resourceComicRequest(id: identifier)
        comicRequestLoader = RequestLoader(request: comicRequest!)
        comicRequestLoader.load(data: []) { result in
            switch result {
                case .success(let response): completion(.success(response.data.results.first!))
                case .failure(let error): completion(.failure(.userFriendlyError(error)))
            }
        }
    }
    
}
