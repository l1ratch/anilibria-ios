import UIKit

// MARK: - View Controller

final class OtherViewController: BaseViewController {
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var authButton: UIButton!
    @IBOutlet var linksStackView: UIStackView!

    @IBOutlet var linkDeviceLabel: UILabel!
    @IBOutlet var linkDeviceView: UIView!
    @IBOutlet var historyTitleLabel: UILabel!
    @IBOutlet var historyView: UIView!
    @IBOutlet var teamTitleLabel: UILabel!
    @IBOutlet var donateTitleLabel: UILabel!
    @IBOutlet var settingsTitleLabel: UILabel!

    var handler: OtherEventHandler!

    override var isNavigationBarVisible: Bool { false }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLiquidGlassStyle()

        if UIDevice.current.userInterfaceIdiom == .pad {
            historyView.isHidden = true
        }
    }

    private func setupLiquidGlassStyle() {
        view.backgroundColor = .Surfaces.background
        userNameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        userNameLabel.textColor = .Text.main

        authButton.smoothCorners(with: 16)
        authButton.backgroundColor = UIColor.Tint.active.withAlphaComponent(0.15)
        authButton.layer.borderColor = UIColor.Tint.active.withAlphaComponent(0.4).cgColor
        authButton.layer.borderWidth = 0.75
        authButton.setTitleColor(.Tint.active, for: .normal)
        authButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        authButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)

        // Style all BorderedView containers as grouped glass cards
        view.subviews.forEach { sub in
            applyGlassRecursively(sub)
        }
    }

    private func applyGlassRecursively(_ view: UIView) {
        if let bordered = view as? BorderedView {
            bordered.smoothCorners(with: 20)
            bordered.backgroundColor = UIColor.Surfaces.content.withAlphaComponent(0.65)
            bordered.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
            bordered.layer.borderWidth = 0.75
        }
        view.subviews.forEach { applyGlassRecursively($0) }
    }

    override func setupStrings() {
        super.setupStrings()
        handler.didLoad()
        linkDeviceLabel.text = L10n.Screen.LinkDevice.title
        historyTitleLabel.text = L10n.Screen.Feed.history
        teamTitleLabel.text = L10n.Screen.Other.team
        donateTitleLabel.text = L10n.Screen.Other.donate
        settingsTitleLabel.text = L10n.Screen.Settings.title
    }

    // MARK: - Actions

    @IBAction func loginLogOutAction(_ sender: Any) {
        triggerHaptic(style: .light)
        self.handler.loginOrLogout()
    }

    @IBAction func historyAction(_ sender: Any) {
        triggerHaptic(style: .light)
        self.handler.history()
    }

    @IBAction func teamAction(_ sender: Any) {
        triggerHaptic(style: .light)
        self.handler.team()
    }

    @IBAction func donateAction(_ sender: Any) {
        triggerHaptic(style: .light)
        self.handler.donate()
    }

    @IBAction func settingsAction(_ sender: Any) {
        triggerHaptic(style: .light)
        self.handler.settings()
    }

    @IBAction func linkDeviceAction(_ sender: Any) {
        triggerHaptic(style: .light)
        self.handler.linkDevice()
    }
}

extension OtherViewController: OtherViewBehavior {
    func set(user: User?, loading: Bool) {
        self.userNameLabel.isHidden = loading
        self.authButton.isHidden = loading
        self.userNameLabel.text = user?.name ?? L10n.Common.guest
        if user == nil {
            self.authButton.setTitle(L10n.Buttons.signIn, for: .normal)
            self.linkDeviceView.isHidden = true
        } else {
            self.authButton.setTitle(L10n.Buttons.signOut, for: .normal)
            self.linkDeviceView.isHidden = false
        }
    }

    func set(links: [LinkData]) {
        let views = links.lazy.compactMap { item -> LinkView? in
            let view = LinkView.fromNib()
            view?.configure(item)
            view?.setTap { [weak self] in
                self?.handler.tap(link: $0)
            }
            return view
        }
        self.linksStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        for view in views {
            self.linksStackView.addArrangedSubview(view)
        }
    }
}
