//
//  IntegrationModels.swift
//  Heroes
//
//  Created by Marcos Curvello on 16/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct StateChangeMessage {
    let state: State
    let title: String
    let message: String
    let character: Character
}

extension StateChangeMessage {
    enum State { case memory, persisted }

    static func deleteCharacter(_ state: State = .memory, with character: Character) -> StateChangeMessage {
        StateChangeMessage(state: state, title: "Delete \"\(character.name)\"?", message: "Deleting this hero will also delete it's data.", character: character)
    }
}
