//
//  TitleReusableView.swift
//  Heroes
//
//  Created by Marcos Curvello on 06/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class TitleSupplementaryView: UICollectionReusableView {
    
    static let elementKind = "title-reusable-kind"
    static let reuseIdentifier = "title-reuse-identifier"

    let label = UILabel()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
}

extension TitleSupplementaryView {
    
    func configure() {
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.preferredFont(forTextStyle: .title3)

        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            label.topAnchor.constraint(equalTo: topAnchor, constant: inset)
        ])
    }
    
}
