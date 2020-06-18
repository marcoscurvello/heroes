//
//  MainTabbarController.swift
//  Heroes
//
//  Created by Marcos Curvello on 11/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit



class MainTabbarController: UITabBarController {
    
    enum Tab: Int, CaseIterable {
        case heroes, favorites
        var title: String {
            switch self {
            case .heroes: return "Heroes"
            case .favorites: return "Favorites"
            }
        }
        
        var image: UIImage {
            switch self {
            case .heroes: return UIImage(systemName: "list.dash")!
            case .favorites: return UIImage(systemName: "star")!
            }
        }
    }
    
    var environment: Environment!
    var imageFetcher: ImageFetcher!
    var charactersVC: HeroListViewController!
    var favoritesVC: FavoritesCollectionViewController!
    
    required init?(coder: NSCoder) {
        self.environment = Environment(server: Server(), store: Store())
        self.imageFetcher = ImageFetcher()
        super.init(coder: coder)
    }
    
    required init(environment: Environment?) {
        self.environment = environment
        self.imageFetcher = ImageFetcher()
        super.init(nibName: nil, bundle: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // MARK: - First Item
        
        charactersVC = HeroListViewController(environment: environment, imageFetcher: imageFetcher, layout: CollectionViewLayoutGenerator.generateLayoutForStyle(.paginated))
        
        let itemOneNavigation = UINavigationController(rootViewController: charactersVC)
        charactersVC.navigationController?.navigationBar.tintColor = .systemPurple
        charactersVC.navigationController?.navigationBar.prefersLargeTitles = true
        charactersVC.collectionView.backgroundColor = .systemBackground
        charactersVC.title = Tab.heroes.title
        
        let itemOne = UITabBarItem()
        itemOne.title = Tab.heroes.title
        itemOne.tag = Tab.heroes.rawValue
        itemOne.image = Tab.heroes.image
        charactersVC.tabBarItem = itemOne
        
        
        // MARK: - Second Item
        
        favoritesVC = FavoritesCollectionViewController(environment: environment, layout: CollectionViewLayoutGenerator.generateLayoutForStyle(.favorites))

        let itemTwoNavigation = UINavigationController(rootViewController: favoritesVC)
        favoritesVC.navigationController?.navigationBar.tintColor = .systemPurple
        favoritesVC.navigationController?.navigationBar.prefersLargeTitles = true
        favoritesVC.collectionView.backgroundColor = .systemBackground
        favoritesVC.title = Tab.favorites.title
        
        let itemTwo = UITabBarItem()
        itemTwo.title = Tab.favorites.title
        itemTwo.tag = Tab.favorites.rawValue
        itemTwo.image = Tab.favorites.image
        favoritesVC.tabBarItem = itemTwo

        
        // MARK: - Configuration
        
        tabBar.tintColor = .systemPurple
        viewControllers = [itemOneNavigation, itemTwoNavigation]
        
    }
    
}
