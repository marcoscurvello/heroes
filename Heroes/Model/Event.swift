//
//  Event.swift
//  Heroes
//
//  Created by Marcos Curvello on 06/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct Event: Decodable {
    let id: Int
    let title: String
    let description: String?
    let resourceURI: String?
    let urls: [Url]?
    let modified: String?
    let start: String?
    let end: String?
    let thumbnail: Image?
    let comics: ResourceList?
    let stories: ResourceList?
    let series: ResourceList?
    let characters: ResourceList?
    let creators: ResourceList?
    let next: Resource?
    let previous: Resource?
}

extension Event: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}

extension Event: Displayable {
    func convert(type: Event) -> DisplayableResource {
        DisplayableResource(type: .event, id: id, title: title, description: description, thumbnail: thumbnail)
    }
}
