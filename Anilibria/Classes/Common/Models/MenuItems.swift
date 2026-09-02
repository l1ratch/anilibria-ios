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
            return "Главная (резерв)"
        case .feedV2:
            return "Главная"
        case .catalog:
            return L10n.Screen.Catalog.title
        case .news:
            return "YouTube"
        case .collections:
            return "Коллекции"
        case .collectionsV2:
            return "Списки (v2)"
        case .other:
            return "Другое"
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
    public static let defaultActiveTypes: [MenuItemType] = [.feedV2, .catalog, .news, .collections, .collectionsV2, .other]
    private static let dockItemsKey = "dock_active_item_types"

    public static func getActiveTypes() -> [MenuItemType] {
        if let rawArray = UserDefaults.standard.stringArray(forKey: dockItemsKey) {
            var result = rawArray.compactMap { MenuItemType(rawValue: $0) }
            if result.contains(.feed) && result.contains(.feedV2) {
                result.removeAll(where: { $0 == .feed })
            } else if result.contains(.feed) && !result.contains(.feedV2) {
                if let idx = result.firstIndex(of: .feed) {
                    result[idx] = .feedV2
                }
            }
            if !result.contains(.feedV2) && !result.contains(.feed) {
                result.insert(.feedV2, at: 0)
            }
            if !result.contains(.collectionsV2) && !rawArray.contains("collectionsV2") {
                if let collectionsIndex = result.firstIndex(of: .collections) {
                    result.insert(.collectionsV2, at: collectionsIndex + 1)
                } else {
                    result.insert(.collectionsV2, at: max(0, result.count - 1))
                }
            }
            if !result.contains(.other) {
                result.append(.other)
            }
            return result
        }
        return defaultActiveTypes
    }

    public static func setActiveTypes(_ types: [MenuItemType], notify: Bool = true) {
        var finalTypes = types
        if !finalTypes.contains(.other) {
            finalTypes.append(.other)
        }
        let rawArray = finalTypes.map { $0.rawValue }
        UserDefaults.standard.set(rawArray, forKey: dockItemsKey)
        if notify {
            NotificationCenter.default.post(name: NSNotification.Name("dockItemsChanged"), object: nil)
        }
    }

    public static func getHiddenTypes() -> [MenuItemType] {
        let active = Set(getActiveTypes())
        return MenuItemType.allCases.filter { !active.contains($0) }
    }

    public static func create() -> [MenuItem] {
        let activeTypes = getActiveTypes()
        return activeTypes.map { MenuItem(type: $0, icon: $0.icon) }
    }
}
