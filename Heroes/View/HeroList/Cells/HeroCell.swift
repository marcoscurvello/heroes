//
//  HeroCell.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

protocol HeroCellDelegate: NSObject {
    func heroCellFavoriteButtonTapped(character: Character)
}

class HeroCell: UICollectionViewCell {
    
    static let reuseIdentifier = "hero-cell-identifier"
    static let nibIdentifier = "HeroCell"
    var representedIdentifier: String?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let delegate = delegate, let character = self.character else { return }
        delegate.heroCellFavoriteButtonTapped(character: character)
    }
    
    weak var delegate: HeroCellDelegate?
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
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
        imageView.layer.cornerRadius = 46
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .systemGray6
        
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.systemGray4.cgColor
        
        containerView.layer.cornerRadius = 12.0
        containerView.clipsToBounds = false
    }
    
}

