//
//  MRFeedV2Assembly.swift
//  Anilibria
//
//  Created by Antigravity on 02.09.2026.
//

import DITranquillity
import UIKit

final class FeedV2Part: DIPart {
    static func load(container: DIContainer) {
        container.register(FeedV2Presenter.init)
            .as(FeedV2EventHandler.self)
            .lifetime(.objectGraph)
    }
}

final class FeedV2Assembly {
    static func createModule(parent: Router? = nil) -> FeedV2ViewController {
        let module = FeedV2ViewController()
        let router = FeedV2Router(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}
