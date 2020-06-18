//
//  HeroListViewModel.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

protocol HeroListViewModelErrorHandler: NSObject {
    func viewModelDidReceiveError(error: UserFriendlyError)
}

class HeroListViewModel: NSObject {
    
    enum State { case ready, loading }
    
    private let environment: Environment
    private var state: State = .ready
    
    private var request: CharacterRequest<Character>!
    private var requestLoader: RequestLoader<CharacterRequest<Character>>!
    private var dataContainer: DataContainer<Character>?
    
    private var dataSource: HeroDataSource?
    private var favoriteHeroesController: FavoriteHeroesFetchController!
    
    weak var errorHandler: HeroListViewModelErrorHandler?
    
    init(environment: Environment) {
        self.environment = environment
        super.init()
        
        request = try? environment.server.characterBaseRequest()
        requestLoader = RequestLoader(request: request)
        
        favoriteHeroesController = FavoriteHeroesFetchController(context: environment.store.viewContext, delegate: self)
        favoriteHeroesController.updateFetchController()
    }
    
    func configureDataSource(with dataSource: HeroDataSource) {
        self.dataSource = dataSource
        configureDataSource()
    }
    
    // MARK: - Pagination
    
    private let defaultPageSize = 20
    private let defaultPrefetchBuffer = 1
    
    private var requestOffset: Int {
        guard let co = dataContainer else {
            return 0
        }
        let newOffset = co.offset + defaultPageSize
        return newOffset >= co.total ? co.offset : newOffset
    }
    
    private var hasNextPage: Bool {
        guard let co = dataContainer else {
            return true
        }
        let newOffset = co.offset + defaultPageSize
        return newOffset >= co.total ? false : true
    }
    
    // MARK: - Data Source
    
    func item(for indexPath: IndexPath) -> Character? {
        dataSource?.itemIdentifier(for: indexPath)
    }
    
    private func appendDataSource(with characters: [Character]) {
        guard let dataSource = dataSource else { return }
        defer { state = .ready }
        
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(characters, toSection: .main)
        apply(currentSnapshot)
    }
    
    private func reloadDataSource(with character: Character) {
        guard let dataSource = dataSource else { return }
        defer { state = .ready }
        
        var snapshot = dataSource.snapshot()
        if snapshot.itemIdentifiers.contains(character) {
            snapshot.reloadItems([character])
            apply(snapshot)
        }
    }
    
    private func configureDataSource() {
        var initialSnapshot = HeroSnapshot()
        initialSnapshot.appendSections([.main])
        initialSnapshot.appendItems([], toSection: .main)
        apply(initialSnapshot, animating: false)
    }
    
    private func apply(_ changes: HeroSnapshot, animating: Bool = true) {
        DispatchQueue.global().async {
            self.dataSource?.apply(changes, animatingDifferences: animating)
        }
    }
    
    // MARK: -  Data Fetch
    
    func shouldFetchData(index: Int) {
        guard let dataSource = dataSource else { return }
        let currentSnapshot = dataSource.snapshot()
        
        guard currentSnapshot.numberOfItems == (index + defaultPrefetchBuffer) && hasNextPage && state == .ready else {
            return
        }
        requestData()
    }
    
    func requestData() {
        guard state == .ready else { return }
        state = .loading
        
        let offsetQuery: [Query] = [.offset(String(requestOffset))]
        
        requestLoader.load(data: offsetQuery) { [weak self] result in
            switch result {
            case .success(let container):
                guard let self = self else { return }
                self.dataContainer = container.data
                self.appendDataSource(with: container.data.results)
                
            case .failure(let error):
                guard let handler = self?.errorHandler else { return }
                handler.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }
    
}


// MARK: - NSFetchedResultsControllerDelegate

import UIKit
import CoreData

extension HeroListViewModel: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        for change in diff {
            switch change {
            case .insert(_, let elementId, _):
                if let characterObject = environment.store.viewContext.registeredObject(for: elementId) as? CharacterObject {
                    let character = Character(managedObject: characterObject)
                    reloadDataSource(with: character)
                }
            case .remove(_, let elementId, _):
                if let characterObject = environment.store.viewContext.registeredObject(for: elementId) as? CharacterObject {
                    let character = Character(managedObject: characterObject)
                    reloadDataSource(with: character)
                }
            }
        }
    }
}
