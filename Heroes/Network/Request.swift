//
//  Request.swift
//  Heroes
//
//  Created by Marcos Curvello on 11/07/2024.
//  Copyright © 2024 Marcos Curvello. All rights reserved.
//

import Foundation

protocol Request {
    associatedtype RequestDataType
    associatedtype ResponseDataType
    func composeRequest(with data: RequestDataType) throws -> URLRequest
    func parse(data: Data?) throws -> ResponseDataType
}
