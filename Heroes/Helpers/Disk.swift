//
//  Disk.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

func loadFromDisk<A: Decodable>(_ name: String) throws -> A  {
    let url = Bundle.main.url(forResource: name, withExtension: "json")!
    let data = try! Data(contentsOf: url)
    return try JSONDecoder().decode(A.self, from: data)
}
