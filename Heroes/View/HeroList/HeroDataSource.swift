//
//  HeroListDataSource.swift
//  Heroes
//
//  Created by Marcos Curvello on 13/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

typealias HeroSnapshot = NSDiffableDataSourceSnapshot<HeroDataSource.Section, Character>
class HeroDataSource: UICollectionViewDiffableDataSource<HeroDataSource.Section, Character> {
    enum Section { case main }
}

typealias ResourceSnapshot = NSDiffableDataSourceSnapshot<ResourceDataSource.LayoutSection, DisplayableResource>
class ResourceDataSource: UICollectionViewDiffableDataSource<ResourceDataSource.LayoutSection, DisplayableResource> {

    enum LayoutSection: Int, CaseIterable {
        case comics, stories, events, series

        var sectionTitle: String {
            switch self {
            case .comics: return "Comics"
            case .stories: return "Stories"
            case .events: return "Events"
            case .series: return "Series"
            }
        }

        func columnCount(for width: CGFloat) -> Int {
            let wideMode = width > 800
            let narrowMode = width < 420

            switch self {
            case .comics, .stories, .events, .series:
                return wideMode ? 3 : narrowMode ? 1 : 2
            }
        }
    }

}
