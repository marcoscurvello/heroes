//
//  ImageFetcherError.swift
//  Heroes
//
//  Created by Marcos Curvello on 19/07/2024.
//  Copyright © 2024 Marcos Curvello. All rights reserved.
//

import Foundation

enum ImageFetcherError: Error {
    case blacklisted
    case invalidURL
    case invalidResponse(response: URLResponse?)
    case invalidStatus(statusCode: Int)
    case invalidData
    case invalidImageData
}
