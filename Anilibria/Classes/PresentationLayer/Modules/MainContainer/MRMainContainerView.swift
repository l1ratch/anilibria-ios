import UIKit

// MARK: - View Controller

final class MainContainerViewController: BaseViewController {
    @IBOutlet var menuTabBar: MenuTabController!
    @IBOutlet var pagerView: PagerView!
    @IBOutlet var shadowView: ShadowView!
    @IBOutlet var tabBarContainer: UIView!

    var handler: MainContainerEventHandler!
    private var pages: [MenuControllerData] = []
    private var glassBlurView: UIVisualEffectView?
    private var dockWidthConstraint: NSLayoutConstraint?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFloatingLiquidGlassDock()
        setupPager()
        handler.didLoad()
        view.backgroundColor = .Surfaces.background
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTabs), name: NSNotification.Name("TabsSettingsDidChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleTabBarVisibility(_:)), name: NSNotification.Name("ToggleMainTabBarVisibility"), object: nil)
    }
    
    @objc private func toggleTabBarVisibility(_ notification: Notification) {
        guard let isVisible = notification.object as? Bool else { return }
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.5,
            options: [.beginFromCurrentState, .allowUserInteraction]
        ) {
            self.shadowView.alpha = isVisible ? 1.0 : 0.0
            self.shadowView.transform = isVisible ? .identity : CGAffineTransform(translationX: 0, y: 80)
        }
    }
    
    private func updateDockWidth(for itemCount: Int) {
        let buttonWidth: CGFloat = 64
        let padding: CGFloat = 16
        let calculatedWidth = min(view.bounds.width - 24, CGFloat(itemCount) * buttonWidth + padding)
        
        if let existing = dockWidthConstraint {
            existing.constant = calculatedWidth
        } else {
            dockWidthConstraint = shadowView.widthAnchor.constraint(equalToConstant: calculatedWidth)
            dockWidthConstraint?.priority = UILayoutPriority(1000)
            dockWidthConstraint?.isActive = true
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func reloadTabs() {
        let newItems = MenuItemsFactory.create()
        let currentType = self.pages[safe: self.pagerView.currentIndex]?.type ?? .other
        
        updateDockWidth(for: newItems.count)
        
        // Update menuTabBar items
        self.menuTabBar.set(newItems) { [weak self] type in
            self?.handler.select(item: type)
        }
        
        // Update pages, reusing existing controllers to prevent deallocation / crash of active screens
        var updatedPages: [MenuControllerData] = []
        for item in newItems {
            if let existing = self.pages.first(where: { $0.type == item.type }) {
                updatedPages.append(existing)
            } else {
                let newPage = MenuItemsControllersFactory.create(for: [item])
                if let created = newPage.first {
                    created.controller.additionalSafeAreaInsets.bottom = 75
                    updatedPages.append(created)
                }
            }
        }
        self.pages = updatedPages
        
        // Keep current selection intact (do NOT call scrollTo unless the active page was deleted!)
        let targetType = updatedPages.contains(where: { $0.type == currentType }) ? currentType : (updatedPages.first?.type ?? .other)
        self.menuTabBar.set(selected: targetType)
        if !updatedPages.contains(where: { $0.type == currentType }), let newIndex = updatedPages.firstIndex(where: { $0.type == targetType }) {
            self.pagerView.scrollTo(index: newIndex, animated: false)
        }
    }

    private func setupFloatingLiquidGlassDock() {
        shadowView.backgroundColor = .clear
        shadowView.shadowOpacity = 0.5
        shadowView.shadowRadius = 20
        shadowView.shadowY = 8
        shadowView.shadowColor = .black

        tabBarContainer.backgroundColor = .clear
        glassBlurView?.removeFromSuperview()

        let blur = UIBlurEffect(style: .systemMaterialDark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        let tintView = UIView()
        tintView.backgroundColor = UIColor(white: 0.1, alpha: 0.65)
        tintView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(tintView)

        tabBarContainer.insertSubview(blurView, at: 0)

        // Continuous capsule corners (height is 62pt, radius is 31pt)
        tabBarContainer.layer.cornerCurve = .continuous
        tabBarContainer.layer.cornerRadius = 31
        tabBarContainer.layer.masksToBounds = true
        blurView.layer.cornerCurve = .continuous
        blurView.layer.cornerRadius = 31
        blurView.layer.masksToBounds = true
        
        // Specular highlight border
        tabBarContainer.layer.borderWidth = 0.5
        tabBarContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: tabBarContainer.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: tabBarContainer.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: tabBarContainer.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: tabBarContainer.trailingAnchor),
            
            tintView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            tintView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),
            tintView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor)
        ])

        self.glassBlurView = blurView
    }

    func setupPager() {
        self.pagerView.delegate = self
        self.pagerView.isScrollEnabled = false
    }
}

extension MainContainerViewController: PagerViewDelegate {
    func numberOfPages(for pagerView: PagerView) -> Int {
        pages.count
    }

    func pagerView(_ pagerView: PagerView, pageFor index: Int) -> UIViewController? {
        pages[safe: index]?.controller
    }
}

extension MainContainerViewController: MainContainerViewBehavior {
    func set(items: [MenuItem]) {
        self.pages = MenuItemsControllersFactory.create(for: items)
        
        // Propagate safe area scroll insets ONLY to the child pages
        self.pages.forEach { page in
            page.controller.additionalSafeAreaInsets.bottom = 75
        }
        
        self.updateDockWidth(for: items.count)
        
        self.menuTabBar.set(items) { [weak self] type in
            self?.handler.select(item: type)
        }
    }

    func set(selected: MenuItemType) {
        self.menuTabBar.set(selected: selected)
        if let index = pages.firstIndex(where: { $0.type == selected }) {
            self.pagerView.scrollTo(index: index, animated: false)
        }
    }

    func change(visible: Bool, for item: MenuItemType) {
        self.menuTabBar.change(visible: visible, for: item)
    }
}

final class MenuTabController: UIStackView {
    private var views: [MenuItemView] = []

    func set(_ items: [MenuItem], selectionChanged: @escaping Action<MenuItemType>) {
        self.views.forEach {
            $0.removeFromSuperview()
        }

        self.views = []

        items.forEach {
            let item = MenuItemView()
            item.configure($0)
            item.setTap(selectionChanged)
            self.views.append(item)
            self.addArrangedSubview(item)
        }
    }

    func set(selected: MenuItemType) {
        self.views.forEach {
            $0.isSelected = $0.type == selected
        }
    }

    func change(visible: Bool, for item: MenuItemType) {
        let value = self.views.first(where: { $0.type == item })
        value?.isHidden = !visible
    }
}
