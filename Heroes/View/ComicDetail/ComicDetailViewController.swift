//
//  ComicDetailViewController.swift
//  Heroes
//
//  Created by Marcos Curvello on 22/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class ComicDetailViewController: UIViewController {
    
    private enum Titles: String {
        case summary = "Summary"
        case creators = "Creators"
        case characters = "Characters"
        case relaseDate = "Release Date"
        case pages = "Pages"
        case printPrice = "Print Price"
        case digitalPrice = "Digital Price"
        case actionButton = "View at Marvel"
    }
    
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
        activateConstraints()
        
        resourceDetailViewModel = ComicDetailViewModel(environment: environment!, delegate: self)
        resourceDetailViewModel!.resource = resource
        resourceDetailViewModel!.request()
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate(imageViewConstraints)
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(summaryConstraints)
        NSLayoutConstraint.activate(creatorsConstraints)
        NSLayoutConstraint.activate(charactersConstraints)
        NSLayoutConstraint.activate(releaseDateConstraints)
        NSLayoutConstraint.activate(pagesConstraints)
        NSLayoutConstraint.activate(printPriceConstraints)
        NSLayoutConstraint.activate(digitalPriceConstraints)
        NSLayoutConstraint.activate(actionButtonConstraints)
    }
    
    let innerSpacing = CGFloat(10)
    let outterSpacing = CGFloat(20)
    
    let defaultCaptionFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    let defaultBodyFont = UIFont.preferredFont(forTextStyle: .caption2).withSize(14.0)
    
    let defaultCaptionColor = UIColor.label
    let defaultBodyColor = UIColor.secondaryLabel
    
    // MARK: - UIScrollView
    
    let contentView = UIView()
    let scrollView = UIScrollView()
    let activityIndicator = UIActivityIndicatorView()
    
    private func configure() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        contentView.addSubview(activityIndicator)
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
    var imageViewConstraints = [NSLayoutConstraint]()
    
    private func configureImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 5.0
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        imageView.backgroundColor = Theme.colors.imageViewBackgroundColor
        imageView.image = placeholderResourceImage
        
        imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: outterSpacing),
            imageView.widthAnchor.constraint(equalToConstant: 138.0),
            imageView.heightAnchor.constraint(equalToConstant: 214.0),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ]
        
        contentView.addSubview(imageView)
    }
    
    
    // MARK: - UILabel Title
    
    let titleLabel = UILabel()
    var titleLabelConstraints = [NSLayoutConstraint]()
    
    private func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.font = Theme.fonts.titleFont
        
        titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: outterSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: summaryLabelCaption.topAnchor, constant: -outterSpacing),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ]
        
        contentView.addSubview(titleLabel)
    }
    
    // MARK: - UILabel Summary
    
    let summaryLabel = UILabel()
    let summaryLabelCaption = UILabel()
    var summaryConstraints = [NSLayoutConstraint]()
    
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
        
        summaryConstraints = [
            summaryLabelCaption.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            summaryLabelCaption.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            summaryLabelCaption.bottomAnchor.constraint(equalTo: summaryLabel.topAnchor, constant: -innerSpacing),
            summaryLabel.leadingAnchor.constraint(equalTo: summaryLabelCaption.leadingAnchor),
            summaryLabel.trailingAnchor.constraint(equalTo: summaryLabelCaption.trailingAnchor),
        ]
        
        contentView.addSubview(summaryLabel)
        contentView.addSubview(summaryLabelCaption)
    }
    
    
    // MARK: - UILabel Creators
    
    let creatorsLabel = UILabel()
    let creatorsLabelCaption = UILabel()
    var creatorsConstraints = [NSLayoutConstraint]()
    
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
        
        creatorsConstraints = [
            creatorsLabelCaption.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: outterSpacing),
            creatorsLabelCaption.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            creatorsLabelCaption.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            creatorsLabelCaption.bottomAnchor.constraint(equalTo: creatorsLabel.topAnchor, constant: -innerSpacing),
            
            creatorsLabel.leadingAnchor.constraint(equalTo: creatorsLabelCaption.leadingAnchor),
            creatorsLabel.trailingAnchor.constraint(equalTo: creatorsLabelCaption.trailingAnchor),
            creatorsLabel.bottomAnchor.constraint(equalTo: charactersLabelCaption.topAnchor, constant: -outterSpacing)
        ]
        
        contentView.addSubview(creatorsLabel)
        contentView.addSubview(creatorsLabelCaption)
    }
    
    // MARK: - UILabel  Characters
    
    let charactersLabel = UILabel()
    let charactersLabelCaption = UILabel()
    var charactersConstraints = [NSLayoutConstraint]()
    
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
        
        charactersConstraints = [
            charactersLabelCaption.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            charactersLabelCaption.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            charactersLabelCaption.bottomAnchor.constraint(equalTo: charactersLabel.topAnchor, constant: -innerSpacing),
            
            charactersLabel.leadingAnchor.constraint(equalTo: charactersLabelCaption.leadingAnchor),
            charactersLabel.trailingAnchor.constraint(equalTo: charactersLabelCaption.trailingAnchor),
            charactersLabel.bottomAnchor.constraint(equalTo: releaseDateLabelCaption.topAnchor, constant: -outterSpacing)
        ]
        
        contentView.addSubview(charactersLabel)
        contentView.addSubview(charactersLabelCaption)
    }
    
    // MARK: - UILabel Release Date
    
    let releaseDateLabel = UILabel()
    let releaseDateLabelCaption = UILabel()
    var releaseDateConstraints = [NSLayoutConstraint]()
    
    private func configureReleaseDate() {
        releaseDateLabelCaption.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        releaseDateLabelCaption.textAlignment = .left
        releaseDateLabelCaption.textColor = defaultCaptionColor
        releaseDateLabelCaption.font = defaultCaptionFont
        
        releaseDateLabel.textAlignment = .left
        releaseDateLabel.textColor = defaultBodyColor
        releaseDateLabel.font = defaultBodyFont
        
        releaseDateConstraints = [
            releaseDateLabelCaption.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            releaseDateLabelCaption.trailingAnchor.constraint(equalTo: pageCountLabelCaption.leadingAnchor, constant: -outterSpacing),
            releaseDateLabelCaption.bottomAnchor.constraint(equalTo: releaseDateLabel.topAnchor, constant: -innerSpacing),
            
            releaseDateLabel.leadingAnchor.constraint(equalTo: releaseDateLabelCaption.leadingAnchor),
            releaseDateLabel.trailingAnchor.constraint(equalTo: releaseDateLabelCaption.trailingAnchor),
            releaseDateLabel.bottomAnchor.constraint(equalTo: pageCountLabel.bottomAnchor)
        ]
        
        contentView.addSubview(releaseDateLabel)
        contentView.addSubview(releaseDateLabelCaption)
    }
    
    // MARK: - UILabel Pages
    
    let pageCountLabel = UILabel()
    let pageCountLabelCaption = UILabel()
    var pagesConstraints = [NSLayoutConstraint]()
    
    private func configurePages() {
        pageCountLabelCaption.translatesAutoresizingMaskIntoConstraints = false
        pageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        pageCountLabelCaption.textAlignment = .left
        pageCountLabelCaption.textColor = defaultCaptionColor
        pageCountLabelCaption.font = defaultCaptionFont
        
        pageCountLabel.textAlignment = .left
        pageCountLabel.textColor = defaultBodyColor
        pageCountLabel.font = defaultBodyFont
        
        pagesConstraints = [
            pageCountLabelCaption.leadingAnchor.constraint(equalTo: releaseDateLabelCaption.trailingAnchor, constant: outterSpacing),
            pageCountLabelCaption.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            pageCountLabelCaption.bottomAnchor.constraint(equalTo: pageCountLabel.topAnchor, constant: -innerSpacing),
            
            pageCountLabel.leadingAnchor.constraint(equalTo: pageCountLabelCaption.leadingAnchor),
            pageCountLabel.trailingAnchor.constraint(equalTo: pageCountLabelCaption.trailingAnchor),
            pageCountLabel.bottomAnchor.constraint(equalTo: printPriceCaptionLabel.topAnchor, constant: -outterSpacing)
        ]
        
        contentView.addSubview(pageCountLabel)
        contentView.addSubview(pageCountLabelCaption)
    }
    
    
    // MARK: - UILabel Print Price
    
    let printPriceLabel = UILabel()
    let printPriceCaptionLabel = UILabel()
    var printPriceConstraints = [NSLayoutConstraint]()
    
    private func configurePrintPrice() {
        printPriceCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        printPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        printPriceCaptionLabel.textAlignment = .left
        printPriceCaptionLabel.textColor = defaultCaptionColor
        printPriceCaptionLabel.font = defaultCaptionFont
        
        printPriceLabel.textAlignment = .left
        printPriceLabel.textColor = defaultBodyColor
        printPriceLabel.font = defaultBodyFont
        
        printPriceConstraints = [
            printPriceCaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            printPriceCaptionLabel.trailingAnchor.constraint(equalTo: pageCountLabelCaption.leadingAnchor, constant: -outterSpacing),
            printPriceCaptionLabel.bottomAnchor.constraint(equalTo: printPriceLabel.topAnchor, constant: -innerSpacing),
            
            printPriceLabel.leadingAnchor.constraint(equalTo: printPriceCaptionLabel.leadingAnchor),
            printPriceLabel.trailingAnchor.constraint(equalTo: printPriceCaptionLabel.trailingAnchor),
            printPriceLabel.bottomAnchor.constraint(lessThanOrEqualTo: actionButton.topAnchor, constant: -outterSpacing)
        ]
        
        contentView.addSubview(printPriceLabel)
        contentView.addSubview(printPriceCaptionLabel)
    }
    
    
    // MARK: - UILabel Digital Price
    
    let digitalPriceLabel = UILabel()
    let digitalPriceCaptionLabel = UILabel()
    var digitalPriceConstraints = [NSLayoutConstraint]()
    
    private func configureDigitalPrice() {
        digitalPriceCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        digitalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        digitalPriceCaptionLabel.textAlignment = .left
        digitalPriceCaptionLabel.textColor = defaultCaptionColor
        digitalPriceCaptionLabel.font = defaultCaptionFont
        
        digitalPriceLabel.textAlignment = .left
        digitalPriceLabel.textColor = defaultBodyColor
        digitalPriceLabel.font = defaultBodyFont
        
        digitalPriceConstraints = [
            digitalPriceCaptionLabel.leadingAnchor.constraint(equalTo: printPriceCaptionLabel.trailingAnchor, constant: outterSpacing),
            digitalPriceCaptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            digitalPriceCaptionLabel.bottomAnchor.constraint(equalTo: digitalPriceLabel.topAnchor, constant: -innerSpacing),
            digitalPriceCaptionLabel.widthAnchor.constraint(equalTo: printPriceCaptionLabel.widthAnchor),
            digitalPriceCaptionLabel.centerYAnchor.constraint(equalTo: printPriceCaptionLabel.centerYAnchor),
            
            digitalPriceLabel.leadingAnchor.constraint(equalTo: digitalPriceCaptionLabel.leadingAnchor),
            digitalPriceLabel.trailingAnchor.constraint(equalTo: digitalPriceCaptionLabel.trailingAnchor),
        ]
        
        contentView.addSubview(digitalPriceLabel)
        contentView.addSubview(digitalPriceCaptionLabel)
    }
    
    
    // MARK: - UIButton Action
    
    let actionButton = UIButton()
    var actionButtonConstraints = [NSLayoutConstraint]()
    
    private func configureActionButton() {
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        actionButton.clipsToBounds = true
        actionButton.layer.cornerRadius = 10.0
        
        actionButton.setTitle(Titles.actionButton.rawValue, for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel!.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        actionButton.addTarget(self, action: #selector(followResourceURL), for: .touchUpInside)
        
        actionButton.isEnabled = false
        actionButton.backgroundColor = .systemGray5
        
        actionButtonConstraints = [
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outterSpacing),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outterSpacing),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -outterSpacing),
            actionButton.heightAnchor.constraint(equalToConstant: 50.0)
        ]
        
        contentView.addSubview(actionButton)
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
            summaryLabelCaption.text = Titles.summary.rawValue
            summaryLabel.text = summary
        }
        
        if let creators = details.creators {
            creatorsLabelCaption.text = Titles.creators.rawValue
            creatorsLabel.text = creators
        }
        
        if let characters = details.characters {
            charactersLabelCaption.text = Titles.characters.rawValue
            charactersLabel.text = characters
        }
        
        if let releaseDate = details.releaseDate {
            releaseDateLabelCaption.text = Titles.relaseDate.rawValue
            releaseDateLabel.text = releaseDate
        }
        
        if let pageCount = details.pages {
            pageCountLabelCaption.text = Titles.pages.rawValue
            pageCountLabel.text = pageCount
        }
        
        if let printPrice = details.printPrice {
            printPriceCaptionLabel.text = Titles.printPrice.rawValue
            printPriceLabel.text = printPrice
        }
        
        if let digitalPrice = details.digitalPrice {
            digitalPriceCaptionLabel.text = Titles.digitalPrice.rawValue
            digitalPriceLabel.text = digitalPrice
        }
        
        if let inAppUrl = details.url {
            self.resourceURL = inAppUrl
            actionButton.isEnabled = true
            actionButton.backgroundColor = Theme.colors.primaryColor
        }
        
        guard let imageFetcher = imageFetcher, let identifier = resource?.thumbnail?.absoluteString else { return }
        
        imageFetcher.image(for: identifier) { [weak imageView] imageFetchResult in
            guard let imageView else { return }

            switch imageFetchResult {
            case .success(let image):
                imageView.image = image
                imageView.contentMode = .scaleToFill
            case .failure(let error): print("Image fetch error \(#function): \(error)")

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
