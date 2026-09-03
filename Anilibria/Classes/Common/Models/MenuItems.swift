import Foundation
import UIKit

public enum MenuItemType: String, CaseIterable {
    case feed, feedV2, catalog, news, collections, collectionsV2, other

    var index: Int {
        return MenuItemType.allCases.firstIndex(of: self) ?? 0
    }

    public var title: String {
        switch self {
        case .feed:
            return Language.isEnglish ? "Home (Backup)" : "Главная (резерв)"
        case .feedV2:
            return Language.isEnglish ? "Home" : "Главная"
        case .catalog:
            return L10n.Screen.Catalog.title
        case .news:
            return "YouTube"
        case .collections:
            return Language.isEnglish ? "Collections (Backup)" : "Коллекции (резерв)"
        case .collectionsV2:
            return Language.isEnglish ? "Lists" : "Списки"
        case .other:
            return Language.isEnglish ? "Other" : "Другое"
        }
    }

    public var icon: UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        switch self {
        case .feed:
            return UIImage(systemName: "clock.arrow.circlepath", withConfiguration: config) ?? .System.news
        case .feedV2:
            return UIImage(systemName: "house.fill", withConfiguration: config) ?? .System.news
        case .catalog:
            return UIImage(systemName: "square.grid.2x2.fill", withConfiguration: config) ?? .System.search
        case .news:
            return UIImage(systemName: "play.rectangle.fill", withConfiguration: config) ?? .iconYoutube
        case .collections:
            return UIImage(systemName: "bookmark.fill", withConfiguration: config) ?? .System.book
        case .collectionsV2:
            return UIImage(systemName: "square.stack.fill", withConfiguration: config) ?? .System.book
        case .other:
            return UIImage(systemName: "ellipsis.circle.fill", withConfiguration: config) ?? .System.dots
        }
    }
}

public typealias DoubleImage = (normal: UIImage, selected: UIImage)

public final class MenuItem: NSObject {
    public let type: MenuItemType
    public let icon: UIImage?

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
    public static let defaultActiveTypes: [MenuItemType] = [.feedV2, .catalog, .news, .collectionsV2, .other]
    private static let dockItemsKey = "dock_active_item_types"

    public static func getActiveTypes() -> [MenuItemType] {
        if let rawArray = UserDefaults.standard.stringArray(forKey: dockItemsKey) {
            var result = rawArray.compactMap { MenuItemType(rawValue: $0) }
            if let idx = result.firstIndex(of: .feed) {
                result[idx] = .feedV2
            }
            if let idx = result.firstIndex(of: .collections) {
                result[idx] = .collectionsV2
            }
            result.removeAll(where: { $0 == .feed || $0 == .collections })

            // Always lock Main (feedV2) at index 0
            result.removeAll(where: { $0 == .feedV2 })
            result.insert(.feedV2, at: 0)

            var seen = Set<MenuItemType>()
            return result.filter { seen.insert($0).inserted }
        }
        return defaultActiveTypes
    }

    public static func setActiveTypes(_ types: [MenuItemType], notify: Bool = true) {
        var finalTypes = types
        finalTypes.removeAll(where: { $0 == .feed || $0 == .collections })
        // Always lock Main (feedV2) at index 0
        finalTypes.removeAll(where: { $0 == .feedV2 })
        finalTypes.insert(.feedV2, at: 0)

        let rawArray = finalTypes.map { $0.rawValue }
        UserDefaults.standard.set(rawArray, forKey: dockItemsKey)
        if notify {
            NotificationCenter.default.post(name: NSNotification.Name("dockItemsChanged"), object: nil)
        }
    }

    public static func getHiddenTypes() -> [MenuItemType] {
        let active = Set(getActiveTypes())
        return MenuItemType.allCases.filter { !active.contains($0) && $0 != .feed && $0 != .collections }
    }

    public static func create() -> [MenuItem] {
        let activeTypes = getActiveTypes()
        return activeTypes.map { MenuItem(type: $0, icon: $0.icon) }
    }
}
