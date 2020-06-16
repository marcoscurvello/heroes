//
//  UserFriendlyError.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct UserFriendlyError: Error {
    let title: String
    let message: String
    let originalError: Error
}

extension UserFriendlyError {
    static func userFriendlyError(_ error: RequestLoaderError) -> UserFriendlyError {
        switch error {
        case .Transport:
            return UserFriendlyError(title: "No Internet Connection", message: "We're unable to reach the network at this time, please try again.", originalError: error)
        case .ServerSide:
            return UserFriendlyError(title: "Server Error", message: "We've encountered an unexpected issue, please try again.", originalError: error)
        default:
            return UserFriendlyError(title: "Oh, That's Embarrassing", message: "We're sorry about that, please try again.", originalError: error)
        }
    }
}
