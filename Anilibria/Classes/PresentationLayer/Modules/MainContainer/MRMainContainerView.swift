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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadTabs),
            name: NSNotification.Name("TabsSettingsDidChange"),
            object: nil
        )
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
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.tintColor = .Tint.active
    }

    @objc private func reloadTabs() {
        let newItems = MenuItemsFactory.create()
        self.set(items: newItems)
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
        
        // Reuse existing navigation controllers if available
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
            let title: String
            let sfSymbol: String
            switch data.type {
            case .feed:
                title = "Главная"
                sfSymbol = "house.fill"
            case .catalog:
                title = "Релизы"
                sfSymbol = "play.rectangle.on.rectangle.fill"
            case .news:
                title = "Новости"
                sfSymbol = "newspaper.fill"
            case .collections:
                title = "Коллекции"
                sfSymbol = "square.stack.3d.up.fill"
            case .other:
                title = "Другое"
                sfSymbol = "ellipsis.circle.fill"
            }
            
            let iconImage = UIImage(systemName: sfSymbol) ?? data.type.icon
            data.controller.tabBarItem = UITabBarItem(
                title: title,
                image: iconImage,
                selectedImage: iconImage
            )
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
        // Handled via set(items:)
    }
}
