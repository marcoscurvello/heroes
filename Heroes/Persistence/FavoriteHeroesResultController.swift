//
//  FavoriteHeroesResultController.swift
//  Heroes
//
//  Created by Marcos Curvello on 15/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit
import CoreData

protocol FavoriteHeroesResultControllerDelegate: NSObject {
    func controllerDidReceiveUpdate(controller: FavoriteHeroesController)
}

final class FavoriteHeroesController: NSObject, NSFetchedResultsControllerDelegate {

    private var store: Store!
    weak var delegate: FavoriteHeroesResultControllerDelegate?

    init(delegate: FavoriteHeroesResultControllerDelegate, store: Store) {
        self.delegate = delegate
        self.store = store
        super.init()
        self.updateFetchController()
    }

    private lazy var fetchedResultsController: NSFetchedResultsController<CharacterObject> = {
        let request: NSFetchRequest<CharacterObject> = CharacterObject.fetchRequest()
        request.sortDescriptors = CharacterObject.defaultSortDescriptors
        request.fetchBatchSize = 20

        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: store.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()

    private func updateFetchController() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("\(error.localizedDescription)")
        }
    }

}
