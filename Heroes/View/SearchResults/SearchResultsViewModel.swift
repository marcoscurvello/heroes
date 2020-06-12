//
//  SearchResultsViewModel.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation
import UIKit

protocol SearchResultsViewModelErrorHandler: NSObject {
    func viewModelDidReceiveError(error: UserFriendlyError)
}

protocol SearchResultsViewModelInformationandler: NSObject {
    func updateSearchResult(with count: Int)
}

class SearchResultsViewModel {
    
    enum State {
        case ready, loading
    }
    
    var state: State = .ready
    
    var server: Server!
    let request: CharacterRequest<Character>!
    let requestLoader: RequestLoader<CharacterRequest<Character>>!
    let debouncer: Debouncer = Debouncer(minimumDelay: 0.5)
    
    var dataSource: UICollectionViewDiffableDataSource<SearchResultsViewController.Section, Character>!
    var currentSnapshot: NSDiffableDataSourceSnapshot<SearchResultsViewController.Section, Character>!
    var currentSearchResult: SearchResult?
    
    weak var errorHandler: SearchResultsViewModelErrorHandler?
    weak var infoHandler: SearchResultsViewModelInformationandler?
    
    init(server: Server? = Server.shared) {
        self.server = server
        self.request = try? server!.characterBaseRequest()
        self.requestLoader = RequestLoader(request: request)
        self.configureSnapshot()
    }
    
    // MARK: Search Pagination
    
    private let defaultPageSize = 20
    func requestOffsetForInput(_ text: String) -> Int {
        guard let cs = currentSearchResult, text == cs.query.input.value else {
            return 0
        }
        
        let currentOffset = Int(cs.query.offset.value)!
        let newOffset = currentOffset + defaultPageSize
        return newOffset >= cs.total ? currentOffset : newOffset
    }
    
    // MARK: Search Query Composition
    
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
    
    // MARK: Data Fetch
    
    func fetchWithQuery(searchQuery: SearchQuery) {
        state = .loading
        
        self.requestLoader.load(data: [searchQuery.offset, searchQuery.input]) { [weak self] result in
            switch result {
            case .success(let response):
                self?.updateSearchResult(with: SearchResult(total: response.data.total, query: searchQuery), data: response.data.results)
            case .failure(let error):
                guard let self = self else { return }
                self.state = .ready
                self.errorHandler?.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }
    
    // MARK: Data Source Update
    
    func updateSearchResult(with result: SearchResult, data: [Character]) {
        state = .ready
        
        if result.query.input == currentSearchResult?.query.input {
            currentSnapshot.appendItems(data, toSection: .results)
        } else if !data.isEmpty {
            currentSnapshot = NSDiffableDataSourceSnapshot<SearchResultsViewController.Section, Character>()
            currentSnapshot.appendSections([.results])
            currentSnapshot.appendItems(data)
        }
        
        currentSearchResult = result
        updateSearchResultsLabel(result.total)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: UI Update
    
    func updateSearchResultsLabel(_ count: Int? = nil) {
        self.infoHandler?.updateSearchResult(with: count ?? 0)
    }
    
    // MARK: Reset State
    
    func resetSearchResultState() {
        currentSearchResult = nil
        currentSnapshot = nil
    }
    
    func configureSnapshot() {
        DispatchQueue.global().async {
            self.currentSnapshot = NSDiffableDataSourceSnapshot<SearchResultsViewController.Section, Character>()
            self.currentSnapshot.appendSections(SearchResultsViewController.Section.allCases)
            self.currentSnapshot.appendItems([], toSection: .results)
        }
    }
    
}

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
