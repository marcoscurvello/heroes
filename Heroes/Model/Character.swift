//
//  Character.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation
import CoreData

protocol Persistable {
    associatedtype ManagedObject: NSManagedObject
    init(managedObject: ManagedObject)
}

struct Character: Decodable {
    let id: Int
    let name: String
    let description: String
    let modified: String?
    let resourceURI: String?
    let urls: [Url]?
    let thumbnail: Image?
    let comics: ResourceList?
    let stories: ResourceList?
    let events: ResourceList?
    let series: ResourceList?
}

extension Character: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    static func == (lhs: Character, rhs: Character) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

extension Character: Persistable {
    typealias ManagedObject = CharacterObject
    
    init(managedObject: CharacterObject) {
        id = Int(managedObject.id)
        name = managedObject.name
        description = managedObject.descriptionText
        modified = nil
        resourceURI = managedObject.resourceURI
        urls = nil
        thumbnail = Image(path: managedObject.image?.path, extension: managedObject.image?.type, data: managedObject.image?.data)
        comics = nil
        stories = nil
        events = nil
        series = nil
    }
}

extension Character {
    static let defaultDescription = "No Description Availiable"
}
