//
//  HeroDetailViewModel.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation
import UIKit

protocol HeroDetailViewModelDelegate: NSObject {
    func viewModelDidReceiveError(error: UserFriendlyError)
}

class HeroDetailViewModel {
    
    let server: Server!
    var character: Character!
    
    var comicsRequest: CharacterRequest<Comic>!
    var storiesRequest: CharacterRequest<Storie>!
    var eventsRequest: CharacterRequest<Event>!
    var seriesRequest: CharacterRequest<Serie>!
    
    var comicsRequestLoader: RequestLoader<CharacterRequest<Comic>>!
    var storiesRequestLoader: RequestLoader<CharacterRequest<Storie>>!
    var eventsRequestLoader: RequestLoader<CharacterRequest<Event>>!
    var seriesRequestLoader: RequestLoader<CharacterRequest<Serie>>!
            
    var dataSource: UICollectionViewDiffableDataSource<HeroDetailViewController.LayoutSection, DisplayableResource>! = nil
    var currentSnapshot = NSDiffableDataSourceSnapshot<HeroDetailViewController.LayoutSection, DisplayableResource>()
    
    weak var delegate: HeroDetailViewModelDelegate?
    
    init(server: Server? = Server.shared) {
        self.server = server
    }

    func update(character: Character, delegate: HeroDetailViewModelDelegate) {
        self.delegate = delegate
        self.character = character
        configureResourceRequests(characterId: character.id)
    }

    func configureResourceRequests(characterId: Int) {
        let identifier = String(characterId)
        comicsRequest = try? server.characterComicsRequest(id: identifier)
        storiesRequest = try? server.characterStoriesRequest(id: identifier)
        eventsRequest = try? server.characterEventsRequest(id: identifier)
        seriesRequest = try? server.characterSeriesRequest(id: identifier)
        
        comicsRequestLoader = RequestLoader(request: comicsRequest)
        storiesRequestLoader = RequestLoader(request: storiesRequest)
        eventsRequestLoader = RequestLoader(request: eventsRequest)
        seriesRequestLoader = RequestLoader(request: seriesRequest)
    }
    
    func requestData() {
        requestComicsData()
        requestStoriesData()
        requestEventsData()
        requestSeriesData()
    }
    
    private func requestComicsData() {
        comicsRequestLoader.load(data: []) { [weak self] result in
            switch result {
            case let .success(response): self?.applyDataSourceChange(section: .comics, resources: response.data.results.map { $0.convert(type: $0) } )
            case let .failure(error): self?.delegate?.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }
    
    private func requestStoriesData() {
        storiesRequestLoader.load(data: []) { [weak self] result in
            switch result {
            case let .success(response): self?.applyDataSourceChange(section: .stories, resources: response.data.results.map { $0.convert(type: $0) } )
            case let .failure(error): self?.delegate?.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }
    
    private func requestSeriesData() {
        seriesRequestLoader.load(data: []) { [weak self] result in
            switch result {
            case let .success(response): self?.applyDataSourceChange(section: .series, resources: response.data.results.map { $0.convert(type: $0) } )
            case let .failure(error): self?.delegate?.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }
    
    private func requestEventsData() {
        eventsRequestLoader.load(data: []) { [weak self] result in
            switch result {
            case let .success(response): self?.applyDataSourceChange(section: .events, resources: response.data.results.map { $0.convert(type: $0) } )
            case let .failure(error): self?.delegate?.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }
    
    func applyDataSourceChange(section: HeroDetailViewController.LayoutSection, resources: [DisplayableResource]) {
        guard !resources.isEmpty else { return }
        if currentSnapshot.sectionIdentifiers.isEmpty {
            currentSnapshot.appendSections(HeroDetailViewController.LayoutSection.allCases)
        }
        
        currentSnapshot.appendItems(resources, toSection: section)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }

}


