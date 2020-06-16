//
//  CollectionViewLayoutGenerator.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

struct CollectionViewLayoutGenerator {
    
    enum CollectionViewStyle {
        case paginated, search
        
        var suplementaryViewKindForStyle: String {
            switch self {
            case .paginated:
                return LoaderReusableView.elementKind
            case .search:
                return SearchReusableView.elementKind
            }
        }
        
        var heightForViewKind: CGFloat {
            switch self {
            case .paginated:
                return CGFloat(60.0)
            case .search:
                return CGFloat(44.0)
            }
        }
        
        var alignmentForViewKind: NSRectAlignment {
            switch self {
            case .paginated:
                return .bottom
            case .search:
                return .top
            }
        }
    }
    
    enum SectionLayoutKind: Int, CaseIterable {
        case list
        
        func columnCount(for width: CGFloat) -> Int {
            let wideMode = width > 800
            let narrowMode = width < 420
            
            switch self {
            case .list:
                return wideMode ? 3 : narrowMode ? 1 : 2
            }
        }
    }
    
    static func generateLayoutForStyle(_ style: CollectionViewStyle) -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let layoutKind = SectionLayoutKind(rawValue: sectionIndex) else { return nil }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let columns = layoutKind.columnCount(for: layoutEnvironment.container.effectiveContentSize.width)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(130))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 10, bottom: 0, trailing: 10)
            
            let suplementaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(style.heightForViewKind))
            let suplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: suplementaryItemSize, elementKind: style.suplementaryViewKindForStyle, alignment: style.alignmentForViewKind)
            section.boundarySupplementaryItems = [suplementaryItem]
            return section
        }
    }
    
    static func resourcesCollectionViewLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let sectionLayoutKind = HeroDetailViewController.LayoutSection(rawValue: sectionIndex)!
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupWidth: NSCollectionLayoutDimension!
            let groupHeight: NSCollectionLayoutDimension!
            switch sectionLayoutKind {
            case .comics:
                groupWidth = .absolute(120)
                groupHeight = .absolute(200)
            case .stories, .events, .series:
                groupWidth = .fractionalWidth(0.40)
                groupHeight = .fractionalHeight(0.18)
            }
            
            let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            
            let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: TitleSupplementaryView.elementKind, alignment: .top)
            section.boundarySupplementaryItems = [titleSupplementary]
        
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        config.scrollDirection = .vertical
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
}
