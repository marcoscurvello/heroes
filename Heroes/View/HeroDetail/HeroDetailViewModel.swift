//
//  HeroDetailViewModel.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

protocol HeroDetailViewModelDelegate: NSObject {
    func viewModelDidReceiveError(error: UserFriendlyError)
    func viewModelDidTogglePersistentence(with status: Bool)
}

class HeroDetailViewModel {
    
    var environment: Environment!
    var imageFetcher: ImageFetcher?
    
    weak var delegate: HeroDetailViewModelDelegate?
    var dataSource: ResourceDataSource! = nil
    
    var comicsRequest: CharacterRequest<Comic>!
    var storiesRequest: CharacterRequest<Storie>!
    var eventsRequest: CharacterRequest<Event>!
    var seriesRequest: CharacterRequest<Serie>!
    
    var comicsRequestLoader: RequestLoader<CharacterRequest<Comic>>!
    var storiesRequestLoader: RequestLoader<CharacterRequest<Storie>>!
    var eventsRequestLoader: RequestLoader<CharacterRequest<Event>>!
    var seriesRequestLoader: RequestLoader<CharacterRequest<Serie>>!
    
    init(environment: Environment, imageFetcher: ImageFetcher? = nil) {
        self.environment = environment
        self.imageFetcher = imageFetcher
    }
    
    func configureResourceRequests(with characterId: Int) {
        let identifier = String(characterId)
        
        comicsRequest = try? environment.server.characterComicsRequest(id: identifier)
        storiesRequest = try? environment.server.characterStoriesRequest(id: identifier)
        eventsRequest = try? environment.server.characterEventsRequest(id: identifier)
        seriesRequest = try? environment.server.characterSeriesRequest(id: identifier)
        
        comicsRequestLoader = RequestLoader(request: comicsRequest)
        storiesRequestLoader = RequestLoader(request: storiesRequest)
        eventsRequestLoader = RequestLoader(request: eventsRequest)
        seriesRequestLoader = RequestLoader(request: seriesRequest)
    }
    
    func requestCharacterData() {
        requestComicsData()
        requestStoriesData()
        requestEventsData()
        requestSeriesData()
    }
    
    private func requestComicsData() {
        comicsRequestLoader.load(data: []) { [weak self] result in
            switch result {
            case let .success(response): self?.applyDataSourceChange(section: .comics, resources: response.data.results.toDisplayable() )
            case let .failure(error): self?.delegate?.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }
    
    private func requestStoriesData() {
        storiesRequestLoader.load(data: []) { [weak self] result in
            switch result {
            case let .success(response): self?.applyDataSourceChange(section: .stories, resources: response.data.results.toDisplayable() )
            case let .failure(error): self?.delegate?.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }
    
    private func requestSeriesData() {
        seriesRequestLoader.load(data: []) { [weak self] result in
            switch result {
            case let .success(response): self?.applyDataSourceChange(section: .series, resources: response.data.results.toDisplayable() )
            case let .failure(error): self?.delegate?.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }
    
    private func requestEventsData() {
        eventsRequestLoader.load(data: []) { [weak self] result in
            switch result {
            case let .success(response): self?.applyDataSourceChange(section: .events, resources: response.data.results.toDisplayable() )
            case let .failure(error): self?.delegate?.viewModelDidReceiveError(error: .userFriendlyError(error))
            }
        }
    }
    
    func applyDataSourceChange(section: ResourceDataSource.LayoutSection, resources: [DisplayableResource]) {
        guard !resources.isEmpty else { return }
        
        var snapshot = dataSource.snapshot()
        if snapshot.sectionIdentifiers.isEmpty {
            snapshot.appendSections(ResourceDataSource.LayoutSection.allCases)
        }
        
        snapshot.appendItems(resources, toSection: section)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func toggleCharacterPersistenceState(with message: StateChangeMessage, data: Data?) {
        environment.store.toggleStorage(for: message.character, with: data, completion: { [weak self] status in
            guard status, let self = self, let delegate = self.delegate else { return }
            delegate.viewModelDidTogglePersistentence(with: status)
        })
    }
    
}
