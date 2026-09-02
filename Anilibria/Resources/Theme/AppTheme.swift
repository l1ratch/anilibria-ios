import UIKit

public protocol AppTheme {
    func apply()

    // MARK: - Colors

    var defaultFont: AppFont? { get }
}

public struct MainTheme: AppTheme {
    public static var shared: AppTheme = MainTheme()

    private init() {}

    public func apply() {
        self.configureNavBar()
        self.configureTabBar()
        self.configureTextView()
        self.configureCollectionView()
    }

    func configureNavBar() {
        let navbar = UINavigationBar.appearance()
        navbar.tintColor = .Tint.active
        navbar.prefersLargeTitles = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .Surfaces.background
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.Text.main,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.Text.main,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]
        appearance.shadowColor = .clear

        navbar.standardAppearance = appearance
        navbar.scrollEdgeAppearance = appearance
        navbar.compactAppearance = appearance
    }

    func configureTabBar() {
        let tabBar = UITabBar.appearance()
        tabBar.tintColor = .Tint.active

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
        appearance.backgroundColor = UIColor(white: 0.08, alpha: 0.8)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.55)
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.55),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
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
    }

    func configureTextView() {
        UITextView.appearance().tintColor = .Tint.active
        UITextField.appearance().tintColor = .Tint.active
        UICollectionView.appearance().backgroundColor = .clear
    }

    func configureCollectionView() {
        UICollectionView.appearance().isPrefetchingEnabled = true
    }

    // MARK: - Font

    public var defaultFont: AppFont?
}
