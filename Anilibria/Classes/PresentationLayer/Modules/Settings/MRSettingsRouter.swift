import UIKit

// MARK: - Router

protocol SettingsRoutable: BaseRoutable, ActionSheetRoute, PermissionRoute {
    func openTabSettings()
}

final class SettingsRouter: BaseRouter, SettingsRoutable {
    func openTabSettings() {
        let vc = TabSettingsViewController()
        self.controller.navigationController?.pushViewController(vc, animated: true)
    }
}
