//
//  ActionSheetAssembly.swift
//  Anilibria
//
//  Created by Ivan Morozov on 16.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

final class ActionSheetAssembly {
    static func createModule(
        source: any ActionSheetGroupSource,
        parent: Router? = nil
    ) -> ActionSheetViewController {
        let module = ActionSheetViewController()
        let router = ActionSheetRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, source: source)
        return module
    }
}

// MARK: - Route

protocol ActionSheetRoute {
    func openSheet(with source: any ActionSheetGroupSource)
}

extension ActionSheetRoute where Self: RouterProtocol {
    func openSheet(with source: any ActionSheetGroupSource) {
        source.fetchItems { [weak self] groups in
            guard let self else { return }
            let groupTitle = groups.first?.title
            let alert = UIAlertController(
                title: (groupTitle?.isEmpty == false) ? groupTitle : nil,
                message: nil,
                preferredStyle: .actionSheet
            )
            alert.view.tintColor = .Tint.active

            for group in groups {
                for item in group.items {
                    var title = item.title.string
                    if item.isSelected {
                        title = "✓ " + title
                    }
                    let action = UIAlertAction(title: title, style: .default) { _ in
                        _ = item.select()
                    }
                    alert.addAction(action)
                }
            }

            alert.addAction(UIAlertAction(title: L10n.Buttons.cancel, style: .cancel, handler: nil))

            if let popover = alert.popoverPresentationController {
                if let root = UIApplication.getWindow()?.rootViewController {
                    popover.sourceView = root.view
                    popover.sourceRect = CGRect(x: root.view.bounds.midX, y: root.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
            }

            if let targetVC = self.controller {
                targetVC.present(alert, animated: true, completion: nil)
            } else if let root = UIApplication.getWindow()?.rootViewController {
                var topVC = root
                while let presented = topVC.presentedViewController {
                    topVC = presented
                }
                topVC.present(alert, animated: true, completion: nil)
            }
        }
    }

    func openSheet(with items: [ChoiceGroup]) {
        openSheet(with: SimpleSheetGroupSource(items: items))
    }
}
