//
//  SearchResultsViewController.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class SearchResultsViewController: UICollectionViewController {
        
    var searchResultsViewModel: SearchResultsViewModel!
    var searchInfoView: SearchReusableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResultsViewModel.infoHandler = self
        configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(HeroCell.self, forCellWithReuseIdentifier: HeroCell.reuseIdentifier)
        collectionView.register(SearchReusableView.self, forSupplementaryViewOfKind: SearchReusableView.elementKind, withReuseIdentifier: SearchReusableView.reuseIdentifier)
    }

}

extension SearchResultsViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let strippedString = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces), !strippedString.isEmpty else {
            return
        }
        
        searchResultsViewModel.performSearch(with: strippedString)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchResultsViewModel.resetSearchResultState()
    }
    
}

extension SearchResultsViewController: SearchResultsViewModelInformationandler {
    
    func presentSearchResult(with count: Int) {
        guard let searchInfoView = searchInfoView else { return }
        searchInfoView.presentInformation(count: count)
    }
    
    func presentSearchActivity() {
        guard let searchInfoView = searchInfoView else { return }
        searchInfoView.presentActivity()
    }
    
}
