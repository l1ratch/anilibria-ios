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
        selectionPill.backgroundColor = UIColor(red: 255/255, green: 45/255, blue: 70/255, alpha: 0.2)
        selectionPill.layer.cornerCurve = .continuous
        selectionPill.layer.cornerRadius = 22
        selectionPill.layer.borderColor = UIColor(red: 255/255, green: 45/255, blue: 70/255, alpha: 0.45).cgColor
        selectionPill.layer.borderWidth = 0.75
        selectionPill.translatesAutoresizingMaskIntoConstraints = false
        selectionPill.alpha = 0
        selectionPill.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        insertSubview(selectionPill, belowSubview: iconView)

        NSLayoutConstraint.activate([
            selectionPill.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            selectionPill.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            selectionPill.widthAnchor.constraint(equalToConstant: 44),
            selectionPill.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func updateSelectionState(animated: Bool) {
        let targetColor: UIColor = isSelected ? .Tint.active : UIColor.white.withAlphaComponent(0.4)
        let targetScale: CGFloat = isSelected ? 1.05 : 1.0
        let pillAlpha: CGFloat = isSelected ? 1.0 : 0.0
        let pillScale: CGFloat = isSelected ? 1.0 : 0.6

        let changes = {
            self.iconView.tintColor = targetColor
            self.iconView.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
            self.selectionPill.alpha = pillAlpha
            self.selectionPill.transform = CGAffineTransform(scaleX: pillScale, y: pillScale)

            if self.isSelected {
                self.iconView.layer.shadowColor = UIColor.Tint.active.cgColor
                self.iconView.layer.shadowRadius = 10
                self.iconView.layer.shadowOpacity = 0.6
                self.iconView.layer.shadowOffset = .zero
            } else {
                self.iconView.layer.shadowOpacity = 0
            }
        }

        if animated {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.65,
                initialSpringVelocity: 0.7,
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
