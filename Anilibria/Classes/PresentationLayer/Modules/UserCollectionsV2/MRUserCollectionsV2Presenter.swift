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
    }

    func didLoad() {
        subscribeToUpdates()
        loadAllCollections()
    }

    func refresh() {
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
    }

    private func loadAllCollections() {
        view.showLoading(true)

        // Preferred order: Watching, Planned, Watched, Postponed, Abandoned, Favorite
        let orderedKeys: [UserCollectionKey] = [
            .watching,
            .planned,
            .watched,
            .postponed,
            .abandoned,
            .favorite
        ]

        var loadedSections: [UserCollectionGroupSection] = orderedKeys.map {
            UserCollectionGroupSection(key: $0, items: [], isLoading: true)
        }
        self.sections = loadedSections
        self.allSections = loadedSections
        self.view.set(sections: loadedSections)

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
            self.view.showLoading(false)
            if !self.currentQuery.isEmpty {
                self.applySearchFilter(query: self.currentQuery)
            } else {
                self.view.set(sections: loadedSections)
            }
        }
    }

    func search(query: String) {
        currentQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        applySearchFilter(query: currentQuery)
    }

    private func applySearchFilter(query: String) {
        if query.isEmpty {
            sections = allSections
        } else {
            let lower = query.lowercased()
            sections = allSections.compactMap { section in
                let filteredItems = section.items.filter { item in
                    let mainName = item.name?.main.lowercased() ?? ""
                    let engName = item.name?.english?.lowercased() ?? ""
                    let alias = item.alias.lowercased()
                    return mainName.contains(lower) || engName.contains(lower) || alias.contains(lower)
                }
                if filteredItems.isEmpty {
                    return nil
                }
                return UserCollectionGroupSection(key: section.key, items: filteredItems, isLoading: false)
            }
        }
        view.set(sections: sections)
    }

    func select(series: Series) {
        router.open(series: series)
    }

    func openDetail(for key: UserCollectionKey) {
        router.openDetail(for: key)
    }
}
