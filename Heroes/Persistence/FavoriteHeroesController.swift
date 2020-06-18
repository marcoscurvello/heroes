//
//  FavoriteHeroesResultController.swift
//  Heroes
//
//  Created by Marcos Curvello on 15/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit
import CoreData

final class FavoriteHeroesFetchController: NSObject {

    private var context: NSManagedObjectContext!
    weak var delegate: NSFetchedResultsControllerDelegate?

    init(context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate) {
        self.context = context
        self.delegate = delegate
        super.init()
    }

    lazy var fetchedResultsController: NSFetchedResultsController<CharacterObject> = {
        let request: NSFetchRequest<CharacterObject> = CharacterObject.fetchRequest()
        request.sortDescriptors = CharacterObject.defaultSortDescriptors
        request.relationshipKeyPathsForPrefetching = ["image"]
        request.returnsObjectsAsFaults = false
        request.fetchBatchSize = 0

        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = delegate
        
        return controller
    }()

    func updateFetchController() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("\(error.localizedDescription)")
        }
    }

}
