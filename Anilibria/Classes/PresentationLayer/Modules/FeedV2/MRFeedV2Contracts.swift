//
//  MRFeedV2Contracts.swift
//  Anilibria
//
//  Created by Antigravity on 02.09.2026.
//

import UIKit

// MARK: - View Behavior

protocol FeedV2ViewBehavior: WaitingBehavior, RefreshBehavior {
    func set(heroItems: [PromoItem])
    func set(continueWatching: Series?, episodeID: String?)
    func set(schedule: ShortSchedule)
}

// MARK: - Event Handler

protocol FeedV2EventHandler: ViewControllerEventHandler, RefreshEventHandler {
    func bind(view: FeedV2ViewBehavior, router: FeedV2Routable)

    func select(series: Series)
    func select(promo: PromoItem)
    func selectRandom()
    func allSchedule()
    func openCatalog()
    func continueWatching(series: Series)
    func search()
    func refreshIfNeeded()
}
