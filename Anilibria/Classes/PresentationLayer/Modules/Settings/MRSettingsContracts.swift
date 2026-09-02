import UIKit

// MARK: - Contracts

protocol SettingsViewBehavior: AnyObject {
    func set(name: String, version: String)
    func set(common items: [SettingsControlItem])
    func set(player items: [SettingsControlItem])
    func set(customization items: [SettingsControlItem])
}

protocol SettingsEventHandler: ViewControllerEventHandler {
    func bind(view: SettingsViewBehavior, router: SettingsRoutable)

}
