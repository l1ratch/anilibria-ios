//
//  MRFeedV2Presenter.swift
//  Anilibria
//
//  Created by Antigravity on 02.09.2026.
//

import Combine
import Foundation
import UIKit

final class FeedV2Presenter {
    private weak var view: FeedV2ViewBehavior!
    private var router: FeedV2Routable!

    private let mainService: MainService
    private var menuService: MenuService
    private let playerService: PlayerService

    private var bag = Set<AnyCancellable>()
    private var activity: ActivityDisposable?
    private var lastRefreshDate: Date?
    private let refreshInterval: TimeInterval = 3600

    init(
        mainService: MainService,
        menuService: MenuService,
        playerService: PlayerService
    ) {
        self.mainService = mainService
        self.menuService = menuService
        self.playerService = playerService

        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.refreshIfNeeded()
            }
            .store(in: &bag)
    }
}

// MARK: - RouterCommandResponder

extension FeedV2Presenter: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if let searchCommand = command as? SearchResultCommand {
            switch searchCommand.value {
            case let .series(item):
                self.select(series: item)
            case let .google(query):
                self.router.open(url: .google(query))
            case .filter:
                self.menuService.setMenuItem(type: .catalog)
            }
            return true
        }
        return false
    }
}

// MARK: - Event Handler

extension FeedV2Presenter: FeedV2EventHandler {
    func bind(view: FeedV2ViewBehavior, router: FeedV2Routable) {
        self.view = view
        self.router = router
        self.router.responder = self
    }

    func didLoad() {
        self.activity = self.view.showLoading(fullscreen: false)
        self.load()
    }

    func refresh() {
        self.activity = self.view.showRefreshIndicator()
        self.load()
    }

    func refreshIfNeeded() {
        if let date = lastRefreshDate {
            let duration = Date().timeIntervalSince1970 - date.timeIntervalSince1970
            if duration >= refreshInterval {
                refresh()
            }
        }
    }

    private func load() {
        Publishers.Zip3(
            mainService.fetchPromo(),
            mainService.fetchTodaySchedule(),
            playerService.fetchSeriesHistory().setFailureType(to: Error.self)
        )
        .sink(onNext: { [weak self] promo, schedule, history in
            guard let self = self else { return }

            self.view.set(heroItems: promo)
            self.view.set(schedule: schedule)

            if let latest = history.first {
                let episodeID = self.playerService.getActiveEpisodeID(for: latest)
                self.view.set(continueWatching: latest, episodeID: episodeID)
            } else {
                self.view.set(continueWatching: nil, episodeID: nil)
            }

            self.activity = nil
            self.lastRefreshDate = Date()
        }, onError: { [weak self] error in
            self?.router.show(error: error)
            self?.activity = nil
        })
        .store(in: &bag)
    }

    func select(series: Series) {
        self.router.open(series: series)
    }

    func continueWatching(series: Series) {
        self.router.open(series: series)
    }

    func select(promo: PromoItem) {
        switch promo.content {
        case .ad(let ad):
            router.open(url: .web(ad.url))
        case .promo(let item):
            if let url = item.url {
                router.open(url: .web(url))
            } else if !promo.info.isEmpty {
                router.show(title: item.title ?? "Анонс", message: promo.info)
            }
        case .release(let series):
            select(series: series)
        case nil:
            if !promo.info.isEmpty {
                router.show(title: "Новость", message: promo.info)
            }
        }
    }

    func selectRandom() {
        self.mainService.fetchRandom()
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] item in
                if let item {
                    self?.router.open(series: item)
                }
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func allSchedule() {
        self.router.openWeekSchedule()
    }

    func openCatalog() {
        self.menuService.setMenuItem(type: .catalog)
    }

    func search() {
        self.router.openSearchScreen()
    }
}
