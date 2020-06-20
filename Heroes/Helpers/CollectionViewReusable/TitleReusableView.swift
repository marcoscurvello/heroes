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
        label.textColor = .label
        
        let titleSize = CGFloat(16.0)
        let titleWeight: UIFont.Weight = .semibold
        
        if let titleDescriptor = UIFont.systemFont(ofSize: titleSize, weight: titleWeight).fontDescriptor.withDesign(.rounded) {
            label.font = UIFont(descriptor: titleDescriptor, size: 0.0)
        }  else {
            label.font = .systemFont(ofSize: titleSize, weight: titleWeight)
        }

        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            label.topAnchor.constraint(equalTo: topAnchor, constant: inset)
        ])
    }
    
}
