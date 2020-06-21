//
//  DisplayableResource.swift
//  Heroes
//
//  Created by Marcos Curvello on 07/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

protocol Displayable {
    func convert(type: Self) -> DisplayableResource
}

struct DisplayableResource {
    enum ResourceType { case comic, event, serie, story }
    let type: ResourceType
    let id: Int
    let title: String
    let description: String?
    let thumbnail: Image?
}

extension DisplayableResource: Hashable {
    static func == (lhs: DisplayableResource, rhs: DisplayableResource) -> Bool {
        lhs.type == rhs.type && lhs.id == rhs.id
    }
}
