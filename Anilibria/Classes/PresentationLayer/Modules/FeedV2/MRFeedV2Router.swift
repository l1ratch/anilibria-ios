//
//  MRFeedV2Router.swift
//  Anilibria
//
//  Created by Antigravity on 02.09.2026.
//

import UIKit

// MARK: - Router

protocol FeedV2Routable: BaseRoutable,
    AppUrlRoute,
    ScheduleRoute,
    SearchRoute,
    SeriesRoute,
    HistoryRoute,
    CatalogRoute {
    func show(title: String, message: String)
}

final class FeedV2Router: BaseRouter, FeedV2Routable {
    func show(title: String, message: String) {
        MRAppAlertController.alert(title, message: message, acceptMessage: Language.isEnglish ? "Got it" : "Понятно")
    }
}
