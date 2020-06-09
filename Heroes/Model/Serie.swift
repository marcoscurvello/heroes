//
//  Serie.swift
//  Heroes
//
//  Created by Marcos Curvello on 07/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct Serie: Decodable {
    let id: Int
    let title: String
    let description: String?
    let resourceURI: String?
    let urls: [Url]?
    let startYear: Int?
    let endYear: Int?
    let rating: String?
    let modified: String?
    let thumbnail: Image?
    let comics: ResourceList?
    let stories: ResourceList?
    let events: ResourceList?
    let characters: ResourceList?
    let creators: ResourceList?
    let next: Resource?
    let previous: Resource?
}

extension Serie: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
    static func == (lhs: Serie, rhs: Serie) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}

extension Serie: Displayable {
    func convert(type: Serie) -> DisplayableResource {
        DisplayableResource(type: .serie, id: id, title: title, description: description, thumbnail: thumbnail)
    }
}
