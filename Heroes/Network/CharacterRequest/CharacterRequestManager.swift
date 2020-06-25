//
//  DetailRequestsManager.swift
//  Heroes
//
//  Created by Marcos Curvello on 23/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

protocol CharacterRequestManagerDelegate: NSObject {
    func requestManagerDidReceiveData(for section: ResourceDataSource.Section, data: [DisplayableResource])
    func requestManagerDidReceiveError(userFriendlyError: UserFriendlyError)
}

class CharacterRequestManager {
    
    let server: Server!
    weak var delegate: CharacterRequestManagerDelegate?
    
    var comicsRequest: CharacterRequest<Comic>!
    var storiesRequest: CharacterRequest<Storie>!
    var eventsRequest: CharacterRequest<Event>!
    var seriesRequest: CharacterRequest<Serie>!
    
    var comicsRequestLoader: RequestLoader<CharacterRequest<Comic>>!
    var storiesRequestLoader: RequestLoader<CharacterRequest<Storie>>!
    var eventsRequestLoader: RequestLoader<CharacterRequest<Event>>!
    var seriesRequestLoader: RequestLoader<CharacterRequest<Serie>>!
    
    init(server: Server, delegate: CharacterRequestManagerDelegate) {
        self.server = server
        self.delegate = delegate
    }
    
    func configureResourceRequests(with characterId: Int) {
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
    
    func requestCharacterData() {
        requestComicsData()
        requestStoriesData()
        requestEventsData()
        requestSeriesData()
    }
    
    private func requestComicsData() {
        comicsRequestLoader.load(data: []) { [weak self] result in
            switch result {
                case let .success(response): self?.delegate?.requestManagerDidReceiveData(for: .comics, data: response.data.results.toDisplayable())
                case let .failure(error): self?.delegate?.requestManagerDidReceiveError(userFriendlyError: .userFriendlyError(error))
            }
        }
    }
    
    private func requestStoriesData() {
        storiesRequestLoader.load(data: []) { [weak self] result in
            switch result {
                case let .success(response): self?.delegate?.requestManagerDidReceiveData(for: .stories, data: response.data.results.toDisplayable())
                case let .failure(error): self?.delegate?.requestManagerDidReceiveError(userFriendlyError: .userFriendlyError(error))
            }
        }
    }
    
    private func requestSeriesData() {
        seriesRequestLoader.load(data: []) { [weak self] result in
            switch result {
                case let .success(response): self?.delegate?.requestManagerDidReceiveData(for: .series, data: response.data.results.toDisplayable())
                case let .failure(error): self?.delegate?.requestManagerDidReceiveError(userFriendlyError: .userFriendlyError(error))
            }
        }
    }
    
    private func requestEventsData() {
        eventsRequestLoader.load(data: []) { [weak self] result in
            switch result {
                case let .success(response): self?.delegate?.requestManagerDidReceiveData(for: .events, data: response.data.results.toDisplayable())
                case let .failure(error): self?.delegate?.requestManagerDidReceiveError(userFriendlyError: .userFriendlyError(error))
            }
        }
    }
}
