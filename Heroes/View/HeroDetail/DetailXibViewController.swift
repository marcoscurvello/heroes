//
//  DetailXibViewController.swift
//  Heroes
//
//  Created by Marcos Curvello on 08/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class HeroDetailViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var resourcesCollectionView: UICollectionView!
    
    var viewModel: CharacterDetailViewModel!
    var character: Character!
    let imageFetcher = ImageFetcher.shared
    
    override func viewDidLoad() {
        navigationItem.largeTitleDisplayMode = .always
        super.viewDidLoad()
        
        self.titleLabel.text = character.name
        self.descriptionLabel.text = character.description
        
        
        viewModel = CharacterDetailViewModel(character: character, delegate: self)
        viewModel.setupResourcesDataSource(collectionView: resourcesCollectionView)
        
        configureCollectionView()
        displayHeaderImage()
        viewModel.requestData()
    }
    
    func configureCollectionView() {
        resourcesCollectionView.setCollectionViewLayout(CollectionViewLayoutGenerator.resourcesCollectionViewLayout(), animated: false)
        resourcesCollectionView.register(ComicCell.self, forCellWithReuseIdentifier: ComicCell.reuseIdentifier)
        resourcesCollectionView.register(ResourceCell.self, forCellWithReuseIdentifier: ResourceCell.reuseIdentifier)
        resourcesCollectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: TitleSupplementaryView.elementKind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    }
    
    func displayHeaderImage() {
        guard let identifier = character.thumbnail?.absoluteString else { return }
        if let cachedImage = imageFetcher.cachedImage(for: identifier) {
            self.imageView.image = cachedImage
        } else {
            self.imageFetcher.fetchAsync(identifier) { [weak imageView] image in
                guard let theImageView = imageView else { return }
                theImageView.image = image
            }
        }
    }
    
    
}

extension HeroDetailViewController: CharacterDetailViewModelDelegate {
    
    func viewModelDidReceiveError(error: UserFriendlyError) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
