//
//  MRUserCollectionsV2Presenter.swift
//  Anilibria
//
//  Created by Antigravity on 03.09.2026.
//

import Combine
import Foundation

final class UserCollectionsV2Presenter: UserCollectionsV2EventHandler {
    private weak var view: UserCollectionsV2ViewBehavior!
    private var router: UserCollectionsV2Routable!

    private let userCollectionsService: UserCollectionsService
    private let favoriteService: FavoriteService

    private var sections: [UserCollectionGroupSection] = []
    private var allSections: [UserCollectionGroupSection] = []
    private var currentQuery: String = ""
    private var bag = Set<AnyCancellable>()

    init(
        userCollectionsService: UserCollectionsService,
        favoriteService: FavoriteService
    ) {
        self.userCollectionsService = userCollectionsService
        self.favoriteService = favoriteService
    }

    func bind(view: UserCollectionsV2ViewBehavior, router: UserCollectionsV2Routable) {
        self.view = view
        self.router = router
        self.router.responder = self
    }

    private static var cachedSections: [UserCollectionGroupSection]?

    func didLoad() {
        subscribeToUpdates()
        if let cached = Self.cachedSections, !cached.isEmpty {
            self.sections = cached
            self.allSections = cached
            self.view.set(sections: cached)
        }
        loadAllCollections()
    }

    func refresh() {
        Self.cachedSections = nil
        loadAllCollections()
    }

    private func subscribeToUpdates() {
        userCollectionsService.collectionsUpdates()
            .sink(onNext: { [weak self] _ in
                self?.loadAllCollections()
            })
            .store(in: &bag)

        favoriteService.favoritesUpdates()
            .sink(onNext: { [weak self] _ in
                self?.loadAllCollections()
            })
            .store(in: &bag)

        NotificationCenter.default.publisher(for: UserCollectionsPreferences.notificationName)
            .sink { [weak self] _ in
                Self.cachedSections = nil
                self?.loadAllCollections()
            }
            .store(in: &bag)
    }

    private func loadAllCollections() {
        let orderedKeys = UserCollectionsPreferences.getActiveKeys()

        view.showLoading(true)

        var loadedSections: [UserCollectionGroupSection]
        if let cached = Self.cachedSections, cached.map({ $0.key }) == orderedKeys {
            loadedSections = cached
        } else {
            loadedSections = orderedKeys.map {
                UserCollectionGroupSection(key: $0, items: [], isLoading: true)
            }
            self.sections = loadedSections
            self.allSections = loadedSections
            self.view.set(sections: loadedSections)
        }

        let dispatchGroup = DispatchGroup()

        for (index, key) in orderedKeys.enumerated() {
            dispatchGroup.enter()

            if let collectionType = key.collectionType {
                userCollectionsService.fetchSeries(
                    type: collectionType,
                    limit: 12,
                    page: 1,
                    data: SeriesSearchData()
                )
                .sink(onNext: { [weak self] series in
                    guard let self = self else { return }
                    loadedSections[index] = UserCollectionGroupSection(key: key, items: series, isLoading: false)
                    self.view.update(section: loadedSections[index], at: index)
                    dispatchGroup.leave()
                }, onError: { [weak self] _ in
                    guard let self = self else { return }
                    loadedSections[index] = UserCollectionGroupSection(key: key, items: [], isLoading: false)
                    self.view.update(section: loadedSections[index], at: index)
                    dispatchGroup.leave()
                })
                .store(in: &bag)
            } else {
                // Favorite
                favoriteService.fetchSeries(
                    limit: 12,
                    page: 1,
                    data: SeriesSearchData()
                )
                .sink(onNext: { [weak self] series in
                    guard let self = self else { return }
                    loadedSections[index] = UserCollectionGroupSection(key: key, items: series, isLoading: false)
                    self.view.update(section: loadedSections[index], at: index)
                    dispatchGroup.leave()
                }, onError: { [weak self] _ in
                    guard let self = self else { return }
                    loadedSections[index] = UserCollectionGroupSection(key: key, items: [], isLoading: false)
                    self.view.update(section: loadedSections[index], at: index)
                    dispatchGroup.leave()
                })
                .store(in: &bag)
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.sections = loadedSections
            self.allSections = loadedSections
            Self.cachedSections = loadedSections
            self.view.showLoading(false)
            self.view.set(sections: loadedSections)
        }
    }

    func search() {
        router.openSearchScreen()
    }

    func openFilter() {
        userCollectionsService.fetchFilterData()
            .sink(onNext: { [weak self] data in
                self?.router.open(filter: .init(), data: data)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func select(series: Series) {
        router.open(series: series)
    }

    func openDetail(for key: UserCollectionKey) {
        router.openDetail(for: key)
    }
}

extension UserCollectionsV2Presenter: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if let searchCommand = command as? SearchResultCommand {
            switch searchCommand.value {
            case let .series(item):
                self.select(series: item)
            case .google:
                break
            case .filter:
                break
            }
            return true
        }
        return false
    }
}
