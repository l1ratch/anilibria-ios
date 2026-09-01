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

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFloatingLiquidGlassDock()
        setupPager()
        handler.didLoad()
        view.backgroundColor = .Surfaces.background
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTabs), name: NSNotification.Name("TabsSettingsDidChange"), object: nil)
    }
    
    @objc private func reloadTabs() {
        let newItems = MenuItemsFactory.create()
        self.set(items: newItems)
        if let first = newItems.first {
            self.set(selected: first.type)
        }
    }

    private func setupFloatingLiquidGlassDock() {
        shadowView.backgroundColor = .clear
        shadowView.shadowOpacity = 0.35
        shadowView.shadowRadius = 16
        shadowView.shadowY = 6
        shadowView.shadowColor = .black

        tabBarContainer.backgroundColor = .clear
        glassBlurView?.removeFromSuperview()

        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        let tintView = UIView()
        tintView.backgroundColor = UIColor(white: 1.0, alpha: 0.04)
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
        tabBarContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor

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
