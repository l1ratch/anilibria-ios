import UIKit

// MARK: - Main Container (Native UITabBarController)

final class MainContainerViewController: UITabBarController, UITabBarControllerDelegate {
    var handler: MainContainerEventHandler!
    private var menuData: [MenuControllerData] = []

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupAppearance()
        handler.didLoad()
    }

    private func setupAppearance() {
        view.backgroundColor = .Surfaces.background
        
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
        appearance.backgroundColor = UIColor(white: 0.08, alpha: 0.8)
        
        let itemAppearance = UITabBarItemAppearance()
        
        // Normal item appearance
        itemAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.55)
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.55),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Selected item appearance
        itemAppearance.selected.iconColor = .Tint.active
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.Tint.active,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .Tint.active
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let index = viewControllers?.firstIndex(of: viewController), let data = menuData[safe: index] {
            triggerHaptic(style: .light)
            handler.select(item: data.type)
        }
    }
}

extension MainContainerViewController: MainContainerViewBehavior {
    func set(items: [MenuItem]) {
        let currentType = menuData[safe: selectedIndex]?.type ?? .feed
        
        var updatedData: [MenuControllerData] = []
        for item in items {
            if let existing = self.menuData.first(where: { $0.type == item.type }) {
                updatedData.append(existing)
            } else {
                let created = MenuItemsControllersFactory.create(for: [item])
                if let newEntry = created.first {
                    updatedData.append(newEntry)
                }
            }
        }
        self.menuData = updatedData
        
        self.viewControllers = updatedData.map { data in
            let item = UITabBarItem(
                title: data.type.title,
                image: data.type.icon,
                selectedImage: data.type.icon
            )
            data.controller.tabBarItem = item
            return data.controller
        }
        
        let targetType = updatedData.contains(where: { $0.type == currentType }) ? currentType : (updatedData.first?.type ?? .feed)
        if let index = updatedData.firstIndex(where: { $0.type == targetType }) {
            self.selectedIndex = index
        }
    }

    func set(selected: MenuItemType) {
        if let index = menuData.firstIndex(where: { $0.type == selected }) {
            self.selectedIndex = index
        }
    }

    func change(visible: Bool, for item: MenuItemType) {
        if !visible {
            let currentItems = menuData.filter { $0.type != item }.map { MenuItem(type: $0.type, icon: $0.type.icon) }
            self.set(items: currentItems)
        } else {
            let allItems = MenuItemsFactory.create()
            self.set(items: allItems)
        }
    }
}
