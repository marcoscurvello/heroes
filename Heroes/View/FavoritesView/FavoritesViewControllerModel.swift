//
//  FavoritesViewControllerModel.swift
//  Heroes
//
//  Created by Marcos Curvello on 11/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import CoreData

class FavoritesViewControllerModel: NSObject {
    
    enum ChangeType { case insert, remove }
    
    private let environment: Environment
    private var favoriteCharacters: [Character]?
    private var dataSource: HeroDataSource?
    private var favoriteHeroesController: FavoriteHeroesFetchController!
    
    init(environment: Environment) {
        self.environment = environment
        super.init()
        
        favoriteHeroesController = FavoriteHeroesFetchController(context: environment.store.viewContext, delegate: self)
        favoriteHeroesController.updateFetchController()
        favoriteCharacters = favoriteHeroesController.fetchedResultsController.fetchedObjects?.toCharacters()
    }
    
    // MARK: - Data Source
    
    func configureDataSource(with dataSource: HeroDataSource) {
        self.dataSource = dataSource
        configureDataSource()
    }
    
    func item(for indexPath: IndexPath) -> Character? {
        let cha =  dataSource?.itemIdentifier(for: indexPath)
        return cha
    }
    
    private func configureDataSource() {
        var initialSnapshot = HeroSnapshot()
        initialSnapshot.appendSections([.main])
        initialSnapshot.appendItems(favoriteCharacters ?? [], toSection: .main)
        apply(initialSnapshot, animating: false)
    }
    
    private func updateDataSource(with type: ChangeType, character: Character) {
        guard let dataSource = dataSource else { return }
        
        var updateSnapshot = dataSource.snapshot()
        switch type {
        case .insert:
            guard !updateSnapshot.itemIdentifiers.contains(character) else { return }
            updateSnapshot.appendItems([character], toSection: .main)
        case .remove:
            guard updateSnapshot.itemIdentifiers.contains(character) else { return }
            updateSnapshot.deleteItems([character])
        }
        apply(updateSnapshot)
    }
    
    private func apply(_ changes: HeroSnapshot, animating: Bool = true) {
        DispatchQueue.global().async {
            self.dataSource?.apply(changes, animatingDifferences: animating)
        }
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

import UIKit
import CoreData

extension FavoritesViewControllerModel: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        for change in diff {
            switch change {
            case .insert(_, let elementId, _):
                if let characterObject = environment.store.viewContext.registeredObject(for: elementId) as? CharacterObject {
                    let character = Character(managedObject: characterObject)
                    updateDataSource(with: .insert, character: character)
                }
            case .remove(_, let elementId, _):
                
                if let characterObject = environment.store.viewContext.registeredObject(for: elementId) as? CharacterObject {
                    let character = Character(managedObject: characterObject)
                    updateDataSource(with: .remove, character: character)
                }
            }
        }
    }
}
