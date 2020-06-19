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
    
    enum State { case memory, persisted }
    var state: State = .memory
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
        self.environment = Environment(server: Server(), store: Store())
        self.imageFetcher = ImageFetcher()
        super.init(coder: coder)
        self.detailViewModel = HeroDetailViewModel(environment: environment, imageFetcher: imageFetcher)
    }
    
    required init(environment: Environment, imageFetcher: ImageFetcher? = nil) {
        self.environment = environment
        self.imageFetcher = imageFetcher
        super.init(nibName: HeroDetailViewController.nibIdentifier, bundle: nil)
        self.detailViewModel = HeroDetailViewModel(environment: environment, imageFetcher: imageFetcher)
    }
    
    override func viewDidLoad() {
        navigationItem.largeTitleDisplayMode = .never
        super.viewDidLoad()
        
        configureLabels()
        configureCollectionView()
        detailViewModel.delegate = self
        
        let dataSource = configureDataSource()
        detailViewModel.dataSource = dataSource
  
        guard let character = character else {
            return
        }
        
        present(with: character)
        detailViewModel.configureResourceRequests(with: character.id)
        detailViewModel.requestCharacterData()
    }
    
    func configureCollectionView() {
        resourcesCollectionView.setCollectionViewLayout(CollectionViewLayoutGenerator.resourcesCollectionViewLayout(), animated: false)
        resourcesCollectionView.register(ComicCell.self, forCellWithReuseIdentifier: ComicCell.reuseIdentifier)
        resourcesCollectionView.register(ResourceCell.self, forCellWithReuseIdentifier: ResourceCell.reuseIdentifier)
        resourcesCollectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: TitleSupplementaryView.elementKind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    }
    
    
    func present(with character: Character) {
        nameLabel.text = character.name
        descriptionLabel.text = character.description.isEmpty ? Character.defaultDescription : character.description
        favoriteButton.isSelected = environment.store.viewContext.hasPersistenceId(for: character)
        
        if let data = character.thumbnail?.data, let image = UIImage(data: data) {
            imageView.image = image
        } else {
            guard let imageFetcher = imageFetcher else { return }
            let identifier = character.thumbnail?.absoluteString
            
            imageFetcher.image(for: identifier!) { [weak imageView] image in
                guard let imageView = imageView else { return }
                imageView.image = image
            }
        }
    }
    
    func configureLabels() {
        nameLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.adjustsFontForContentSizeCategory = true

        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .caption2).withSize(14.0)
        
        let titleSize = CGFloat(20.0)
        let titleWeight: UIFont.Weight = .semibold
        
        if let titleDescriptor = UIFont.systemFont(ofSize: titleSize, weight: titleWeight).fontDescriptor.withDesign(.rounded) {
            nameLabel.font = UIFont(descriptor: titleDescriptor, size: 0.0)
        } else {
            nameLabel.font = .systemFont(ofSize: titleSize, weight: titleWeight)
        }
    }
    
}

extension HeroDetailViewController {
    
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
            self.imageFetcher?.image(for: identifier) { [weak cell] image in
                guard let cell = cell, cell.representedIdentifier == identifier else {
                    self.imageFetcher?.cancelFetch(identifier)
                    return
                }
                cell.update(image: image)
            }
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = {
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let titleSupplementary = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath) as! TitleSupplementaryView
            let section = ResourceDataSource.LayoutSection(rawValue: indexPath.section)!
            titleSupplementary.label.text = section.sectionTitle
            
            return titleSupplementary
        }
        
        return dataSource
    }
    
}

extension HeroDetailViewController: HeroDetailViewModelDelegate {
    
    func viewModelDidReceiveError(error: UserFriendlyError) {
        presentAlertWithError(message: error, callback: { _ in})
    }
    
    func viewModelDidTogglePersistentence(with status: Bool) {
        guard status else { return }
        UIView.animate(withDuration: 3.0) {
            self.favoriteButton.isSelected = !self.favoriteButton.isSelected
        }
    }
    
    func composeStateChangeMessage() -> StateChangeMessage? {
        guard let character = character else { return nil}
        let message: StateChangeMessage!
        
        switch state {
        case .memory: message = .deleteCharacter(.memory, with: character)
        case .persisted: message = .deleteCharacter(.persisted, with: character)
        }
        
        return message
    }
    
    func presentPersistenceStateChangeAlert() {
        guard let message = composeStateChangeMessage() else { return }
        
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
