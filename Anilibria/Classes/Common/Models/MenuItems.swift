import Foundation
import UIKit

public enum MenuItemType: String, CaseIterable {
    case feed, catalog, news, collections, other

    var index: Int {
        return MenuItemType.allCases.firstIndex(of: self) ?? 0
    }
    
    public var icon: UIImage? {
        switch self {
        case .feed: return .System.feed
        case .catalog: return .System.catalog
        case .news: return .System.media
        case .collections: return .System.collections
        case .other: return .System.more
        }
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
        let activeTypes = MenuSettingsManager.shared.getActiveTabs()
        return activeTypes.map { type in
            return MenuItem(type: type, icon: type.icon)
        }
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
            let list = saved.compactMap { MenuItemType(rawValue: $0) }
            if !list.isEmpty {
                return list
            }
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
