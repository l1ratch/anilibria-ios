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
    func openSeriesWithPlayer(series: Series, episodeID: String?)
}

final class FeedV2Router: BaseRouter, FeedV2Routable {
    func show(title: String, message: String) {
        MRAppAlertController.alert(title, message: message, acceptMessage: Language.isEnglish ? "Got it" : "Понятно")
    }

    func openSeriesWithPlayer(series: Series, episodeID: String?) {
        let seriesVC = SeriesAssembly.createModule(series: series, parent: self)
        PushRouter(target: seriesVC, parent: self.controller).move()

        let episode = series.playlist.first(where: { $0.id == episodeID }) ?? series.playlist.first
        let playerVC = PlayerAssembly.createModule(
            series: series,
            userID: UserRepositoryImp().getUser()?.id,
            episode: episode,
            parent: self
        )
        PresentRouter(target: playerVC,
                      from: seriesVC,
                      use: BlurPresentationController.self,
                      configure: {
                          $0.isBlured = false
                          $0.transformation = ScaleTransformation()
        }).move()
    }
}
