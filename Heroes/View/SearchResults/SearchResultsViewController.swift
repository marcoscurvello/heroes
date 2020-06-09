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
