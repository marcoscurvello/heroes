//
//  ResourceCell.swift
//  Heroes
//
//  Created by Marcos Curvello on 07/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class ResourceCell: UICollectionViewCell {
    
    static let reuseIdentifier = "resource-cell-reuse-identifier"
    var representedIdentifier: String?
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
        
    func update(image: UIImage?) {
        DispatchQueue.main.async {
            self.update(image)
        }
    }
    
    private func update(_ image: UIImage?) {
        guard let image = image else {
            imageView.contentMode = .center
            imageView.image = placeholderResourceImage
            return
        }
        imageView.image = image
        imageView.contentMode = .scaleToFill
    }
    
}

extension ResourceCell {
    
    func configure() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
            
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        titleLabel.adjustsFontForContentSizeCategory = true
        
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        imageView.image = placeholderResourceImage
        imageView.backgroundColor = Theme.colors.imageViewBackgroundColor

        let spacing = CGFloat(10)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 10.0)
        ])
        
    }
}
