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
