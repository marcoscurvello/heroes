//
//  NetworkModels.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct Response<A: Decodable>: Decodable {
    let code: Int
    let status: String?
    let message: String?
    let data: A
}

struct DataContainer<A: Decodable>: Decodable {
    let offset: Int
    let limit: Int
    let total: Int
    let count: Int
    let results: [A]
}

struct ResourceList: Decodable {
    let available: Int
    let returned: Int
    let collectionURI: String
    let items: [Resource]?
}

struct Resource: Decodable {
    let resourceURI: String?
    let name: String?
    let type: String?
}

struct Url: Decodable {
    let type: String?
    let url: String?
}

struct Image: Decodable {
    let path: String?
    let `extension`: String?
}

extension Image {
    var absoluteString: String { "\(path!).\(`extension`!)" }
}
