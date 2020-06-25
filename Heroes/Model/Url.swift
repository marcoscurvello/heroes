//
//  Url.swift
//  Heroes
//
//  Created by Marcos Curvello on 18/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct Url: Decodable, Equatable {
    let type: String
    let url: String
}

extension Url {
    
    static func detail(_ url: String) -> Url {
        Url(type: "detail", url: url)
    }
    
    static func purchase(_ url: String) -> Url {
        Url(type: "purchase", url: url)
    }
    
    static func reader(_ url: String) -> Url {
        Url(type: "reader", url: url)
    }
    
    static func inAppLink(_ url: String) -> Url {
        Url(type: "inAppLink", url: url)
    }

}
