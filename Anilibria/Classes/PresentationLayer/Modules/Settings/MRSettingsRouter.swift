import UIKit

// MARK: - Router

protocol SettingsRoutable: BaseRoutable, ActionSheetRoute, PermissionRoute {
    func openDockEditor()
}

final class SettingsRouter: BaseRouter, SettingsRoutable {
    func openDockEditor() {
        let editor = DockEditorViewController()
        self.controller.navigationController?.pushViewController(editor, animated: true)
    }
}
