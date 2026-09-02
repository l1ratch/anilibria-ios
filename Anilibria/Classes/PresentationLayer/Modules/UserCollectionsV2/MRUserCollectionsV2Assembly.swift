//
//  MRUserCollectionsV2Assembly.swift
//  Anilibria
//
//  Created by Antigravity on 03.09.2026.
//

import DITranquillity
import UIKit

final class UserCollectionsV2Part: DIPart {
    static func load(container: DIContainer) {
        container.register(UserCollectionsV2Presenter.init)
            .as(UserCollectionsV2EventHandler.self)
            .lifetime(.objectGraph)
    }
}

final class UserCollectionsV2Assembly {
    static func createModule(parent: Router? = nil) -> UserCollectionsV2ViewController {
        let module = UserCollectionsV2ViewController()
        let router = UserCollectionsV2Router(view: module, parent: parent)
        let handler: UserCollectionsV2EventHandler = MainAppCoordinator.shared.container.resolve()
        module.handler = handler
        module.handler.bind(view: module, router: router)
        return module
    }
}
