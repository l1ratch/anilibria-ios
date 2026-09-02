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
    CatalogRoute {}

final class FeedV2Router: BaseRouter, FeedV2Routable {}
