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

struct Character {
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

extension Character: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case description = "description"
        case modified = "modified"
        case resourceURI = "resourceURI"
        case urls = "urls"
        case thumbnail = "thumbnail"
        case comics = "comics"
        case stories = "stories"
        case events = "events"
        case series = "series"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        let dsc = try values.decodeIfPresent(String.self, forKey: .description)!
        description = dsc.isEmpty ? "No description availiable" : dsc
        modified = try values.decode(String.self, forKey: .modified)
        resourceURI = try values.decode(String.self, forKey: .resourceURI)
        urls = try values.decode([Url].self, forKey: .urls)
        thumbnail = try values.decode(Image.self, forKey: .thumbnail)
        comics = try values.decode(ResourceList.self, forKey: .comics)
        stories = try values.decode(ResourceList.self, forKey: .stories)
        events = try values.decode(ResourceList.self, forKey: .events)
        series = try values.decode(ResourceList.self, forKey: .series)
    }
    
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
