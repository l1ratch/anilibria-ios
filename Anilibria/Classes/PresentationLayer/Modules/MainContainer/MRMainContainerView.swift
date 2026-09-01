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
        setupFloatingDock()
        setupPager()
        handler.didLoad()
        view.backgroundColor = .Surfaces.background
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDockCorners()
    }

    private func setupFloatingDock() {
        shadowView.backgroundColor = .clear
        shadowView.shadowColor = UIColor.black.withAlphaComponent(0.4)
        shadowView.shadowY = 6
        shadowView.shadowRadius = 18

        tabBarContainer.backgroundColor = .clear
        tabBarContainer.layer.cornerCurve = .continuous
        tabBarContainer.layer.borderWidth = 0.75
        tabBarContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor

        // Remove old subviews from background
        glassBlurView?.removeFromSuperview()

        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.layer.cornerCurve = .continuous
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.clipsToBounds = true

        let tintOverlay = UIView()
        tintOverlay.backgroundColor = UIColor(white: 1.0, alpha: 0.03)
        tintOverlay.translatesAutoresizingMaskIntoConstraints = false
        tintOverlay.layer.cornerCurve = .continuous

        tabBarContainer.insertSubview(blurView, at: 0)
        tabBarContainer.insertSubview(tintOverlay, at: 1)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: tabBarContainer.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: tabBarContainer.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: tabBarContainer.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: tabBarContainer.trailingAnchor),

            tintOverlay.topAnchor.constraint(equalTo: tabBarContainer.topAnchor),
            tintOverlay.bottomAnchor.constraint(equalTo: tabBarContainer.bottomAnchor),
            tintOverlay.leadingAnchor.constraint(equalTo: tabBarContainer.leadingAnchor),
            tintOverlay.trailingAnchor.constraint(equalTo: tabBarContainer.trailingAnchor)
        ])

        self.glassBlurView = blurView
    }

    private func updateDockCorners() {
        // Subtle capsule rounding on the top/all edges of the dock
        let radius: CGFloat = 20
        tabBarContainer.layer.cornerRadius = radius
        glassBlurView?.layer.cornerRadius = radius
        if let tintOverlay = tabBarContainer.subviews.first(where: { $0 !== glassBlurView && $0 !== menuTabBar }) {
            tintOverlay.layer.cornerRadius = radius
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
        self.pages = MenuItemsControllersFactory.create(for: items)
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
