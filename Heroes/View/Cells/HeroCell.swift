//
//  HeroCell.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

protocol HeroCellDelegate: NSObject {
    func heroCellFavoriteButtonTapped(cell: HeroCell)
}

class HeroCell: UICollectionViewCell {

    static let reuseIdentifier = "hero-cell-identifier"
    var representedIdentifier: String?

    let imageView = UIImageView()
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let favoriteButton = UIButton()

    weak var delegate: HeroCellDelegate?

    @objc func favoriteButtonTapped(_ sender: UIButton) {
        guard let delegate = delegate else { return }
        delegate.heroCellFavoriteButtonTapped(cell: self)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    var character: Character? {
        didSet {
            update()
        }
    }

    public func update(image: UIImage?) {
        DispatchQueue.main.async {
            self.update(image)
        }
    }

    // MARK: - Private

    private func update() {
        guard let character = character else {
            nameLabel.text = nil
            descriptionLabel.text = nil
            imageView.image = placeholderHeroImage
            return
        }
        nameLabel.text = character.name
        descriptionLabel.text = character.description.isEmpty ? Character.defaultDescription : character.description

        guard let data = character.thumbnail?.data, let image = UIImage(data: data) else { return }
        update(image: image)
    }

    private func update(_ image: UIImage?) {
        guard let image = image, image != imageView.image else { return }
        imageView.image = image
    }

    private func configure() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 46.0
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = UIColor.systemGray3.cgColor

        favoriteButton.addTarget(self, action: #selector(self.favoriteButtonTapped(_:)), for: .touchUpInside)
        favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
        favoriteButton.tintColor = .systemOrange
        favoriteButton.contentHorizontalAlignment = .fill
        favoriteButton.contentVerticalAlignment = .fill

        let titleSize = CGFloat(18.0)
        let titleWeight: UIFont.Weight = .semibold

        if let titleDescriptor = UIFont.systemFont(ofSize: titleSize, weight: titleWeight).fontDescriptor.withDesign(.rounded) {
            nameLabel.font = UIFont(descriptor: titleDescriptor, size: 0.0)
        }  else {
            nameLabel.font = .systemFont(ofSize: titleSize, weight: titleWeight)
        }

        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.textAlignment = .left
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .caption2).withSize(14.0)
        descriptionLabel.textColor = .secondaryLabel

        nameLabel.textAlignment = .left
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        imageView.image = placeholderHeroImage

        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(favoriteButton)

        backgroundColor = .systemGray5
        layer.cornerRadius = 16.0

        let outterSpacing = CGFloat(20)
        let innerSpacing = CGFloat(10)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: outterSpacing),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: outterSpacing),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -outterSpacing),
            nameLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -innerSpacing),

            imageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: innerSpacing),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -outterSpacing),
            imageView.widthAnchor.constraint(equalToConstant: 92.0),
            imageView.heightAnchor.constraint(equalToConstant: 92.0),

            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: innerSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: outterSpacing),
            descriptionLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -innerSpacing),
            descriptionLabel.bottomAnchor.constraint(equalTo: favoriteButton.topAnchor, constant: -innerSpacing),

            favoriteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: innerSpacing),
            favoriteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: outterSpacing),
            favoriteButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -outterSpacing),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30.0),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28.0),
        ])

    }

}
