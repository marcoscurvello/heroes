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

protocol SearchResultsViewModelSearchHandler: NSObject {
    func updateSearchResult(with count: Int)
}

class SearchResultsViewModel {
    
    enum State {
        case ready, loading
    }
    
    let server: Server!
    let debouncer: Debouncer = Debouncer(minimumDelay: 0.5)
    let request: CharacterRequest<Character>!
    let requestLoader: RequestLoader<CharacterRequest<Character>>!
    
    var state: State = .ready
    var currentSearchResult: SearchResult?
    var dataSource: UICollectionViewDiffableDataSource<SearchResultsViewController.Section, Character>!
    var currentSnapshot: NSDiffableDataSourceSnapshot<SearchResultsViewController.Section, Character>!
    
    weak var errorHandler: SearchResultsViewModelErrorHandler?
    weak var searchInfoHandler: SearchResultsViewModelSearchHandler?
    
    init(server: Server? = Server.shared) {
        self.server = server
        self.request = try? server!.characterBaseRequest()
        self.requestLoader = RequestLoader(request: request)
    }
    
    // MARK: Pagination
    
    private let defaultPageSize = 20
    var requestOffset: Int {
        guard let co = currentSearchResult else {
            return 0
        }
        let currentOffset = Int(co.query.offset.value)!
        let newOffset = currentOffset + defaultPageSize
        return newOffset >= co.total ? currentOffset : newOffset
    }
    
    var hasNextPage: Bool {
        guard let co = currentSearchResult else {
            return true
        }
        let currentOffset = Int(co.query.offset.value)!
        let newOffset = currentOffset + defaultPageSize
        return newOffset >= co.total ? false : true
    }
    
    struct SearchQuery: Equatable {
        let offset: Query
        let textInput: Query
    }
    
    struct SearchResult {
        let total: Int
        let query: SearchQuery
        let data: [Character]
    }
    
    func fetchCharactersWith(textInput: String?) {
        state = .loading
        
        var newSearchQuery: SearchQuery!
        if let input = textInput {
            newSearchQuery = SearchQuery(offset: .offset("0"), textInput: .nameStartsWith(input))
        } else {
            if let currentSearchQuery = currentSearchResult?.query.textInput.value {
                newSearchQuery = SearchQuery(offset: .offset("\(requestOffset)"), textInput: .nameStartsWith(currentSearchQuery))
            }
        }
        
        guard newSearchQuery != currentSearchResult?.query else {
            return state = .ready
        }
        
        self.requestLoader.load(data: [newSearchQuery.offset, newSearchQuery.textInput]) { [weak self] result in
            switch result {
            case .success(let response):
                self?.updateSearchResult(with: SearchResult(total: response.data.total, query: newSearchQuery, data: response.data.results))
            case .failure(let error):
                guard let self = self else { return }
                self.state = .ready
                self.errorHandler?.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }
    
    func updateSearchResult(with result: SearchResult) {
        updateSearchDataSource(result)
        updateSearchResultsLabel(result.total)
    }
    
    func updateSearchDataSource(_ result: SearchResult) {
        guard !result.data.isEmpty || currentSnapshot.itemIdentifiers != result.data else { return }
        state = .ready
        
        if result.query.textInput == currentSearchResult?.query.textInput && currentSnapshot != nil {
            currentSnapshot.appendItems(result.data, toSection: .results)
        } else {
            currentSnapshot = NSDiffableDataSourceSnapshot<SearchResultsViewController.Section, Character>()
            currentSnapshot.appendSections([.results])
            currentSnapshot.appendItems(result.data)
        }
        
        currentSearchResult = result
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    func updateSearchResultsLabel(_ count: Int? = nil) {
        self.searchInfoHandler?.updateSearchResult(with: count ?? 0)
    }

    func resetSearchResultState() {
        currentSearchResult = nil
        currentSnapshot = nil
    }
    
}

