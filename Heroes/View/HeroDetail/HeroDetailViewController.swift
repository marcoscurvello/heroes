//
//  DetailXibViewController.swift
//  Heroes
//
//  Created by Marcos Curvello on 08/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class HeroDetailViewController: UIViewController {
    
    static let nibIdentifier = "HeroDetailViewController"
    
    var character: Character?
    
    private let environment: Environment!
    private let imageFetcher: ImageFetcher?
    private var detailViewModel: HeroDetailViewModel!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var resourcesCollectionView: UICollectionView!
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        presentPersistenceStateChangeAlert()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) should not been implemented")
    }
    
    required init(environment: Environment, imageFetcher: ImageFetcher? = nil) {
        self.environment = environment
        self.imageFetcher = imageFetcher
        super.init(nibName: HeroDetailViewController.nibIdentifier, bundle: nil)
        
        self.detailViewModel = HeroDetailViewModel(environment: environment)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        configureLabels()
        configureCollectionView()
        detailViewModel.delegate = self
        
        let dataSource = configureDataSource()
        detailViewModel.dataSource = dataSource
        detailViewModel.character = character
        
        guard let character = character else { return }
        present(with: character)
    }
    
    func configureCollectionView() {
        resourcesCollectionView.delegate = self
        resourcesCollectionView.setCollectionViewLayout(CollectionViewLayoutGenerator.resourcesCollectionViewLayout(), animated: false)
        resourcesCollectionView.register(ResourceCell.self, forCellWithReuseIdentifier: ResourceCell.reuseIdentifier)
        resourcesCollectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: TitleSupplementaryView.elementKind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    }
    
    func present(with character: Character) {
        nameLabel.text = character.name
        descriptionLabel.text = character.description.isEmpty ? unavailableDescription : character.description
        favoriteButton.isSelected = environment.store.viewContext.hasPersistenceId(for: character)
        
        if let data = character.thumbnail?.data, let image = UIImage(data: data) {
            imageView.image = image
        } else {
            
            guard let imageFetcher = imageFetcher, let identifier = character.thumbnail?.absoluteString else { return }
            imageFetcher.image(for: identifier) { [weak imageView] image in
                guard let imageView = imageView, let image = image else { return }
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
    
    func configureLabels() {
        nameLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.adjustsFontForContentSizeCategory = true
        
        nameLabel.font = Theme.fonts.titleFont
        descriptionLabel.textColor = Theme.colors.secondaryLabelColor
        descriptionLabel.font = Theme.fonts.descriptionFont
    }
    
}

extension HeroDetailViewController: HeroDetailViewModelDelegate {
    
    func viewModelDidReceiveError(error: UserFriendlyError) {
        presentAlertWithError(message: error, callback: { _ in})
    }
    
    func viewModelDidTogglePersistentence(with status: Bool) {
        guard status else { return }
        animateFavoriteButtonSelection()
    }
    
    func animateFavoriteButtonSelection() {
        UIView.transition(with: favoriteButton,
                          duration: 0.26,
                          options: .transitionCrossDissolve,
                          animations: { self.favoriteButton.isSelected = !self.favoriteButton.isSelected },
                          completion: nil)
    }
    
    func presentPersistenceStateChangeAlert() {
        guard let message = detailViewModel.composeStateChangeMessage() else { return }
        
        switch message.state {
            case .persisted:
                presentAlertWithStateChange(message: message) { [weak self] status in
                    guard status, let self = self else { return }
                    
                    self.detailViewModel.toggleCharacterPersistenceState(with: message, data: self.imageView.image?.pngData())
                    self.navigationController?.popViewController(animated: true)
            }
            case .memory:
                self.detailViewModel.toggleCharacterPersistenceState(with: message, data: self.imageView.image?.pngData())
        }
        
    }
    
}


// MARK: - ResourcesCollectionView

extension HeroDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let resource = detailViewModel.dataSource?.itemIdentifier(for: indexPath)
        
        switch resource?.type {
            case .comic:
                let resourceDetailViewController = ComicDetailViewController()
                resourceDetailViewController.resource = resource
                resourceDetailViewController.environment = environment
                resourceDetailViewController.imageFetcher = imageFetcher
                
                let navController = UINavigationController(rootViewController: resourceDetailViewController)
                present(navController, animated: true)
            
            default:
                return
        }
        
        
    }
    
    private func configureDataSource() -> ResourceDataSource {
        
        let dataSource = ResourceDataSource(collectionView: resourcesCollectionView) { [weak self]
            (collectionView: UICollectionView, indexPath: IndexPath, resource: DisplayableResource) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResourceCell.reuseIdentifier, for: indexPath) as! ResourceCell
            cell.titleLabel.text = resource.title
            
            guard let identifier = resource.thumbnail?.absoluteString else {
                return cell
            }
            
            cell.representedIdentifier = identifier
            let image = self.imageFetcher?.cachedImage(for: identifier)
            
            switch image {
                case .some(let image): cell.update(image: image)
                
                default:
                    cell.update(image: nil)
                    self.imageFetcher?.image(for: identifier) { [weak self] image in
                        
                        guard cell.representedIdentifier == identifier, let image = image else {
                            self?.imageFetcher?.cancelFetch(identifier)
                            return
                        }
                        cell.update(image: image)
                }
            }
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = {
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let titleSupplementary = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath) as! TitleSupplementaryView
            
            let section = CollectionViewLayoutGenerator.ResourceSection(rawValue: indexPath.section)!
            titleSupplementary.label.text = section.sectionTitle
            
            return titleSupplementary
        }
        
        return dataSource
    }
    
}
