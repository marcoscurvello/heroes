//
//  DateContainer.swift
//  Heroes
//
//  Created by Marcos Curvello on 24/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

// MARK: - DateContainer

struct DateContainer: Decodable, Equatable {
    let type: String
    let date: String
}

extension DateContainer {
    static let getTypeValue: KeyPath<DateContainer, String> = \.type
    static let getDateValue: KeyPath<DateContainer, String> = \.date
    
    static func onSaleDate(_ date: String) -> DateContainer {
        DateContainer(type: "onsaleDate", date: date)
    }
}
