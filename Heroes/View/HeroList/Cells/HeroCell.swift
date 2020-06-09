//
//  HeroCell.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class HeroCell: UICollectionViewCell {
    
    static let reuseIdentifier = "hero-cell-identifier"
    static let nibIdentifier = "HeroCell"
    var representedIdentifier: String?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewBackground: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        display(image: nil)
        character = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    var character: Character? {
        didSet {
            reload()
        }
    }
    
    func display(image: UIImage?) {
        DispatchQueue.main.async {
            guard let image = image else {
                self.imageView.contentMode = .center
                self.imageView.backgroundColor = .systemGroupedBackground
                self.imageView.image = placeholderImage.withTintColor(.systemGray5)
                return
            }
            self.imageView.contentMode = .scaleToFill
            self.imageView.image = image
        }
    }
    
    private func reload() {
        nameLabel.text = character?.name
    }
    
    private func configure() {
        imageViewBackground.layer.cornerRadius = 58
        imageViewBackground.clipsToBounds = true
        
        imageView.layer.cornerRadius = 52
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        
        containerView.layer.cornerRadius = 12.0
        containerView.clipsToBounds = false
        clipsToBounds = false
    }    
    
}

