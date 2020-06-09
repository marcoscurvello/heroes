//
//  SearchResultsReusableView.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class SearchReusableView: UICollectionReusableView {
    
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
    
    func presentInformation(count: Int) {
        let info = count > 0 ? "\(count) heros found" : "No heros found"
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.label.text = info
        }
    }
    
    func presentActivity() {
        DispatchQueue.main.async {
            self.label.text = nil
            self.activityIndicator.startAnimating()
        }
    }
    
    func configure() {
        activityIndicator.hidesWhenStopped = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.preferredFont(forTextStyle: .body)
                        
        containerView.addSubview(label)
        containerView.addSubview(activityIndicator)
        addSubview(containerView)
    
        
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 44.0),
            
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -inset)
        ])
        
    }
    
}
