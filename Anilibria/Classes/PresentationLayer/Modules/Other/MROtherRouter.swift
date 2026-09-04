import UIKit

// MARK: - Route

protocol AboutRoute {
    func openAbout()
}

extension AboutRoute where Self: RouterProtocol {
    func openAbout() {
        let module = AboutViewController()
        PushRouter(target: module, parent: self.controller).move()
    }
}

// MARK: - Router

protocol OtherRoutable: BaseRoutable,
    AppUrlRoute,
    SafariRoute,
    SignInRoute,
    SettingsRoute,
    AboutRoute,
    HistoryRoute,
    LinkDeviceRoute,
    TeamRoute {}

final class OtherRouter: BaseRouter, OtherRoutable {}
