//
//  MRUserCollectionsV2Contracts.swift
//  Anilibria
//
//  Created by Antigravity on 03.09.2026.
//

import Combine
import UIKit

// MARK: - Models

struct UserCollectionGroupSection {
    let key: UserCollectionKey
    var items: [Series]
    var totalCount: Int? = nil
    var isLoading: Bool
}

// MARK: - View Behavior

protocol UserCollectionsV2ViewBehavior: AnyObject {
    func set(sections: [UserCollectionGroupSection])
    func update(section: UserCollectionGroupSection, at index: Int)
    func showLoading(_ show: Bool)
}

// MARK: - Event Handler

protocol UserCollectionsV2EventHandler: AnyObject {
    func bind(view: UserCollectionsV2ViewBehavior, router: UserCollectionsV2Routable)
    func didLoad()
    func refresh()
    func search()
    func openFilter()
    func select(series: Series)
    func openDetail(for key: UserCollectionKey)
}

// MARK: - Routable

protocol UserCollectionsV2Routable: BaseRoutable, SeriesRoute, SearchRoute, FilterRoute {
    func openDetail(for key: UserCollectionKey)
}
