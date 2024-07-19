//
//  ResourceDetailViewModel.swift
//  Heroes
//
//  Created by Marcos Curvello on 22/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

protocol ComicDetailViewModelDelegate: NSObject {
    func viewModelDidReceiveData(details: ComicDetailViewModel.ComicDetails)
    func viewModelDidReceiveError(error: UserFriendlyError)
}

class ComicDetailViewModel: NSObject {
    
    struct ComicDetails {
        var title: String
        var summary: String?
        var releaseDate: String?
        var creators: String?
        var characters: String?
        var pages: String?
        var printPrice: String?
        var digitalPrice: String?
        var url: URL?
    }
    
    var resource: DisplayableResource! {
        didSet {
            configure()
        }
    }
    
    let environment: Environment!
    var resourceRequestManager: ResourceRequestManager?
    
    weak var delegate: ComicDetailViewModelDelegate?
    
    init(environment: Environment, delegate: ComicDetailViewModelDelegate) {
        self.environment = environment
        self.delegate = delegate
    }
    
    func configure() {
        resourceRequestManager = ResourceRequestManager(server: environment.server)
    }
    
    func request() {
        resourceRequestManager?.request(comic: resource!, completion: { [weak self] result in
            switch result {
                case .success(let comic): self?.configureComicDetail(comic: comic)
                case .failure(let error): self?.delegate?.viewModelDidReceiveError(error: error)
            }
        })
    }
    
    func configureComicDetail(comic: Comic) {
        
        var details = ComicDetails(title: comic.title)
        
        details.summary = comic.description
        details.characters = ListFormatter.localizedString(byJoining: (comic.characters?.items?.map { $0.name })!)
        details.creators = ListFormatter.localizedString(byJoining: (comic.creators?.items?.map { $0.name })!)
        details.pages = String(comic.pageCount!)
        
        if let onSaleDate = comic.dates?.onSaleDate() {
            guard let date = dateFormatter.date(from: onSaleDate.date) else { return }
            
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            
            let releaseDate = formatter.string(from: date)
            details.releaseDate = releaseDate
        }
        
        if let printPrice = comic.prices?.printPrice() {
            let prPrice = currencyFormatter.string(for: printPrice.price)
            details.printPrice = prPrice
        }
        
        if let digitalPurchasePrice = comic.prices?.digitalPurchasePrice() {
            let digPrice = currencyFormatter.string(for: digitalPurchasePrice.price)
            details.digitalPrice = digPrice
        }
        
        if let validUrl = comic.urls?.validComicUrl(), let url = URL(string: validUrl.url) {
            details.url = url
        }
        
        delegate?.viewModelDidReceiveData(details: details)
    }
    
}
