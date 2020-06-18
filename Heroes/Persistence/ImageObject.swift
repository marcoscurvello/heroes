//
//  ImageObject+CoreDataClass.swift
//  Heroes
//
//  Created by Marcos Curvello on 11/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//
//

import UIKit
import CoreData

extension UIImage {
    
    var toData: Data? {
        return pngData()
    }
    
}


public class ImageObject: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageObject> {
        return NSFetchRequest<ImageObject>(entityName: "ImageObject")
    }
    
    @NSManaged public var path: String?
    @NSManaged public var type: String?
    @NSManaged public var data: Data?
    @NSManaged public var character: CharacterObject?

}

extension ImageObject {
    
    static func findOrCreateImage(with image: Image, with data: Data?, in context: NSManagedObjectContext) throws -> ImageObject {
        
        let request: NSFetchRequest<ImageObject> = ImageObject.fetchRequest()
        request.predicate = NSPredicate(format: "path = %@", image.path!)
        
        do {
            let match = try context.fetch(request)
            if match.count > 0 {
                return match.first!
            }
        } catch {
            throw error
        }
        
        let imageObject = ImageObject(context: context)
        imageObject.path = image.path
        imageObject.type = image.extension
        imageObject.data = data
        
        return imageObject
    }
}
