//
//  DetailXibViewController.swift
//  Heroes
//
//  Created by Marcos Curvello on 08/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class HeroDetailViewController: UIViewController {
    
    enum LayoutSection: Int, CaseIterable {
        case comics, stories, events, series
        var sectionTitle: String {
            switch self {
            case .comics:
                return "Comics"
            case .stories:
                return "Stories"
            case .events:
                return "Events"
            case .series:
                return "Series"
            }
        }
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var resourcesCollectionView: UICollectionView!
    
    var character: Character!
    var viewModel: HeroDetailViewModel!
    let imageFetcher = ImageFetcher.shared
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    init(character: Character, viewModel: HeroDetailViewModel? = HeroDetailViewModel()) {
        super.init(nibName: nil, bundle: nil)
        self.character = character
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        titleLabel.text = character.name
        descriptionLabel.text = (character.description != "") ? character.description : "No description availiable"
        
    
        viewModel.update(character: character, delegate: self)
        configureDataSource(collectionView: resourcesCollectionView)
        
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

extension HeroDetailViewController {
    
    private func configureDataSource(collectionView: UICollectionView) {
        
        viewModel.dataSource = UICollectionViewDiffableDataSource<LayoutSection, DisplayableResource>(collectionView: collectionView) { [weak self]
            (collectionView: UICollectionView, indexPath: IndexPath, resource: DisplayableResource) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResourceCell.reuseIdentifier, for: indexPath) as! ResourceCell
            cell.titleLabel.text = resource.title
            
            if let identifier = resource.thumbnail?.absoluteString {
                cell.representedIdentifier = identifier
                if let cachedImage = self?.imageFetcher.cachedImage(for: identifier) {
                    cell.display(image: cachedImage)
                    
                } else {
                    
                    self?.imageFetcher.fetchAsync(identifier) { [weak cell] image in
                        guard let theCell = cell, theCell.representedIdentifier == identifier else { return }
                        theCell.display(image: image)
                    }
                }
            } else {
                cell.display(image: nil)
            }
            
            
            return cell
        }
        
        viewModel.dataSource.supplementaryViewProvider = {
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let titleSupplementary = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath) as! TitleSupplementaryView
            
            let section = LayoutSection(rawValue: indexPath.section)!
            titleSupplementary.label.text = section.sectionTitle
            return titleSupplementary
        }
    }
}

extension HeroDetailViewController: HeroDetailViewModelDelegate {
    
    func viewModelDidReceiveError(error: UserFriendlyError) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
}
