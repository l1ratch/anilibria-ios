import Foundation
import UIKit

public enum MenuItemType: String, CaseIterable {
    case feed, catalog, news, collections, other

    var index: Int {
        return MenuItemType.allCases.firstIndex(of: self) ?? 0
    }
}

public typealias DoubleImage = (normal: UIImage, selected: UIImage)

public final class MenuItem: NSObject {
    let type: MenuItemType
    let icon: UIImage?

    public init(type: MenuItemType, icon: UIImage?) {
        self.type = type
        self.icon = icon
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? MenuItem {
            return self.type == other.type
        }
        return super.isEqual(object)
    }
}

public final class MenuListItem: ListItem<[MenuItem]> {}

public final class MenuItemsFactory {
    static func create() -> [MenuItem] {
        return [
            MenuItem(type: .feed, icon: .System.feed),
            MenuItem(type: .catalog, icon: .System.catalog),
            MenuItem(type: .news, icon: .System.media),
            MenuItem(type: .collections, icon: .System.collections),
            MenuItem(type: .other, icon: .System.more)
        ]
    }
}

public final class MenuSettingsManager {
    public static let shared = MenuSettingsManager()
    
    private let activeTabsKey = "AniLiberty.ActiveTabs"
    private let inactiveTabsKey = "AniLiberty.InactiveTabs"
    
    private let defaultActive: [MenuItemType] = [.feed, .catalog, .news, .collections, .other]
    private let defaultInactive: [MenuItemType] = []
    
    public init() {}
    
    public func getActiveTabs() -> [MenuItemType] {
        if let saved = UserDefaults.standard.stringArray(forKey: activeTabsKey) {
            return saved.compactMap { MenuItemType(rawValue: $0) }
        }
        return defaultActive
    }
    
    public func getInactiveTabs() -> [MenuItemType] {
        if let saved = UserDefaults.standard.stringArray(forKey: inactiveTabsKey) {
            return saved.compactMap { MenuItemType(rawValue: $0) }
        }
        return defaultInactive
    }
    
    public func save(active: [MenuItemType], inactive: [MenuItemType]) {
        let activeStrings = active.map { $0.rawValue }
        let inactiveStrings = inactive.map { $0.rawValue }
        UserDefaults.standard.set(activeStrings, forKey: activeTabsKey)
        UserDefaults.standard.set(inactiveStrings, forKey: inactiveTabsKey)
    }
}
