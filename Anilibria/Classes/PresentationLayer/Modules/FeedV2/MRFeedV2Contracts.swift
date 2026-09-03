//
//  MRFeedV2Contracts.swift
//  Anilibria
//
//  Created by Antigravity on 02.09.2026.
//

import UIKit

public enum ContinueWatchingItem: Hashable {
    case series(series: Series, episodeID: String?)
    case allHistory
}

// MARK: - View Behavior

protocol FeedV2ViewBehavior: WaitingBehavior, RefreshBehavior {
    func set(heroItems: [PromoItem])
    func set(continueWatching items: [ContinueWatchingItem])
    func set(schedule: ShortSchedule)
}

// MARK: - Event Handler

protocol FeedV2EventHandler: ViewControllerEventHandler, RefreshEventHandler {
    func bind(view: FeedV2ViewBehavior, router: FeedV2Routable)

    func select(series: Series)
    func select(promo: PromoItem)
    func selectPromoDetails(promo: PromoItem)
    func selectRandom()
    func allSchedule()
    func openCatalog()
    func continueWatching(series: Series, episodeID: String?)
    func openHistory()
    func search()
    func refreshIfNeeded()
}
