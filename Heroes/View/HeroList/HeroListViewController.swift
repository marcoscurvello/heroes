//
//  HeroListViewController.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class HeroListViewController: UICollectionViewController {
    
    enum Section { case main }
    let imageFetcher = ImageFetcher.shared
    var viewModel: HeroListViewModel!
    var searchViewModel: SearchResultsViewModel!
    var searchResultsController: SearchResultsViewController!
    var searchController: UISearchController!
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    init(layout: UICollectionViewLayout, viewModel: HeroListViewModel? = HeroListViewModel(), searchViewModel: SearchResultsViewModel? = SearchResultsViewModel()) {
        super.init(collectionViewLayout: layout)
        self.viewModel = viewModel
        self.searchViewModel = searchViewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Heroes"
        navigationController!.navigationBar.prefersLargeTitles = true
        
        configureCollectionView()
        configureDataSource()
        configureSearch()
        
        viewModel.errorHandler = self
        searchViewModel.errorHandler = self
        viewModel.fetchCharacters()
    }
    
    func configureCollectionView() {
        let heroCell = UINib(nibName: HeroCell.nibIdentifier, bundle: nil)
        collectionView.register(heroCell, forCellWithReuseIdentifier: HeroCell.reuseIdentifier)
        collectionView.register(LoaderReusableView.self, forSupplementaryViewOfKind: LoaderReusableView.elementKind, withReuseIdentifier: LoaderReusableView.reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
    }
    
    func configureSearch() {
        searchResultsController = SearchResultsViewController(layout: CollectionViewLayoutGenerator.generateLayoutForStyle(.search))
        searchResultsController.searchViewModel = searchViewModel
        searchResultsController.collectionView.delegate = self
        searchResultsController.collectionView.prefetchDataSource = self
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.delegate = searchResultsController
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Who are your heroes?"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
}

extension HeroListViewController {
    
    private func configureDataSource() {
        viewModel.dataSource = UICollectionViewDiffableDataSource<HeroListViewController.Section, Character>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, character: Character) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroCell.reuseIdentifier, for: indexPath) as! HeroCell
            let identifier = character.thumbnail!.absoluteString
            cell.character = character
            cell.representedIdentifier = identifier
            
            if let cachedImage = self.imageFetcher.cachedImage(for: identifier) {
                cell.display(image: cachedImage)
            } else {
                cell.display(image: nil)
                self.imageFetcher.fetchAsync(identifier) { [weak cell] image in
                    guard let theCell = cell, theCell.representedIdentifier == identifier else { return }
                    theCell.display(image: image)
                }
            }
            return cell
        }
        
        viewModel.dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            if let loaderSuplementary = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LoaderReusableView.reuseIdentifier, for: indexPath) as? LoaderReusableView {
                loaderSuplementary.activityIndicator.startAnimating()
                return loaderSuplementary
            }
            return nil
        }
        
        viewModel.currentSnapshot = NSDiffableDataSourceSnapshot<HeroListViewController.Section, Character>()
        viewModel.currentSnapshot.appendSections([.main])
        viewModel.currentSnapshot.appendItems([], toSection: .main)
    }
    
}

extension HeroListViewController {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == searchResultsController.collectionView {
            if searchViewModel.currentSnapshot.numberOfItems == indexPath.item + 1 && searchViewModel.hasNextPage && searchViewModel.state == .ready {
                searchViewModel.fetchCharactersWith(textInput: nil)
            }
        } else {
            if viewModel.currentSnapshot.numberOfItems == indexPath.item + 1 && viewModel.hasNextPage && viewModel.state == .ready { viewModel.fetchCharacters() }
        }        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let navigationController = self.navigationController else { return }
        
        let character: Character!
        if collectionView == searchResultsController.collectionView {
            character = searchViewModel.dataSource.itemIdentifier(for: indexPath)
        } else {
            character = viewModel.dataSource.itemIdentifier(for: indexPath)
        }
        
        let detailViewController = HeroDetailViewController(character: character)
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
}

extension HeroListViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        for indexPath in indexPaths {
            if collectionView == searchResultsController.collectionView, let identifier = searchViewModel.dataSource.itemIdentifier(for: indexPath)?.thumbnail {
                imageFetcher.fetchAsync(identifier.absoluteString)
            } else {
                if let identifier = viewModel.dataSource.itemIdentifier(for: indexPath)?.thumbnail {
                    imageFetcher.fetchAsync(identifier.absoluteString)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if collectionView == searchResultsController.collectionView, let identifier = searchViewModel.dataSource.itemIdentifier(for: indexPath)?.thumbnail {
                imageFetcher.cancelFetch(identifier.absoluteString)
            } else {
                if let identifier = viewModel.dataSource.itemIdentifier(for: indexPath)?.thumbnail {
                    imageFetcher.cancelFetch(identifier.absoluteString)
                }
            }
            
        }
    }
    
}

extension HeroListViewController: HeroListViewModelErrorHandler, SearchResultsViewModelErrorHandler {
    
    func viewModelDidReceiveError(error: UserFriendlyError) {
        self.presentAlertWithMessage(message: error)
    }
    
    func presentAlertWithMessage(message: UserFriendlyError) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: message.title, message: message.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
