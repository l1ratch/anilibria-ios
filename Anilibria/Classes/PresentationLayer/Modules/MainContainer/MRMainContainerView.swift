import UIKit

// MARK: - View Controller

final class MainContainerViewController: BaseViewController {
    @IBOutlet var menuTabBar: MenuTabController!
    @IBOutlet var pagerView: PagerView!
    @IBOutlet var shadowView: ShadowView!
    @IBOutlet var tabBarContainer: UIView!

    var handler: MainContainerEventHandler!
    private var pages: [MenuControllerData] = []

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFloatingDock()
        setupPager()
        handler.didLoad()
        view.backgroundColor = .Surfaces.background

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBottomBarToggle(_:)),
            name: .shouldToggleBottomBar,
            object: nil
        )
    }

    private func setupFloatingDock() {
        shadowView.shadowColor = .black
        shadowView.shadowOpacity = 0.4
        shadowView.shadowRadius = 16
        shadowView.shadowY = 6
        shadowView.clipsToBounds = false

        tabBarContainer.backgroundColor = UIColor(white: 0.12, alpha: 0.8)
        tabBarContainer.smoothCorners(with: 27)
        tabBarContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor
        tabBarContainer.layer.borderWidth = 1
        tabBarContainer.clipsToBounds = true

        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = tabBarContainer.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tabBarContainer.insertSubview(blurView, at: 0)
    }

    @objc private func handleBottomBarToggle(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let hidden = userInfo["hidden"] as? Bool else { return }
        let animated = userInfo["animated"] as? Bool ?? true

        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
            self.shadowView.alpha = hidden ? 0 : 1
            self.shadowView.transform = hidden ? CGAffineTransform(translationX: 0, y: 100) : .identity
        }
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
        let oldPages = self.pages
        var newPages: [MenuControllerData] = []
        for item in items {
            if let existing = oldPages.first(where: { $0.type == item.type }) {
                newPages.append(existing)
            } else {
                newPages.append(MenuItemsControllersFactory.createSingle(for: item))
            }
        }
        self.pages = newPages
        self.pagerView.resetCurrentIndex()
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
