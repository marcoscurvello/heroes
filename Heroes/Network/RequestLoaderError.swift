//
//  RequestLoaderError.swift
//  Heroes
//
//  Created by Marcos Curvello on 11/07/2024.
//  Copyright © 2024 Marcos Curvello. All rights reserved.
//

import Foundation

enum RequestLoaderError: Error {
    case Transport(Error)
    case ServerSide(ServerError)
    case Decoding(Error)
    case RequestCompose(Error)
    case Network(Error?)
    
    struct ServerError: Error, Equatable {
        public let statusCode: Int
        public let response: HTTPURLResponse?
        public init(statusCode: Int, response: HTTPURLResponse?) {
            self.statusCode = statusCode
            self.response = response
        }
    }
}

extension RequestLoaderError: Equatable {
    static func == (lhs: RequestLoaderError, rhs: RequestLoaderError) -> Bool {
        switch (lhs, rhs) {
        case (.Transport, .Transport):
            return true
        case (.ServerSide, .ServerSide):
            return true
        case (.Decoding, .Decoding):
            return true
        default:
            return false
        }
    }
}
