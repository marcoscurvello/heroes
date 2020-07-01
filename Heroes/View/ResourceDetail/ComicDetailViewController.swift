//
//  ComicDetailViewController.swift
//  Heroes
//
//  Created by Marcos Curvello on 22/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class ComicDetailViewController: UIViewController {
    
    private enum Title: String {
        case summary = "Summary"
        case creators = "Creators"
        case characters = "Characters"
        case relaseDate = "Release Date"
        case pages = "Pages"
        case printPrice = "Print Price"
        case digitalPrice = "Digital Price"
        case actionButton = "View at Marvel"
    }
    
    // MARK: - Captions
    let summaryLabelCaption = UILabel()
    let creatorsLabelCaption = UILabel()
    let charactersLabelCaption = UILabel()
    let releaseDateLabelCaption = UILabel()
    let pageCountLabelCaption = UILabel()
    let printPriceCaptionLabel = UILabel()
    let digitalPriceCaptionLabel = UILabel()

    
    // MARK: - Labels
    let titleLabel = UILabel()
    let summaryLabel = UILabel()
    let creatorsLabel = UILabel()
    let charactersLabel = UILabel()
    let releaseDateLabel = UILabel()
    let pageCountLabel = UILabel()
    let printPriceLabel = UILabel()
    let digitalPriceLabel = UILabel()
    
    
    // MARK: - Base
    let scrollView = UIScrollView()
    let contentView = UIView()
    let actionButton = UIButton()
    let activityIndicator = UIActivityIndicatorView()

    var environment: Environment?
    var imageFetcher: ImageFetcher?
    var resourceDetailViewModel: ComicDetailViewModel?
    
    var resourceURL: URL?
    var resource: DisplayableResource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comic Details"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.colors.primaryColor]
        
        configure()
        configureImageView()
        configureTitleLabel()
        configureSummary()
        configureCreators()
        configureCharacters()
        configureReleaseDate()
        configurePages()
        configurePrintPrice()
        configureDigitalPrice()
        configureActionButton()

        resourceDetailViewModel = ComicDetailViewModel(environment: environment!, delegate: self)
        resourceDetailViewModel!.resource = resource
        resourceDetailViewModel!.request()
    }
    
    // MARK: Default Values
    let innerSpacing = CGFloat(10)
    let outterSpacing = CGFloat(20)
    
    let defaultCaptionFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    let defaultBodyFont = UIFont.preferredFont(forTextStyle: .caption2).withSize(14.0)
    
    let defaultCaptionColor = UIColor.label
    let defaultBodyColor = UIColor.secondaryLabel
    
    
    // MARK: - UIScrollView
    private func configure() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        contentView.addSubview(activityIndicator)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(summaryLabel)
        contentView.addSubview(summaryLabelCaption)
        contentView.addSubview(creatorsLabel)
        contentView.addSubview(creatorsLabelCaption)
        contentView.addSubview(charactersLabel)
        contentView.addSubview(charactersLabelCaption)
        contentView.addSubview(releaseDateLabel)
        contentView.addSubview(releaseDateLabelCaption)
        contentView.addSubview(pageCountLabel)
        contentView.addSubview(pageCountLabelCaption)
        contentView.addSubview(printPriceLabel)
        contentView.addSubview(printPriceCaptionLabel)
        contentView.addSubview(digitalPriceLabel)
        contentView.addSubview(digitalPriceCaptionLabel)
        contentView.addSubview(actionButton)
        
        scrollView.addSubview(contentView)
        scrollView.showsVerticalScrollIndicator = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    
    // MARK: - UIImageView
    
    let imageView = UIImageView()
    
    private func configureImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 5.0
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        imageView.backgroundColor = Theme.colors.imageViewBackgroundColor
        imageView.image = placeholderResourceImage
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: outterSpacing),
            imageView.widthAnchor.constraint(equalToConstant: 138.0),
            imageView.heightAnchor.constraint(equalToConstant: 214.0),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    
    // MARK: - Title
    private func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.font = Theme.fonts.titleFont
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: outterSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: summaryLabelCaption.topAnchor, constant: -outterSpacing),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    // MARK: - Summary
    private func configureSummary() {
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabelCaption.translatesAutoresizingMaskIntoConstraints = false
        
        summaryLabelCaption.textAlignment = .left
        summaryLabelCaption.textColor = defaultCaptionColor
        summaryLabelCaption.font = defaultCaptionFont
        
        summaryLabel.numberOfLines = 0
        summaryLabel.textAlignment = .left
        summaryLabel.textColor = defaultBodyColor
        summaryLabel.font = defaultBodyFont

        NSLayoutConstraint.activate([
            summaryLabelCaption.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            summaryLabelCaption.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            summaryLabelCaption.bottomAnchor.constraint(equalTo: summaryLabel.topAnchor, constant: -innerSpacing),
            summaryLabel.leadingAnchor.constraint(equalTo: summaryLabelCaption.leadingAnchor),
            summaryLabel.trailingAnchor.constraint(equalTo: summaryLabelCaption.trailingAnchor)
        ])
    }
    
    
    // MARK: - Creators
    private func configureCreators() {
        creatorsLabelCaption.translatesAutoresizingMaskIntoConstraints = false
        creatorsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        creatorsLabelCaption.textAlignment = .left
        creatorsLabelCaption.textColor = defaultCaptionColor
        creatorsLabelCaption.font = defaultCaptionFont
        
        creatorsLabel.numberOfLines = 0
        creatorsLabel.textAlignment = .left
        creatorsLabel.textColor = defaultBodyColor
        creatorsLabel.font = defaultBodyFont
        
        NSLayoutConstraint.activate([
            creatorsLabelCaption.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: outterSpacing),
            creatorsLabelCaption.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            creatorsLabelCaption.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            creatorsLabelCaption.bottomAnchor.constraint(equalTo: creatorsLabel.topAnchor, constant: -innerSpacing),
            
            creatorsLabel.leadingAnchor.constraint(equalTo: creatorsLabelCaption.leadingAnchor),
            creatorsLabel.trailingAnchor.constraint(equalTo: creatorsLabelCaption.trailingAnchor),
            creatorsLabel.bottomAnchor.constraint(equalTo: charactersLabelCaption.topAnchor, constant: -outterSpacing)
        ])
    }
    
    // MARK: - Characters
    private func configureCharacters() {
        charactersLabelCaption.translatesAutoresizingMaskIntoConstraints = false
        charactersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        charactersLabelCaption.textAlignment = .left
        charactersLabelCaption.textColor = defaultCaptionColor
        charactersLabelCaption.font = defaultCaptionFont
        
        charactersLabel.numberOfLines = 0
        charactersLabel.textAlignment = .left
        charactersLabel.textColor = defaultBodyColor
        charactersLabel.font = defaultBodyFont
        
        NSLayoutConstraint.activate([
            charactersLabelCaption.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            charactersLabelCaption.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            charactersLabelCaption.bottomAnchor.constraint(equalTo: charactersLabel.topAnchor, constant: -innerSpacing),
            
            charactersLabel.leadingAnchor.constraint(equalTo: charactersLabelCaption.leadingAnchor),
            charactersLabel.trailingAnchor.constraint(equalTo: charactersLabelCaption.trailingAnchor),
            charactersLabel.bottomAnchor.constraint(equalTo: releaseDateLabelCaption.topAnchor, constant: -outterSpacing)
        ])
    }
    
    // MARK: - Release Date
    private func configureReleaseDate() {
        releaseDateLabelCaption.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        releaseDateLabelCaption.textAlignment = .left
        releaseDateLabelCaption.textColor = defaultCaptionColor
        releaseDateLabelCaption.font = defaultCaptionFont
        
        releaseDateLabel.textAlignment = .left
        releaseDateLabel.textColor = defaultBodyColor
        releaseDateLabel.font = defaultBodyFont
        
        NSLayoutConstraint.activate([
            releaseDateLabelCaption.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            releaseDateLabelCaption.trailingAnchor.constraint(equalTo: pageCountLabelCaption.leadingAnchor, constant: -outterSpacing),
            releaseDateLabelCaption.bottomAnchor.constraint(equalTo: releaseDateLabel.topAnchor, constant: -innerSpacing),
            
            releaseDateLabel.leadingAnchor.constraint(equalTo: releaseDateLabelCaption.leadingAnchor),
            releaseDateLabel.trailingAnchor.constraint(equalTo: releaseDateLabelCaption.trailingAnchor),
            releaseDateLabel.bottomAnchor.constraint(equalTo: pageCountLabel.bottomAnchor)
        ])
    }
    
    // MARK: - Pages
    private func configurePages() {
        pageCountLabelCaption.translatesAutoresizingMaskIntoConstraints = false
        pageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        pageCountLabelCaption.textAlignment = .left
        pageCountLabelCaption.textColor = defaultCaptionColor
        pageCountLabelCaption.font = defaultCaptionFont
        
        pageCountLabel.textAlignment = .left
        pageCountLabel.textColor = defaultBodyColor
        pageCountLabel.font = defaultBodyFont
        
        NSLayoutConstraint.activate([
            pageCountLabelCaption.leadingAnchor.constraint(equalTo: releaseDateLabelCaption.trailingAnchor, constant: outterSpacing),
            pageCountLabelCaption.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            pageCountLabelCaption.bottomAnchor.constraint(equalTo: pageCountLabel.topAnchor, constant: -innerSpacing),
            
            pageCountLabel.leadingAnchor.constraint(equalTo: pageCountLabelCaption.leadingAnchor),
            pageCountLabel.trailingAnchor.constraint(equalTo: pageCountLabelCaption.trailingAnchor),
            pageCountLabel.bottomAnchor.constraint(equalTo: printPriceCaptionLabel.topAnchor, constant: -outterSpacing)
        ])
    }
    
    // MARK: - Print Price
    private func configurePrintPrice() {
        printPriceCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        printPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        printPriceCaptionLabel.textAlignment = .left
        printPriceCaptionLabel.textColor = defaultCaptionColor
        printPriceCaptionLabel.font = defaultCaptionFont
        
        printPriceLabel.textAlignment = .left
        printPriceLabel.textColor = defaultBodyColor
        printPriceLabel.font = defaultBodyFont
        
        NSLayoutConstraint.activate([
            printPriceCaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            printPriceCaptionLabel.trailingAnchor.constraint(equalTo: pageCountLabelCaption.leadingAnchor, constant: -outterSpacing),
            printPriceCaptionLabel.bottomAnchor.constraint(equalTo: printPriceLabel.topAnchor, constant: -innerSpacing),
            
            printPriceLabel.leadingAnchor.constraint(equalTo: printPriceCaptionLabel.leadingAnchor),
            printPriceLabel.trailingAnchor.constraint(equalTo: printPriceCaptionLabel.trailingAnchor),
            printPriceLabel.bottomAnchor.constraint(lessThanOrEqualTo: actionButton.topAnchor, constant: -outterSpacing)
        ])
    }
    
    
    // MARK: - Digital Price
    private func configureDigitalPrice() {
        digitalPriceCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        digitalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        digitalPriceCaptionLabel.textAlignment = .left
        digitalPriceCaptionLabel.textColor = defaultCaptionColor
        digitalPriceCaptionLabel.font = defaultCaptionFont
        
        digitalPriceLabel.textAlignment = .left
        digitalPriceLabel.textColor = defaultBodyColor
        digitalPriceLabel.font = defaultBodyFont
        
        NSLayoutConstraint.activate([
            digitalPriceCaptionLabel.leadingAnchor.constraint(equalTo: printPriceCaptionLabel.trailingAnchor, constant: outterSpacing),
            digitalPriceCaptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            digitalPriceCaptionLabel.bottomAnchor.constraint(equalTo: digitalPriceLabel.topAnchor, constant: -innerSpacing),
            digitalPriceCaptionLabel.widthAnchor.constraint(equalTo: printPriceCaptionLabel.widthAnchor),
            digitalPriceCaptionLabel.centerYAnchor.constraint(equalTo: printPriceCaptionLabel.centerYAnchor),
            
            digitalPriceLabel.leadingAnchor.constraint(equalTo: digitalPriceCaptionLabel.leadingAnchor),
            digitalPriceLabel.trailingAnchor.constraint(equalTo: digitalPriceCaptionLabel.trailingAnchor)
        ])
    }
    
    
    // MARK: - Action Button
    private func configureActionButton() {
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.layer.cornerRadius = 10.0
        
        actionButton.setTitle(Title.actionButton.rawValue, for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel!.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        actionButton.addTarget(self, action: #selector(followResourceURL), for: .touchUpInside)
        actionButton.isEnabled = false
        actionButton.clipsToBounds = true
        actionButton.backgroundColor = .systemGray5
        
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -outterSpacing),
            actionButton.heightAnchor.constraint(equalToConstant: 50.0)
        ])
    }
    
    @objc private func followResourceURL() {
        guard let url = resourceURL else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - Present Data
    
    func present(with details: ComicDetailViewModel.ComicDetails) {
        activityIndicator.stopAnimating()
        
        titleLabel.text = details.title
        
        if let summary = details.summary {
            summaryLabelCaption.text = Title.summary.rawValue
            summaryLabel.text = summary
        }
        
        if let creators = details.creators {
            creatorsLabelCaption.text = Title.creators.rawValue
            creatorsLabel.text = creators
        }
        
        if let characters = details.characters {
            charactersLabelCaption.text = Title.characters.rawValue
            charactersLabel.text = characters
        }
        
        if let releaseDate = details.releaseDate {
            releaseDateLabelCaption.text = Title.relaseDate.rawValue
            releaseDateLabel.text = releaseDate
        }
        
        if let pageCount = details.pages {
            pageCountLabelCaption.text = Title.pages.rawValue
            pageCountLabel.text = pageCount
        }
        
        if let printPrice = details.printPrice {
            printPriceCaptionLabel.text = Title.printPrice.rawValue
            printPriceLabel.text = printPrice
        }
        
        if let digitalPrice = details.digitalPrice {
            digitalPriceCaptionLabel.text = Title.digitalPrice.rawValue
            digitalPriceLabel.text = digitalPrice
        }
        
        if let inAppUrl = details.url {
            self.resourceURL = inAppUrl
            actionButton.isEnabled = true
            actionButton.backgroundColor = Theme.colors.primaryColor
        }
        
        guard let imageFetcher = imageFetcher, let identifier = resource?.thumbnail?.absoluteString else { return }
        
        imageFetcher.image(for: identifier) { [weak imageView] image in
            guard let image = image else { return }
            DispatchQueue.main.async {
                imageView?.image = image
                imageView?.contentMode = .scaleToFill
            }
        }
    }
    
}

// MARK: - ComicDetailViewModelDelegate

extension ComicDetailViewController: ComicDetailViewModelDelegate {
    
    func viewModelDidReceiveData(details: ComicDetailViewModel.ComicDetails) {
        DispatchQueue.main.async {
            self.present(with: details)
        }
    }
    
    func viewModelDidReceiveError(error: UserFriendlyError) {
        presentAlertWithError(message: error, callback: { _ in})
    }
    
}
