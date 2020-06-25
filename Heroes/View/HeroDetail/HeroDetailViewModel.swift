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

class HeroDetailViewModel: NSObject {
    
    enum State { case memory, persisted }
    
    var character: Character! {
        didSet {
            state = character.thumbnail?.data == nil ? .memory : .persisted
            configure()
        }
    }
    
    private(set) var state: State = .memory
    
    let environment: Environment!
    var dataSource: ResourceDataSource! = nil
    var detailViewRequestManager: CharacterRequestManager?
    
    weak var delegate: HeroDetailViewModelDelegate?
    
    init(environment: Environment, state: State = .memory) {
        self.state = state
        self.environment = environment
        super.init()
    }
    
    func configure() {
        detailViewRequestManager = CharacterRequestManager(server: environment.server, delegate: self)
        detailViewRequestManager!.configureResourceRequests(with: character.id)
        detailViewRequestManager!.requestCharacterData()
    }
    
    func applyDataSourceChange(section: ResourceDataSource.Section, resources: [DisplayableResource]) {
        guard !resources.isEmpty else { return }
        
        var snapshot = dataSource.snapshot()
        if snapshot.sectionIdentifiers.isEmpty {
            snapshot.appendSections(ResourceDataSource.Section.allCases)
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
    
    func composeStateChangeMessage() -> StateChangeMessage? {
        guard let character = character else { return nil}
        let message: StateChangeMessage!
        
        switch state {
        case .memory: message = .deleteCharacter(.memory, with: character)
        case .persisted: message = .deleteCharacter(.persisted, with: character)
        }
        
        return message
    }
    
}

extension HeroDetailViewModel: CharacterRequestManagerDelegate {
    
    func requestManagerDidReceiveData(for section: ResourceDataSource.Section, data: [DisplayableResource]) {
        applyDataSourceChange(section: section, resources: data)
    }
    
    func requestManagerDidReceiveError(userFriendlyError: UserFriendlyError) {
        delegate?.viewModelDidReceiveError(error: userFriendlyError)
    }
    
    
}
