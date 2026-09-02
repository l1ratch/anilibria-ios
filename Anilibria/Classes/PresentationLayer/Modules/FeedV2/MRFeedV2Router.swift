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
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Понятно", style: .default))
        controller.present(alert, animated: true)
    }
}
