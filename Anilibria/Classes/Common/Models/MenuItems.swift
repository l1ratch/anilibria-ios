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
            MenuItem(type: .feed, icon: UIImage(systemName: "house.fill") ?? .System.news),
            MenuItem(type: .catalog, icon: UIImage(systemName: "play.rectangle.on.rectangle.fill") ?? .System.search),
            MenuItem(type: .news, icon: UIImage(systemName: "newspaper.fill") ?? .iconYoutube),
            MenuItem(type: .collections, icon: UIImage(systemName: "square.stack.3d.up.fill") ?? .System.book),
            MenuItem(type: .other, icon: UIImage(systemName: "ellipsis.circle.fill") ?? .System.dots)
        ]
    }
}
