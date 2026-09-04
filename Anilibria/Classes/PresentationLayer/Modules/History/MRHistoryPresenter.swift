import DITranquillity
import Combine
import UIKit

final class HistoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(HistoryPresenter.init)
            .as(HistoryEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class HistoryPresenter {
    private weak var view: HistoryViewBehavior!
    private var router: HistoryRoutable!
    private var rawSeries: [Series] = []
    private var query: String = ""
    private var bag = Set<AnyCancellable>()

    let playerService: PlayerService
    let mainService: MainService

    init(playerService: PlayerService,
         mainService: MainService) {
        self.playerService = playerService
        self.mainService = mainService
    }
}

extension HistoryPresenter: HistoryEventHandler {
    func bind(view: HistoryViewBehavior, router: HistoryRoutable) {
        self.view = view
        self.router = router
    }

    func didLoad() {
        self.playerService
            .observeHistoryUpdates()
            .sink { [weak self] update in
                guard let self else { return }
                switch update {
                case .removed(let series):
                    remove(series: series)
                case .added(let series):
                    remove(series: series)
                    rawSeries.insert(series, at: 0)
                }
                showItems()
            }
            .store(in: &bag)

        self.playerService
            .fetchSeriesHistory()
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] items in
                self?.rawSeries = items
                self?.showItems()
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    private func remove(series: Series) {
        if let index = rawSeries.firstIndex(where: { $0.id == series.id }) {
            rawSeries.remove(at: index)
        }
    }

    func delete(item: HistoryItemModel) {
        self.playerService.removeHistory(for: item.series)
    }

    func select(item: HistoryItemModel) {
        router.open(series: item.series)
    }

    func continueWatching(item: HistoryItemModel) {
        router.openSeriesWithPlayer(series: item.series, episodeID: item.episodeID)
    }

    func search(query: String) {
        self.query = query.lowercased()
        self.showItems()
    }

    private func buildItemModel(for series: Series, userID: Int?) -> HistoryItemModel {
        let episodeID = self.playerService.getActiveEpisodeID(for: series)
        let item = series.playlist.first(where: { $0.id == episodeID }) ?? series.playlist.first
        let activeID = episodeID ?? item?.id
        let timeCode = activeID.flatMap { self.playerService.getTimeCode(userID: userID, episodeID: $0) }
        return HistoryItemModel(
            series: series,
            episodeID: activeID,
            playlistItem: item,
            timeCode: timeCode
        )
    }

    private func showItems() {
        let currentSeries = self.rawSeries
        let currentQuery = self.query
        let userID = UserRepositoryImp().getUser()?.id

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var filtered = currentSeries
            if !currentQuery.isEmpty {
                filtered = filtered.filter { s in
                    (s.name?.main?.lowercased().contains(currentQuery) ?? false) ||
                    (s.name?.english?.lowercased().contains(currentQuery) ?? false) ||
                    s.alias.lowercased().contains(currentQuery)
                }
            }

            let models = filtered.map { self.buildItemModel(for: $0, userID: userID) }
            DispatchQueue.main.async {
                self.view.set(items: models)
            }
        }
    }
}
