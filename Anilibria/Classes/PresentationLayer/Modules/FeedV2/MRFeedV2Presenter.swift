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

    private static var cachedPromo: [PromoItem]?
    private static var cachedSchedule: ShortSchedule?

    func didLoad() {
        if let promo = Self.cachedPromo, !promo.isEmpty {
            self.view.set(heroItems: promo)
        }
        if let schedule = Self.cachedSchedule {
            self.view.set(schedule: schedule)
        }
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
        mainService.fetchPromo()
            .sink(onNext: { [weak self] promo in
                Self.cachedPromo = promo
                self?.view.set(heroItems: promo)
                self?.activity = nil
            }, onError: { [weak self] _ in
                self?.activity = nil
            })
            .store(in: &bag)

        mainService.fetchTodaySchedule()
            .sink(onNext: { [weak self] schedule in
                Self.cachedSchedule = schedule
                self?.view.set(schedule: schedule)
                self?.activity = nil
                self?.lastRefreshDate = Date()
            }, onError: { [weak self] _ in
                self?.activity = nil
            })
            .store(in: &bag)

        playerService.fetchSeriesHistory()
            .sink(onNext: { [weak self] history in
                guard let self = self else { return }
                if let latest = history.first {
                    let episodeID = self.playerService.getActiveEpisodeID(for: latest)
                    self.view.set(continueWatching: latest, episodeID: episodeID)
                } else {
                    self.view.set(continueWatching: nil, episodeID: nil)
                }
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

    func selectPromoDetails(promo: PromoItem) {
        let title: String
        switch promo.content {
        case .ad(let ad):
            title = ad.title
        case .promo(let item):
            let t = item.title?.trimmingCharacters(in: .whitespacesAndNewlines)
            title = (t?.isEmpty == false) ? t! : (Language.isEnglish ? "Announcement" : "Анонс")
        case .release(let series):
            title = series.name?.main ?? series.alias
        case nil:
            title = Language.isEnglish ? "News" : "Новость"
        }

        if !promo.info.isEmpty {
            router.show(title: title, message: promo.info)
        } else {
            select(promo: promo)
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
