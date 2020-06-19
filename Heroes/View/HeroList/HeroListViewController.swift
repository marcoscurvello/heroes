//
//  HeroListViewController.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class HeroListViewController: UICollectionViewController {

    private let environment: Environment!
    private let imageFetcher: ImageFetcher!
    
    private var viewModel: HeroListViewModel!
    private var searchResultsViewModel: SearchResultsViewModel!
    private var detailViewController: HeroDetailViewController?

    var searchController: UISearchController!
    var searchResultsViewController: SearchResultsViewController!
    
    required init?(coder: NSCoder) {
        self.environment = Environment(server: Server(), store: Store())
        self.imageFetcher = ImageFetcher()
        super.init(coder: coder)
    }
    
    required init(environment: Environment, imageFetcher: ImageFetcher, layout: UICollectionViewLayout) {
        self.environment = environment
        self.imageFetcher = imageFetcher
        super.init(collectionViewLayout: layout)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = HeroListViewModel(environment: environment)
        searchResultsViewModel = SearchResultsViewModel(environment: environment)
        defer { viewModel.requestData() }
        
        let dataSource = generateDataSource(for: collectionView)
        viewModel.configureDataSource(with: dataSource)
        viewModel.errorHandler = self
        
        configureCollectionView()
        configureSearch()
        
        let searchDataSource = generateDataSource(for: searchResultsViewController.collectionView)
        searchResultsViewModel.configureDataSource(with: searchDataSource)
        searchResultsViewModel.errorHandler = self
    }
        
    func configureCollectionView() {
        collectionView.register(HeroCell.self, forCellWithReuseIdentifier: HeroCell.reuseIdentifier)
        collectionView.register(LoaderReusableView.self, forSupplementaryViewOfKind: LoaderReusableView.elementKind, withReuseIdentifier: LoaderReusableView.reuseIdentifier)
    }
        
    func configureSearch() {
        searchResultsViewController = SearchResultsViewController(collectionViewLayout: CollectionViewLayoutGenerator.generateLayoutForStyle(.search))
        searchResultsViewController.searchResultsViewModel = searchResultsViewModel
        searchResultsViewController.collectionView.delegate = self

        searchController = UISearchController(searchResultsController: searchResultsViewController)
        searchController.searchResultsUpdater = searchResultsViewController
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Who are your heroes?"
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
    
}

// MARK: - UICollectionViewDelegate

extension HeroListViewController {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch collectionView {
        case self.collectionView: viewModel.shouldFetchData(index: indexPath.item)
        case searchResultsViewController.collectionView: searchResultsViewModel.shouldFetchData(index: indexPath.item)
        default: return
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let navigationController = navigationController else { return }
        
        let selectedCharacter: Character!
        
        switch collectionView {
        case self.collectionView: selectedCharacter = viewModel.item(for: indexPath)
        case searchResultsViewController.collectionView: selectedCharacter = searchResultsViewModel.item(for: indexPath)
        default: return
        }
        
        let detailViewController = HeroDetailViewController(environment: environment, imageFetcher: imageFetcher)
        detailViewController.character = selectedCharacter
        detailViewController.state = .memory
            
        detailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
}


// MARK: - HeroCell Delegate

extension HeroListViewController: HeroCellDelegate {
    
    func heroCellFavoriteButtonTapped(cell: HeroCell) {
        guard let character = cell.character else { return }
        let imageData = cell.imageView.image?.pngData()
        environment.store.toggleStorage(for: character, with: imageData, completion: { _ in})
    }

}


// MARK: - Error Handlers

extension HeroListViewController: HeroListViewModelErrorHandler, SearchResultsViewModelErrorHandler {
    
    func viewModelDidReceiveError(error: UserFriendlyError) {
        presentAlertWithError(message: error, callback: {_ in})
    }
    
}


// MARK: - Data Source Generator

extension HeroListViewController {
    
    public func generateDataSource(for collectionView: UICollectionView) -> HeroDataSource {

        let dataSource = HeroDataSource(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, character) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroCell.reuseIdentifier, for: indexPath) as! HeroCell
            cell.favoriteButton.isSelected = self.environment.store.viewContext.hasPersistenceId(for: character)
            cell.character = character
            cell.delegate = self

            guard let identifier = character.thumbnail?.absoluteString else { return cell }
            cell.representedIdentifier = identifier
            
            self.imageFetcher.image(for: identifier) { [weak cell] image in
                guard let cell = cell, cell.representedIdentifier == identifier else {
                    return self.imageFetcher.cancelFetch(identifier)
                }
                cell.update(image: image)
            }
            return cell

        })
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            switch kind {
            case LoaderReusableView.elementKind:
                let loaderSuplementary = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LoaderReusableView.reuseIdentifier, for: indexPath) as! LoaderReusableView
                return loaderSuplementary
            case SearchReusableView.elementKind:
                let searchSuplementary = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SearchReusableView.reuseIdentifier, for: indexPath) as! SearchReusableView
                self?.searchResultsViewController.searchInfoView = searchSuplementary
                return searchSuplementary
            default:
                return nil
            }
        }
        
        return dataSource
    }
    
}
