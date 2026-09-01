import UIKit

final class MenuItemView: LoadableView {
    @IBOutlet var iconView: UIImageView!
    private(set) var type: MenuItemType?

    private var tapHandler: Action<MenuItemType>?
    private let selectionPill = UIView()

    public var isSelected: Bool = false {
        didSet {
            updateSelectionState(animated: true)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupSelectionPill()
    }

    private func setupSelectionPill() {
        selectionPill.backgroundColor = UIColor.Tint.active.withAlphaComponent(0.18)
        selectionPill.layer.cornerCurve = .continuous
        selectionPill.layer.cornerRadius = 16
        selectionPill.layer.borderColor = UIColor.Tint.active.withAlphaComponent(0.35).cgColor
        selectionPill.layer.borderWidth = 0.75
        selectionPill.translatesAutoresizingMaskIntoConstraints = false
        selectionPill.alpha = 0
        selectionPill.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        insertSubview(selectionPill, belowSubview: iconView)

        NSLayoutConstraint.activate([
            selectionPill.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            selectionPill.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            selectionPill.widthAnchor.constraint(equalToConstant: 44),
            selectionPill.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    private func updateSelectionState(animated: Bool) {
        let targetColor: UIColor = isSelected ? .Tint.active : UIColor.white.withAlphaComponent(0.42)
        let targetScale: CGFloat = isSelected ? 1.08 : 1.0
        let pillAlpha: CGFloat = isSelected ? 1.0 : 0.0
        let pillScale: CGFloat = isSelected ? 1.0 : 0.7

        let changes = {
            self.iconView.tintColor = targetColor
            self.iconView.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
            self.selectionPill.alpha = pillAlpha
            self.selectionPill.transform = CGAffineTransform(scaleX: pillScale, y: pillScale)

            if self.isSelected {
                self.iconView.layer.shadowColor = UIColor.Tint.active.cgColor
                self.iconView.layer.shadowRadius = 8
                self.iconView.layer.shadowOpacity = 0.55
                self.iconView.layer.shadowOffset = .zero
            } else {
                self.iconView.layer.shadowOpacity = 0
            }
        }

        if animated {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.6,
                options: [.allowUserInteraction, .beginFromCurrentState],
                animations: changes
            )
        } else {
            changes()
        }
    }

    func configure(_ item: MenuItem) {
        self.iconView.image = item.icon
        self.type = item.type
        self.updateSelectionState(animated: false)
    }

    func setTap(_ handler: @escaping Action<MenuItemType>) {
        self.tapHandler = handler
    }

    @IBAction func tapAction(_ sender: Any) {
        if let type = self.type {
            triggerHaptic(style: .light)
            self.tapHandler?(type)
        }
    }
}
