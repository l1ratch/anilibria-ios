import Combine
import UIKit

// MARK: - View Controller

final class SignInViewController: BaseViewController {
    @IBOutlet var loginField: MRTextField!
    @IBOutlet var passwordField: MRTextField!
    @IBOutlet var authProvidersView: UIStackView!
    @IBOutlet var logInButton: RippleButton!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var resetButton: UIButton!

    private var providersBag: Set<AnyCancellable> = []

    var handler: SignInEventHandler!

    override var isNavigationBarVisible: Bool { false }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupModernUI()
        self.handler.didLoad()
        self.addKeyboardObservers()
        self.subscribes()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.handler.cancel()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        view.backgroundColor = .Surfaces.base
        loginField.superview?.applyAdaptiveBorder()
        passwordField.superview?.applyAdaptiveBorder()
        authProvidersView.arrangedSubviews.forEach { $0.applyAdaptiveBorder() }
    }

    private func setupModernUI() {
        view.backgroundColor = .Surfaces.base
        scrollView.backgroundColor = .clear
        if let contentView = scrollView.subviews.first {
            contentView.backgroundColor = .clear
        }

        scrollView.alwaysBounceVertical = false
        scrollView.bounces = false
        scrollView.isScrollEnabled = false

        // English / ASCII keyboard defaults & AutoFill hints
        loginField.keyboardType = .asciiCapable
        loginField.textContentType = .username
        loginField.autocorrectionType = .no
        loginField.spellCheckingType = .no
        loginField.autocapitalizationType = .none

        passwordField.keyboardType = .asciiCapable
        passwordField.textContentType = .password
        passwordField.autocorrectionType = .no
        passwordField.spellCheckingType = .no

        // Style textfield card containers
        if let loginContainer = loginField.superview {
            loginContainer.backgroundColor = .Surfaces.content
            loginContainer.layer.cornerRadius = 14
            loginContainer.layer.cornerCurve = .continuous
            loginContainer.applyAdaptiveBorder()
            loginField.targetView?.isHidden = true
        }

        if let passwordContainer = passwordField.superview {
            passwordContainer.backgroundColor = .Surfaces.content
            passwordContainer.layer.cornerRadius = 14
            passwordContainer.layer.cornerCurve = .continuous
            passwordContainer.applyAdaptiveBorder()
            passwordField.targetView?.isHidden = true
        }

        for field in [loginField, passwordField] {
            guard let field = field, let container = field.superview else { continue }
            field.translatesAutoresizingMaskIntoConstraints = false
            for c in container.constraints where c.firstItem as? UIView == field || c.secondItem as? UIView == field {
                c.isActive = false
            }
            NSLayoutConstraint.activate([
                field.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                field.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                field.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                field.heightAnchor.constraint(equalToConstant: 24),
                container.heightAnchor.constraint(equalToConstant: 50)
            ])
        }

        // Modern Login button
        logInButton.translatesAutoresizingMaskIntoConstraints = false
        if let h = logInButton.constraints.first(where: { $0.firstAttribute == .height }) {
            h.constant = 50
        }
        logInButton.layer.cornerRadius = 14
        logInButton.layer.cornerCurve = .continuous
        logInButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        logInButton.setTitleColor(.white, for: .normal)
        logInButton.setTitleColor(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(white: 0.45, alpha: 1) : UIColor(white: 0.55, alpha: 1)
        }, for: .disabled)

        // Close button: modern 36x36 circular button
        if let closeCircle = closeButton.superview {
            closeCircle.translatesAutoresizingMaskIntoConstraints = false
            closeCircle.layer.cornerRadius = 20
            closeCircle.clipsToBounds = true
            closeCircle.backgroundColor = UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor.white.withAlphaComponent(0.12)
                    : UIColor.black.withAlphaComponent(0.06)
            }
        }
    }

    override func setupStrings() {
        super.setupStrings()
        loginField.placeholder = L10n.Screen.Auth.login
        loginField.placeHolderColor = .Text.secondary
        passwordField.placeholder = L10n.Screen.Auth.password
        passwordField.placeHolderColor = .Text.secondary
        logInButton.setTitle(L10n.Buttons.signIn, for: .normal)

        logInButton.enabledColor = .Buttons.selected
        logInButton.disabledColor = .Buttons.unselected
        logInButton.cornerRadius = 14

        signUpButton.setTitle(L10n.Buttons.signUp, for: .normal)
        resetButton.setTitle(L10n.Buttons.resetPassword, for: .normal)
    }

    private func subscribes() {
        Publishers.ThreadSafeCombineLatest(
            self.loginField.textPublisher.map { $0 ?? "" },
            self.passwordField.textPublisher.map { $0 ?? "" }
        )
        .sink(onNext: { [weak self] in
            self?.logInButton.isEnabled = !($0.isEmpty || $1.isEmpty)
        })
        .store(in: &subscribers)
    }

    override func keyBoardWillShow(keyboardHeight: CGFloat) {
        self.scrollView.isScrollEnabled = true
        self.scrollView.contentInset.bottom = keyboardHeight
    }

    override func keyBoardWillHide() {
        self.scrollView.isScrollEnabled = false
        self.scrollView.contentInset.bottom = 0
        self.scrollView.setContentOffset(.zero, animated: true)
    }

    // MARK: - Actions

    @IBAction func closeAction(_ sender: Any) {
        self.handler.back()
    }

    @IBAction func loginAction(_ sender: Any) {
        self.handler.login(
            login: loginField.text ?? "",
            password: passwordField.text ?? ""
        )
        view.endEditing(true)
    }

    @IBAction func signUpAction() {
        handler.signUp()
    }

    @IBAction func resetAction() {
        handler.resetPassword()
    }
}

extension SignInViewController: SignInViewBehavior {
    func set(providers: [AuthProvider]) {
        providersBag.removeAll()
        authProvidersView.subviews.forEach {
            authProvidersView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        providers.forEach { provider in
            let button = makeAuthButton(provider: provider)
            authProvidersView.addArrangedSubview(button)
        }
    }

    private func makeAuthButton(provider: AuthProvider) -> UIButton {
        let button = RippleButton()
        button.backgroundColor = .Surfaces.content
        button.smoothCorners(with: 14)
        button.applyAdaptiveBorder()
        button.setImage(provider.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .Text.main
        button.publisher(for: .touchUpInside).sink { [weak self] in
            self?.handler.login(with: provider)
        }.store(in: &providersBag)

        button.widthAnchor.constraint(equalToConstant: 46).isActive = true
        button.heightAnchor.constraint(equalToConstant: 46).isActive = true
        return button
    }
}

private extension AuthProvider {
    var image: UIImage {
        switch self {
        case .vk: return .iconVk
        case .google: return .iconGoogle
        case .patreon: return .iconPatreon
        case .discord: return .iconDiscord
        }
    }
}
