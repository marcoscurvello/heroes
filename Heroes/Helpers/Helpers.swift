//
//  Helpers.swift
//  Heroes
//
//  Created by Marcos Curvello on 09/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

let unavailableTitle = "No title availiable."
let unavailableDescription = "No description availiable."
let placeholderHeroImage = UIImage(named: "hero-placeholder")!

let placeholderResourceImage: UIImage = {
    let configuration = UIImage.SymbolConfiguration(scale: .small)
    let image = UIImage(systemName: "person.crop.square", withConfiguration: configuration)!
    return image.withTintColor(.lightGray, renderingMode: .alwaysOriginal).withTintColor(.systemGray4)
}()

let currencyFormatter: NumberFormatter = {
    let 🇺🇸 = Locale(identifier: "en_US")
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = 🇺🇸
    return formatter
}()

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return formatter
}()
