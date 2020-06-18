//
//  Image.swift
//  Heroes
//
//  Created by Marcos Curvello on 18/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

struct Image: Decodable, Hashable {
    let path: String?
    let `extension`: String?
    let data: Data?
}

extension Image {
    var absoluteString: String { "\(path!).\(`extension`!)" }
}
