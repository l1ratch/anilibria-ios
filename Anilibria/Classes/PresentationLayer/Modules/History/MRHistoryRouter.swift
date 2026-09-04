import UIKit

// MARK: - Router

protocol HistoryRoutable: BaseRoutable, SeriesRoute {
    func openSeriesWithPlayer(series: Series, episodeID: String?)
}

final class HistoryRouter: BaseRouter, HistoryRoutable {
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
