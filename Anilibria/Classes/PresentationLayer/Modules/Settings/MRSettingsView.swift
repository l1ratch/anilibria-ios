import UIKit
import Combine

// MARK: - View Controller

final class SettingsViewController: BaseViewController {
    @IBOutlet var commonTitleLabel: UILabel!
    @IBOutlet var commonStackView: UIStackView!

    @IBOutlet var playerTitleLabel: UILabel!
    @IBOutlet var playerStackView: UIStackView!

    @IBOutlet var customizationTitleLabel: UILabel!
    @IBOutlet var customizationStackView: UIStackView!

    var handler: SettingsEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCards()
    }

    private func setupCards() {
        for card in [
            commonStackView?.superview?.superview,
            playerStackView?.superview?.superview,
            customizationStackView?.superview?.superview
        ] {
            card?.smoothCorners(with: 16)
            card?.layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor
            card?.layer.borderWidth = 1
        }
    }

    override func setupStrings() {
        super.setupStrings()
        self.handler.didLoad()
        self.navigationItem.title = L10n.Screen.Settings.title
        self.commonTitleLabel.text = L10n.Screen.Settings.common
        self.playerTitleLabel?.text = "Плеер"
        self.customizationTitleLabel?.text = "Кастомизация"
    }
}

extension SettingsViewController: SettingsViewBehavior {
    func set(common items: [SettingsControlItem]) {
        commonStackView.arrangedSubviews.forEach {
            commonStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        items.forEach {
            let view = SettingsControlView()
            view.configure(item: $0)
            commonStackView.addArrangedSubview(view)
        }
    }

    func set(player items: [SettingsControlItem]) {
        guard let playerStackView = playerStackView else { return }
        playerStackView.arrangedSubviews.forEach {
            playerStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        items.forEach {
            let view = SettingsControlView()
            view.configure(item: $0)
            playerStackView.addArrangedSubview(view)
        }
    }

    func set(customization items: [SettingsControlItem]) {
        guard let customizationStackView = customizationStackView else { return }
        customizationStackView.arrangedSubviews.forEach {
            customizationStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        items.forEach {
            let view = SettingsControlView()
            view.configure(item: $0)
            customizationStackView.addArrangedSubview(view)
        }
    }
}
