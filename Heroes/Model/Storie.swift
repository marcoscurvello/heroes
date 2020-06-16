//
//  Storie.swift
//  Heroes
//
//  Created by Marcos Curvello on 07/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct Storie: Decodable {
    let id: Int
    let title: String
    let description: String?
    let resourceURI: String?
    let type: String?
    let modified: String?
    let thumbnail: Image?
    let comics: ResourceList?
    let stories: ResourceList?
    let events: ResourceList?
    let characters: ResourceList?
    let creators: ResourceList?
    let originalIssue: Resource?
}

extension Storie: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
    static func == (lhs: Storie, rhs: Storie) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}

extension Storie: Displayable {
    func convert(type: Storie) -> DisplayableResource {
        DisplayableResource(type: .story, id: id, title: title, description: description, thumbnail: thumbnail)
    }
}
