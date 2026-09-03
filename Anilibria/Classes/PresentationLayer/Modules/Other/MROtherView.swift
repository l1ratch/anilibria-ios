import UIKit
import Kingfisher

// MARK: - View Controller

final class OtherViewController: BaseViewController {
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var authButton: UIButton!
    @IBOutlet var linksStackView: UIStackView!
    @IBOutlet var contentStackView: UIStackView!

    @IBOutlet var linkDeviceLabel: UILabel!
    @IBOutlet var linkDeviceView: UIView!
    @IBOutlet var historyTitleLabel: UILabel!
    @IBOutlet var historyView: UIView!
    @IBOutlet var teamTitleLabel: UILabel!
    @IBOutlet var donateTitleLabel: UILabel!
    @IBOutlet var settingsTitleLabel: UILabel!

    private let profileCardView = OtherProfileCardView()

    var handler: OtherEventHandler!

    override var isNavigationBarVisible: Bool { false }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if UIDevice.current.userInterfaceIdiom == .pad {
            historyView.isHidden = true
        }
        setupCards()
    }

    private func setupCards() {
        for card in [linkDeviceView?.superview?.superview, settingsTitleLabel?.superview?.superview, teamTitleLabel?.superview?.superview?.superview] {
            card?.smoothCorners(with: 16)
            card?.layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor
            card?.layer.borderWidth = 1
        }

        if let contentStackView = contentStackView {
            profileCardView.translatesAutoresizingMaskIntoConstraints = false
            if let socialLinksCard = linksStackView?.superview?.superview,
               let idx = contentStackView.arrangedSubviews.firstIndex(of: socialLinksCard) {
                contentStackView.insertArrangedSubview(profileCardView, at: idx)
            } else {
                contentStackView.addArrangedSubview(profileCardView)
            }
            NSLayoutConstraint.activate([
                profileCardView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor, constant: 16),
                profileCardView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: -16)
            ])
            profileCardView.onLoginTap = { [weak self] in
                self?.handler.loginOrLogout()
            }
            profileCardView.onLogoutTap = { [weak self] in
                self?.handler.loginOrLogout()
            }
        }
    }
    
    override func setupStrings() {
        super.setupStrings()
        handler.didLoad()
        userNameLabel.text = "AniLiberty"
        authButton.isHidden = true
        linkDeviceLabel.text = L10n.Screen.LinkDevice.title
        historyTitleLabel.text = L10n.Screen.Feed.history
        teamTitleLabel.text = L10n.Screen.Other.team
        donateTitleLabel.text = L10n.Screen.Other.donate
        settingsTitleLabel.text = L10n.Screen.Settings.title
    }

    // MARK: - Actions

    @IBAction func loginLogOutAction(_ sender: Any) {
        self.handler.loginOrLogout()
    }

    @IBAction func historyAction(_ sender: Any) {
        self.handler.history()
    }

    @IBAction func teamAction(_ sender: Any) {
        self.handler.team()
    }

    @IBAction func donateAction(_ sender: Any) {
        self.handler.donate()
    }

    @IBAction func settingsAction(_ sender: Any) {
        self.handler.settings()
    }

    @IBAction func linkDeviceAction(_ sender: Any) {
        self.handler.linkDevice()
    }
}

extension OtherViewController: OtherViewBehavior {
    func set(user: User?, loading: Bool) {
        self.userNameLabel.text = "AniLiberty"
        self.authButton.isHidden = true
        self.linkDeviceView.isHidden = (user == nil)
        self.profileCardView.configure(with: user)
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

// MARK: - Profile Card View

final class OtherProfileCardView: UIView {
    var onLoginTap: (() -> Void)?
    var onLogoutTap: (() -> Void)?

    private let containerView = UIView()

    // Auth subviews
    private let authStack = UIStackView()
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let logoutButton = UIButton(type: .system)

    // Guest subviews
    private let guestStack = UIStackView()
    private let guestIconView = UIImageView()
    private let guestTitleLabel = UILabel()
    private let guestSubtitleLabel = UILabel()
    private let chevronView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateTheme()
    }

    private func updateTheme() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        containerView.layer.borderColor = isDark
            ? UIColor.white.withAlphaComponent(0.08).cgColor
            : UIColor.black.withAlphaComponent(0.08).cgColor
    }

