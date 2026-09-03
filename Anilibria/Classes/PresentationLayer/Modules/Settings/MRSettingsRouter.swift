import UIKit

// MARK: - Router

protocol SettingsRoutable: BaseRoutable, ActionSheetRoute, PermissionRoute {
    func openDockEditor()
    func openCollectionsEditor()
    func presentAlert(_ alert: UIAlertController)
}

final class SettingsRouter: BaseRouter, SettingsRoutable {
    func openDockEditor() {
        let editor = DockEditorViewController()
        self.controller.navigationController?.pushViewController(editor, animated: true)
    }

    func openCollectionsEditor() {
        let editor = UserCollectionsEditorViewController()
        self.controller.navigationController?.pushViewController(editor, animated: true)
    }

    func presentAlert(_ alert: UIAlertController) {
        self.controller.present(alert, animated: true)
    }
}
