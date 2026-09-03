import UIKit

// MARK: - View Controller

final class MainContainerViewController: BaseViewController {
    @IBOutlet var menuTabBar: MenuTabController!
    @IBOutlet var pagerView: PagerView!
    @IBOutlet var shadowView: ShadowView!
    @IBOutlet var tabBarContainer: UIView!

    var handler: MainContainerEventHandler!
    private var pages: [MenuControllerData] = []
    private let dockBlurView = UIVisualEffectView()

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

    private var dockWidthConstraint: NSLayoutConstraint?

    private func setupFloatingDock() {
        shadowView.shadowColor = .black
        shadowView.shadowOpacity = 0.25
        shadowView.shadowRadius = 16
        shadowView.shadowY = 6
        shadowView.clipsToBounds = false

        tabBarContainer.smoothCorners(with: 27)
        tabBarContainer.clipsToBounds = true

        dockBlurView.frame = tabBarContainer.bounds
        dockBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tabBarContainer.insertSubview(dockBlurView, at: 0)

        setupDockConstraints()
        updateDockAppearance()
    }

    private func setupDockConstraints() {
        for constraint in view.constraints {
            let isShadowLeadingOrTrailing = (constraint.firstItem as? UIView == shadowView && (constraint.firstAttribute == .leading || constraint.firstAttribute == .trailing)) ||
                                            (constraint.secondItem as? UIView == shadowView && (constraint.secondAttribute == .leading || constraint.secondAttribute == .trailing))
            if isShadowLeadingOrTrailing {
                constraint.isActive = false
            }
        }

        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        let initialWidth = calculateDockWidth(itemCount: 5)
        let widthConstraint = shadowView.widthAnchor.constraint(equalToConstant: initialWidth)
        widthConstraint.isActive = true
        self.dockWidthConstraint = widthConstraint
    }

    private func calculateDockWidth(itemCount: Int) -> CGFloat {
        let count = max(1, itemCount)
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let maxAvailableWidth = screenWidth - 32
        let slotWidth: CGFloat = min(72, maxAvailableWidth / 5.0)
        let targetWidth = CGFloat(count) * slotWidth
        return min(targetWidth, maxAvailableWidth)
    }

    private func updateDockWidth(for itemCount: Int, animated: Bool = true) {
        let targetWidth = calculateDockWidth(itemCount: itemCount)
        dockWidthConstraint?.constant = targetWidth
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.view.layoutIfNeeded()
        }
    }

    private func updateDockAppearance() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        tabBarContainer.backgroundColor = isDark
            ? UIColor(white: 0.12, alpha: 0.75)
            : UIColor(white: 0.98, alpha: 0.82)
        tabBarContainer.layer.borderColor = isDark
            ? UIColor.white.withAlphaComponent(0.14).cgColor
            : UIColor.black.withAlphaComponent(0.08).cgColor
        tabBarContainer.layer.borderWidth = 1
        dockBlurView.effect = UIBlurEffect(style: isDark ? .systemMaterialDark : .systemMaterialLight)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateDockAppearance()
        }
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
        self.updateDockWidth(for: items.count)
    }

    func set(selected: MenuItemType) {
        self.menuTabBar.set(selected: selected)
        if let index = pages.firstIndex(where: { $0.type == selected }) {
            self.pagerView.scrollTo(index: index, animated: false)
        }
    }

    func change(visible: Bool, for item: MenuItemType) {
        self.menuTabBar.change(visible: visible, for: item)
        let visibleCount = self.menuTabBar.views.filter { !$0.isHidden }.count
        self.updateDockWidth(for: visibleCount)
    }
}

final class MenuTabController: UIStackView {
    var views: [MenuItemView] = []

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
