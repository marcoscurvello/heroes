//
//  SearchResultsReusableView.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class SearchResultsReusableView: UICollectionReusableView {
    static let elementKind = "search-results-kind"
    static let reuseIdentifier = "loader-reusable-identifier"
    
    let label = UILabel()
    let containerView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func presentInformation(info: String?) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.label.text = info
        }
    }
    
    func presentActivity() {
        label.text = nil
        activityIndicator.stopAnimating()
    }
    
    func configure() {
        activityIndicator.hidesWhenStopped = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                        
        containerView.addSubview(label)
        containerView.addSubview(activityIndicator)
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 44.0),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        presentActivity()
    }
    
}
