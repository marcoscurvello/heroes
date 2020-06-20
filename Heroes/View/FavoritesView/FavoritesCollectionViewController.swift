//
//  FavoritesCollectionViewController.swift
//  Heroes
//
//  Created by Marcos Curvello on 11/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit
import CoreData

class FavoritesCollectionViewController: UICollectionViewController {
    
    private let environment: Environment!
    private let favoritesViewModel: FavoritesViewControllerModel!
    
    required init?(coder: NSCoder) {
        self.environment = Environment(server: Server(), store: Store())
        self.favoritesViewModel = FavoritesViewControllerModel(environment: environment)
        super.init(coder: coder)
    }
    
    required init(environment: Environment, layout: UICollectionViewLayout) {
        self.environment = environment
        self.favoritesViewModel = FavoritesViewControllerModel(environment: environment)
        super.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = generateDataSource()
        favoritesViewModel.configureDataSource(with: dataSource)
        
        configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(HeroCell.self, forCellWithReuseIdentifier: HeroCell.reuseIdentifier)
    }
    
    func generateDataSource() -> HeroDataSource {
        
        let dataSource = HeroDataSource(collectionView: collectionView) { [weak self] (collectionView, indexPath, character) -> UICollectionViewCell?  in
            guard let self = self else { return nil }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroCell.reuseIdentifier, for: indexPath) as! HeroCell
            cell.favoriteButton.isSelected = self.environment.store.viewContext.hasPersistenceId(for: character)
            cell.character = character
            cell.delegate = self
                        
            if let data = character.thumbnail?.data, let image = UIImage(data: data) {
                cell.update(image: image)
            } else {
                cell.update(image: nil)
                
            }
            
            return cell
        }
        
        return dataSource
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let navigationController = navigationController else { return }
        
        let selectedCharacter = favoritesViewModel.item(for: indexPath)!
        let detailViewController = HeroDetailViewController(environment: environment)
        detailViewController.character = selectedCharacter
        detailViewController.state = .persisted
        
        detailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(detailViewController, animated: true)
    }
}


// MARK: - HeroCell Delegate


extension FavoritesCollectionViewController: HeroCellDelegate {
    
    func heroCellFavoriteButtonTapped(cell: HeroCell) {
        guard let character = cell.character else { return }        
        presentAlertWithStateChange(message: .deleteCharacter(with: character)) { [weak self] status in
            guard let self = self, let env = self.environment else { return }
            if status { env.store.toggleStorage(for: character, completion: { _ in}) }
        }
    }
    
}
