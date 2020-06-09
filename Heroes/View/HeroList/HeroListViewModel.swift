//
//  HeroListViewModel.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation
import UIKit

protocol HeroListViewModelErrorHandler: NSObject {
    func viewModelDidReceiveError(error: UserFriendlyError)
}

class HeroListViewModel {
    
    var state: State = .ready
    enum State {
        case ready, loading
    }
    
    let server: Server!
    var request: CharacterRequest<Character>!
    var requestLoader: RequestLoader<CharacterRequest<Character>>!
    var dataContainer: DataContainer<Character>?
    
    var dataSource: UICollectionViewDiffableDataSource<HeroListViewController.Section, Character>!
    var currentSnapshot = NSDiffableDataSourceSnapshot<HeroListViewController.Section, Character>()

    weak var errorHandler: HeroListViewModelErrorHandler?
    
    init(server: Server? = Server.shared) {
        self.server = server
        request = try? self.server.characterBaseRequest()
        requestLoader = RequestLoader(request: request)
    }
    
    deinit {
        print("\(type(of: self)) deinit")
    }
    
    // MARK: Pagination
    
    private let defaultPageSize = 20
    var requestOffset: Int {
        guard let co = dataContainer else {
            return 0
        }
        let newOffset = co.offset + defaultPageSize
        return newOffset >= co.total ? co.offset : newOffset
    }
    
    var hasNextPage: Bool {
        guard let co = dataContainer else {
            return true
        }
        let newOffset = co.offset + defaultPageSize
        return newOffset >= co.total ? false : true
    }
    
    // MARK: Data Fetch
    
    func fetchCharacters() {
        guard state == .ready else { return }
        state = .loading
        
        let offsetQuery: [Query] = [.offset(String(requestOffset))]
        requestLoader.load(data: offsetQuery) { [weak self] result in
            switch result {
            case .success(let container):
                self?.dataContainer = container.data
                self?.applyDataSourceChange(container.data.results)
            case .failure(let error):
                guard let handler = self?.errorHandler else { return }
                handler.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }
    
    // MARK: UI Update
    
    private func applyDataSourceChange(_ characters: [Character]) {
        state = .ready
        
        let newItems = currentSnapshot.itemIdentifiers + characters
        currentSnapshot.appendItems(newItems, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
        
    }
    
}
