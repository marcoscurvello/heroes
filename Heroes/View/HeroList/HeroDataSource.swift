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
    
    enum Section {
        case main
    }
    
}

typealias ResourceSnapshot = NSDiffableDataSourceSnapshot<ResourceDataSource.Section, DisplayableResource>

class ResourceDataSource: UICollectionViewDiffableDataSource<ResourceDataSource.Section, DisplayableResource> {
    
    enum Section: CaseIterable {
        case comics, stories, events, series
    }
    
}
