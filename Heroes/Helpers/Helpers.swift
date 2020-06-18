//
//  Helpers.swift
//  Heroes
//
//  Created by Marcos Curvello on 09/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

let placeholderHeroImage = UIImage(named: "hero-placeholder")!

let placeholderResourceImage: UIImage = {
    let configuration = UIImage.SymbolConfiguration(scale: .small)
    let image = UIImage(systemName: "person.crop.square", withConfiguration: configuration)!
    return image.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
}()
