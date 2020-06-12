//
//  SearchResultsViewController.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class SearchResultsViewController: UICollectionViewController {
    
    enum Section: CaseIterable { case results }
    
    let imageFetcher = ImageFetcher.shared
    var searchViewModel: SearchResultsViewModel!
    var searchResultInformationView: SearchReusableView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init(layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchViewModel.infoHandler = self
        
        configureCollectionView()
        configureDataSource()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(UINib(nibName: HeroCell.nibIdentifier, bundle: nil), forCellWithReuseIdentifier: HeroCell.reuseIdentifier)
        collectionView.register(SearchReusableView.self, forSupplementaryViewOfKind: SearchReusableView.elementKind, withReuseIdentifier: SearchReusableView.reuseIdentifier)
    }
    
}

extension SearchResultsViewController: SearchResultsViewModelInformationandler, UISearchResultsUpdating, UISearchControllerDelegate {
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchViewModel.resetSearchResultState()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else {
            return
        }
        
        searchViewModel.debouncer.debounce { [unowned self] in
            guard let searchQuery = self.searchViewModel.composeSearchQuery(with: text) else {
                return
            }
            self.updateSearchActivity()
            self.searchViewModel.fetchWithQuery(searchQuery: searchQuery)
        }
    }
    
    func updateSearchActivity() {
        guard let searchInformationView = searchResultInformationView else { return }
        searchInformationView.presentActivity()
    }
    
    func updateSearchResult(with count: Int) {
        guard let searchInformationView = searchResultInformationView else { return }
        searchInformationView.presentInformation(count: count)
    }
    
}


extension SearchResultsViewController {
    
    private func configureDataSource() {
        searchViewModel.dataSource = UICollectionViewDiffableDataSource<SearchResultsViewController.Section, Character>(collectionView: collectionView) { [weak imageFetcher]
            (collectionView: UICollectionView, indexPath: IndexPath, character: Character) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroCell.reuseIdentifier, for: indexPath) as! HeroCell
            let identifier = character.thumbnail!.absoluteString
            cell.character = character
            cell.representedIdentifier = identifier
            
            if let cachedImage = imageFetcher?.cachedImage(for: identifier) {
                cell.display(image: cachedImage)
            } else {
                cell.display(image: nil)
                
                imageFetcher?.fetchAsync(identifier) { [weak cell] image in
                    guard let theCell = cell, theCell.representedIdentifier == identifier else { return }
                    theCell.display(image: image)
                }
            }
            return cell
        }
        
        searchViewModel.dataSource.supplementaryViewProvider = { [weak self]
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let searchResultInformation = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SearchReusableView.reuseIdentifier, for: indexPath) as! SearchReusableView
            if let count = self?.searchViewModel.currentSearchResult?.total {
                searchResultInformation.presentInformation(count: count)
            } else {
                searchResultInformation.presentActivity()
            }
            self?.searchResultInformationView = searchResultInformation
            return searchResultInformation
        }
    }
    
}

