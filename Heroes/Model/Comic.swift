//
//  Comic.swift
//  Heroes
//
//  Created by Marcos Curvello on 06/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct Comic: Decodable {
    let id: Int
    let digitalId: Int?
    let title: String
    let issueNumber: Int?
    let variantDescription: String?
    let description: String?
    let modified: String?
    let isbn: String?
    let upc: String?
    let diamondCode: String?
    let ean: String?
    let issn: String?
    let format: String?
    let pageCount: Int?
    let textObjects: [Text]?
    let resourceURI: String?
    let urls: [Url]?
    let dates: [DateContainer]?
    let prices: [Price]?
    let thumbnail: Image?
    let images: [Image]?
    let creators: ResourceList?
    let characters: ResourceList?
}

struct Text: Decodable {
    let type: String
    let language: String
    let text: String
}

struct DateContainer: Decodable {
    let type: String
    let date: String
}

struct Price: Decodable {
    let type: String
    let price: Double
}

extension Comic: Hashable, Equatable {
    static func == (lhs: Comic, rhs: Comic) -> Bool {
        lhs.id == rhs.id && lhs.digitalId == rhs.digitalId && lhs.title == rhs.title
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(digitalId)
        hasher.combine(title)
    }
}

extension Comic: Displayable {
    func convert(type: Comic) -> DisplayableResource {
        DisplayableResource(type: .comic, id: id, title: title, description: description, thumbnail: thumbnail)
    }
}
