//
//  SearchResultsViewModel.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

protocol SearchResultsViewModelErrorHandler: NSObject {
    func viewModelDidReceiveError(error: UserFriendlyError)
}

protocol SearchResultsViewModelInformationandler: NSObject {
    func presentSearchActivity()
    func presentSearchResult(with count: Int)
}

class SearchResultsViewModel: NSObject {

    private enum State { case ready, loading }

    private let environment: Environment!
    private var state: State = .ready

    private let request: CharacterRequest<Character>!
    private var requestLoader: RequestLoader<CharacterRequest<Character>>!
    private let debouncer: Debouncer = Debouncer(minimumDelay: 0.5)

    private var currentSearchResult: SearchResult?
    private var searchDataSource: HeroDataSource?
    private var favoriteHeroesController: FavoriteHeroesFetchController!

    weak var errorHandler: SearchResultsViewModelErrorHandler?
    weak var infoHandler: SearchResultsViewModelInformationandler?

    // MARK: - Init

    init(environment: Environment) {
        self.environment = environment
        self.request = try? environment.server.characterBaseRequest()
        super.init()

        requestLoader = RequestLoader(request: request)
        favoriteHeroesController = FavoriteHeroesFetchController(context: environment.store.viewContext, delegate: self)
        favoriteHeroesController.updateFetchController()
    }

    func configureDataSource(with dataSource: HeroDataSource) {
        searchDataSource = dataSource
        configureDataSource()
    }

    // MARK: Pagination

    private let defaultPageSize = 20
    private let defaultPrefetchBuffer = 1

    func requestOffsetForInput(_ text: String) -> Int {
        guard let cs = currentSearchResult, text == cs.query.input.value else {
            return 0
        }

        let currentOffset = Int(cs.query.offset.value)!
        let newOffset = currentOffset + defaultPageSize
        return newOffset >= cs.total ? currentOffset : newOffset
    }

    func composeNextPageSearchQuery() -> SearchQuery? {
        guard let csi = currentSearchResult?.query.input.value else {
            return nil
        }
        let searchQuery = SearchQuery(offset: .offset("\(requestOffsetForInput(csi))"), input: .nameStartsWith(csi))
        guard searchQuery != currentSearchResult?.query else {
            return nil
        }
        return searchQuery
    }

    func composeSearchQuery(with text: String) -> SearchQuery? {
        guard text != currentSearchResult?.query.input.value else {
            return nil
        }
        let searchQuery = SearchQuery(offset: .offset("\(requestOffsetForInput(text))"), input: .nameStartsWith(text))
        guard searchQuery != currentSearchResult?.query else {
            return nil
        }
        return searchQuery
    }


    // MARK: - Data Fetch

    func performSearch(with text: String) {
        debouncer.debounce { [unowned self] in
            guard let newSearchQuery = self.composeSearchQuery(with: text) else { return }

            self.infoHandler?.presentSearchActivity()
            self.requestWithQuery(searchQuery: newSearchQuery)
        }
    }

    func requestWithQuery(searchQuery: SearchQuery) {
        state = .loading

        self.requestLoader.load(data: [searchQuery.offset, searchQuery.input]) { [weak self] result in
            switch result {
            case .success(let response):
                guard let self = self else { return }
                self.updateSearchResult(with: SearchResult(total: response.data.total, query: searchQuery), data: response.data.results)

            case .failure(let error):
                guard let self = self else { return }
                self.state = .ready
                self.errorHandler?.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }

    func shouldFetchData(index: Int) {
        guard let dataSource = searchDataSource else { return }
        let currentSnapshot = dataSource.snapshot()

        guard currentSnapshot.numberOfItems == (index + defaultPrefetchBuffer) && state == .ready, let searchQuery = composeNextPageSearchQuery() else {
            return
        }
        requestWithQuery(searchQuery: searchQuery)
    }


    // MARK: - Data Source

    func item(for indexPath: IndexPath) -> Character? {
        searchDataSource?.itemIdentifier(for: indexPath)
    }

    func updateSearchResult(with result: SearchResult, data: [Character]) {
        guard let dataSource = searchDataSource else { return }
        state = .ready

        var currentSnapshot = dataSource.snapshot()
        if result.query.input == currentSearchResult?.query.input {
            currentSnapshot.appendItems(data, toSection: .main)
        } else if !data.isEmpty {
            currentSnapshot = HeroSnapshot()
            currentSnapshot.appendSections([.main])
            currentSnapshot.appendItems(data)
        }

        currentSearchResult = result
        updateSearchResultsLabel(result.total)
        apply(currentSnapshot)
    }

    private func reloadDataSource(with character: Character) {
        guard let dataSource = searchDataSource else { return }
        defer { state = .ready }

        var snapshot = dataSource.snapshot()
        if snapshot.itemIdentifiers.contains(character) {
            snapshot.reloadItems([character])
            apply(snapshot)
        }
    }

    private func apply(_ changes: HeroSnapshot, animating: Bool = true) {
        DispatchQueue.global().async {
            self.searchDataSource?.apply(changes, animatingDifferences: animating)
        }
    }

    private func configureDataSource() {
        var initialSnapshot = HeroSnapshot()
        initialSnapshot.appendSections([.main])
        initialSnapshot.appendItems([], toSection: .main)
        apply(initialSnapshot, animating: false)
    }

    // MARK: UI

    func updateSearchResultsLabel(_ count: Int? = nil) {
        self.infoHandler?.presentSearchResult(with: count ?? 0)
    }

    // MARK: Reset State

    func resetSearchResultState() {
        currentSearchResult = nil
    }

}

// MARK: - Helper Structures

extension SearchResultsViewModel {

    struct SearchQuery: Equatable {
        let offset: Query
        let input: Query
    }

    struct SearchResult {
        let total: Int
        let query: SearchQuery
    }

}

// MARK: - NSFetchedResultsControllerDelegate

import UIKit
import CoreData

extension SearchResultsViewModel: NSFetchedResultsControllerDelegate {

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
