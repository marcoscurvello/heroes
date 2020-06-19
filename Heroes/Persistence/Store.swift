//
//  Store.swift
//  Heroes
//
//  Created by Marcos Curvello on 10/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import CoreData

final class Store {
    
    enum StoreError: Error {
        case load(Error)
        case save(Error)
        case delete(Error)
    }
    
    private let container: NSPersistentContainer
    private var storeErrors: [StoreError]?
    
    init(name: String? = "Heroes") {
        container = NSPersistentContainer(name: name!)
        container.loadPersistentStores { storeDesription, error in
            guard error == nil else {
                fatalError("Unable to load Store, error: \(StoreError.load(error!))")
            }
        }
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        return context
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        let context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        return context
    }()
    
    func deleteCharacter(character: Character) {
        let context = backgroundContext
        
        context.perform {
            do {
                try CharacterObject.deleteCharacter(with: character, in: context)
                self.save(context) { result in
                    switch result {
                    case .success(let status): print("Save Status: \(status)")
                    case .failure(let storeError): self.storeErrors?.append(storeError)
                    }
                }
            } catch {
                let storeError = StoreError.save(error)
                self.storeErrors?.append(storeError)
            }
        }
    }
    
    
    func toggleStorage(for character: Character, with data: Data? = nil, completion: @escaping (Bool) -> Void) {
        let context = viewContext
        
        context.perform {
            do {
                if  context.hasPersistenceId(for: character) {
                    try CharacterObject.deleteCharacter(with: character, in: context)
                }
                else {
                    guard let imageData = data, let imageObject = try? ImageObject.findOrCreateImage(with: character.thumbnail!, with: imageData, in: context) else {
                        return _ = CharacterObject.createCharacter(with: character, imageObject: nil, in: context)
                    }
                    let characterObject = CharacterObject.createCharacter(with: character, imageObject: imageObject, in: context)
                    try? context.obtainPermanentIDs(for: [characterObject])
                }
                
                self.save(context) { result in
                    switch result {
                    case .success(_): completion(true)
                    case .failure(let storeError):
                        self.storeErrors?.append(storeError)
                        completion(false)
                    }
                }
                
            } catch {
                let storeError = StoreError.save(error)
                self.storeErrors?.append(storeError)
                completion(false)
            }
        }
    }
    
    private func save(_ context: NSManagedObjectContext, completion: @escaping (Result<Bool, StoreError>) -> ()) {
        var status = false
        
        context.perform {
            if context.hasChanges {
                
                do {
                    try context.save()
                    
                } catch {
                    let error = StoreError.save(error)
                    return completion(.failure(error))
                }
                
                context.reset()
            }
            status = true
            completion(.success(status))
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
