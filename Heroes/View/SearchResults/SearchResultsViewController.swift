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
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    init(layout: UICollectionViewLayout, searchViewModel: SearchResultsViewModel? = SearchResultsViewModel()) {
        super.init(collectionViewLayout: layout)
        self.searchViewModel = searchViewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchViewModel.searchInfoHandler = self
        configureCollectionView()
        configureDataSource()
    }
    
    func configureCollectionView() {
        let heroCell = UINib(nibName: HeroCell.nibIdentifier, bundle: nil)
        collectionView.register(heroCell, forCellWithReuseIdentifier: HeroCell.reuseIdentifier)
        collectionView.register(SearchReusableView.self, forSupplementaryViewOfKind: SearchReusableView.elementKind, withReuseIdentifier: SearchReusableView.reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
}

extension SearchResultsViewController: SearchResultsViewModelSearchHandler, UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let strippedString = searchController.searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces).lowercased()
        
        guard !strippedString.isEmpty && strippedString != searchViewModel.currentSearchResult?.query.textInput.value else {
            return
        }
        
        updateSearchActivity()
        
        searchViewModel.debouncer.debounce {
            self.searchViewModel.fetchCharactersWith(textInput: strippedString)
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
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchViewModel.resetSearchResultState()
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
            if let count = self?.searchViewModel.currentSearchResult?.data.count {
                searchResultInformation.presentInformation(count: count)
            } else {
                searchResultInformation.presentActivity()
            }
            self?.searchResultInformationView = searchResultInformation
            return searchResultInformation
        }
        
        DispatchQueue.global().async {
            self.searchViewModel.currentSnapshot = NSDiffableDataSourceSnapshot<SearchResultsViewController.Section, Character>()
            self.searchViewModel.currentSnapshot.appendSections(SearchResultsViewController.Section.allCases)
            self.searchViewModel.currentSnapshot.appendItems([], toSection: .results)
            self.searchViewModel.dataSource.apply(self.searchViewModel.currentSnapshot, animatingDifferences: false)
        }
    }
    
}