    private func setupViews() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 16
        containerView.layer.cornerCurve = .continuous
        containerView.layer.borderWidth = 1
        containerView.backgroundColor = .Surfaces.content
        containerView.clipsToBounds = true
        addSubview(containerView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        containerView.addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true

        // Setup Auth Stack
        authStack.axis = .horizontal
        authStack.alignment = .center
        authStack.spacing = 12
        authStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(authStack)

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 22
        avatarImageView.layer.cornerCurve = .continuous
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.tintColor = .Text.secondary
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44)
        ])
        authStack.addArrangedSubview(avatarImageView)

        let infoStack = UIStackView()
        infoStack.axis = .vertical
        infoStack.spacing = 2
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .Text.main
        nameLabel.numberOfLines = 1
        infoStack.addArrangedSubview(nameLabel)

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .Text.secondary
        subtitleLabel.numberOfLines = 1
        infoStack.addArrangedSubview(subtitleLabel)
        authStack.addArrangedSubview(infoStack)

        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        logoutButton.setTitle(Language.isEnglish ? "Sign Out" : "Выйти", for: .normal)
        logoutButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        logoutButton.tintColor = UIColor(named: "buttons/selected") ?? .systemRed
        logoutButton.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.08)
                : UIColor.black.withAlphaComponent(0.06)
        }
        logoutButton.layer.cornerRadius = 10
        logoutButton.layer.cornerCurve = .continuous
        logoutButton.clipsToBounds = true
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        logoutButton.setContentHuggingPriority(.required, for: .horizontal)
        authStack.addArrangedSubview(logoutButton)

        // Setup Guest Stack
        guestStack.axis = .horizontal
        guestStack.alignment = .center
        guestStack.spacing = 14
        guestStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(guestStack)

        let guestIconConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        guestIconView.image = UIImage(systemName: "person.crop.circle.badge.plus", withConfiguration: guestIconConfig)
        guestIconView.tintColor = UIColor(named: "buttons/selected") ?? .systemRed
        guestIconView.contentMode = .scaleAspectFit
        guestIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            guestIconView.widthAnchor.constraint(equalToConstant: 32),
            guestIconView.heightAnchor.constraint(equalToConstant: 32)
        ])
        guestStack.addArrangedSubview(guestIconView)

        let guestTextStack = UIStackView()
        guestTextStack.axis = .vertical
        guestTextStack.spacing = 2
        guestTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        guestTitleLabel.textColor = .Text.main
        guestTitleLabel.text = Language.isEnglish ? "Sign In to Account" : "Войти в аккаунт"
        guestTextStack.addArrangedSubview(guestTitleLabel)

        guestSubtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        guestSubtitleLabel.textColor = .Text.secondary
        guestSubtitleLabel.text = Language.isEnglish ? "Sync favorites and history" : "Синхронизация избранного и списков"
        guestTextStack.addArrangedSubview(guestSubtitleLabel)
        guestStack.addArrangedSubview(guestTextStack)

        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chevronView.image = UIImage(systemName: "chevron.right", withConfiguration: chevronConfig)
        chevronView.tintColor = .Text.secondary
        chevronView.contentMode = .scaleAspectFit
        guestStack.addArrangedSubview(chevronView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            authStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            authStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            authStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            authStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),

            guestStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            guestStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14),
            guestStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            guestStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }

    private var isUserAuthorized = false

    func configure(with user: User?) {
        isUserAuthorized = user != nil
        if let user = user {
            authStack.isHidden = false
            guestStack.isHidden = true
            nameLabel.text = user.name
            subtitleLabel.text = "AniLibria • ID: \(user.id)"
            if let avatarUrl = user.avatar {
                avatarImageView.setImage(from: avatarUrl, placeholder: DefaultPlaceholder())
            } else {
                avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
            }
            logoutButton.setTitle(Language.isEnglish ? "Sign Out" : "Выйти", for: .normal)
        } else {
            authStack.isHidden = true
            guestStack.isHidden = false
            avatarImageView.kf.cancelDownloadTask()
            avatarImageView.image = nil
            guestTitleLabel.text = Language.isEnglish ? "Sign In to Account" : "Войти в аккаунт"
            guestSubtitleLabel.text = Language.isEnglish ? "Sync favorites and history" : "Синхронизация избранного и списков"
        }
    }

    @objc private func didTapCard() {
        if !isUserAuthorized {
            onLoginTap?()
        }
    }

    @objc private func didTapLogout() {
        onLogoutTap?()
    }
}
