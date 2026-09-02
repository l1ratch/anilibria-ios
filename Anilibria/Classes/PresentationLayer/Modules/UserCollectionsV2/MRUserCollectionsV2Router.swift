//
//  MRUserCollectionsV2Router.swift
//  Anilibria
//
//  Created by Antigravity on 03.09.2026.
//

import UIKit

final class UserCollectionsV2Router: BaseRouter, UserCollectionsV2Routable {
    func openDetail(for key: UserCollectionKey) {
        let detailVC = UserCollectionDetailViewController(key: key)
        controller.navigationController?.pushViewController(detailVC, animated: true)
    }
}
