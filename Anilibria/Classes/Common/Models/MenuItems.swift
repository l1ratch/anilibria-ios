import Foundation
import UIKit

public enum MenuItemType: String, CaseIterable {
    case feed, catalog, news, collections, other

    var index: Int {
        return MenuItemType.allCases.firstIndex(of: self) ?? 0
    }

    public var title: String {
        switch self {
        case .feed: return "Главная"
        case .catalog: return "Каталог"
        case .news: return "Новости"
        case .collections: return "Коллекции"
        case .other: return "Другое"
        }
    }

    public var sfSymbol: String {
        switch self {
        case .feed: return "house.fill"
        case .catalog: return "play.rectangle.on.rectangle.fill"
        case .news: return "newspaper.fill"
        case .collections: return "square.stack.3d.up.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    public var icon: UIImage? {
        return UIImage(systemName: sfSymbol)
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
        return MenuItemType.allCases.map { type in
            MenuItem(type: type, icon: type.icon)
        }
    }
}
