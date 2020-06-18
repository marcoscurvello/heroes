//
//  CharacterObject+CoreDataClass.swift
//  Heroes
//
//  Created by Marcos Curvello on 11/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//
//

import CoreData

public class CharacterObject: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CharacterObject> {
        return NSFetchRequest<CharacterObject>(entityName: "CharacterObject")
    }
    
    @NSManaged public var id: Int64
    @NSManaged public var name: String
    @NSManaged public var descriptionText: String
    @NSManaged public var created: Date?
    @NSManaged public var resourceURI: String?
    @NSManaged public var image: ImageObject?
    
}

extension CharacterObject {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "created", ascending: true)]
    }
        
    static func createCharacter(with character: Character, imageObject: ImageObject?, in context: NSManagedObjectContext) -> CharacterObject {
    
        let characterObject = CharacterObject(context: context)
        characterObject.created = Date()
        characterObject.id = Int64(character.id)
        characterObject.name = character.name
        characterObject.descriptionText = character.description
        characterObject.resourceURI = character.resourceURI
        characterObject.image = imageObject
        return characterObject
    }
    
    static func deleteCharacter(with character: Character, in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<CharacterObject> = CharacterObject.fetchRequest()
        request.predicate = NSPredicate(format: "id = %ld", Int64(character.id))
        
        do {
            let match = try context.fetch(request)
            guard let persistedCharacter = match.first else {
                return
            }
            context.delete(persistedCharacter)
            
        } catch {
            throw error
        }
    }
    
}

extension NSManagedObjectContext {
    
    func hasPersistenceId(for character: Character) -> Bool {
        let request: NSFetchRequest<CharacterObject> = CharacterObject.fetchRequest()
        request.predicate = NSPredicate(format: "id = %ld", Int64(character.id))
        request.propertiesToFetch = ["id"]
        
        do {
            let match = try self.fetch(request)
            guard let _ = match.first else {
                return false
            }
            return true
        } catch {
            return false
        }
    }
    
}
