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
    let categoryLabel = UILabel()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        update(image: nil)
    }
    
    func update(image: UIImage?) {
        DispatchQueue.main.async {
            self.update(image)
        }
    }
    
    private func update(_ image: UIImage?) {
        guard let image = image else {
            imageView.contentMode = .center
            imageView.image = placeholderResourceImage.withTintColor(.systemGray4)
            return
        }
        imageView.contentMode = .scaleToFill
        imageView.image = image
    }
    
}

extension ResourceCell {
    
    func configure() {
        imageView.backgroundColor = .systemGray6
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(categoryLabel)
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        titleLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        categoryLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.textColor = .placeholderText
        
        imageView.layer.cornerRadius = 4
        imageView.contentMode = .center
        imageView.image = placeholderResourceImage.withTintColor(.systemGray4)
        
        let spacing = CGFloat(10)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
