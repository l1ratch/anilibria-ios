import UIKit

final class MenuItemView: LoadableView {
    @IBOutlet var iconView: UIImageView!
    private(set) var type: MenuItemType?

    private var tapHandler: Action<MenuItemType>?
    private let pillCapsuleView = UIView()

    public var isSelected: Bool = false {
        didSet {
            updateSelectionState(animated: true)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        iconView.contentMode = .center
        setupPillCapsule()
    }

    private func setupPillCapsule() {
        pillCapsuleView.layer.cornerCurve = .continuous
        pillCapsuleView.layer.cornerRadius = 18
        pillCapsuleView.layer.masksToBounds = true
        pillCapsuleView.translatesAutoresizingMaskIntoConstraints = false
        pillCapsuleView.isUserInteractionEnabled = false

        insertSubview(pillCapsuleView, belowSubview: iconView)

        NSLayoutConstraint.activate([
            pillCapsuleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            pillCapsuleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            pillCapsuleView.widthAnchor.constraint(equalToConstant: 48),
            pillCapsuleView.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func updateSelectionState(animated: Bool) {
        let targetIconColor: UIColor = isSelected ? .Tint.active : UIColor.white.withAlphaComponent(0.45)
        let targetBgColor: UIColor = isSelected ? UIColor.white.withAlphaComponent(0.12) : .clear
        let targetBorderColor: UIColor = isSelected ? UIColor.white.withAlphaComponent(0.2) : .clear
        let targetScale: CGFloat = isSelected ? 1.05 : 1.0

        let changes = {
            self.iconView.tintColor = targetIconColor
            self.iconView.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
            self.pillCapsuleView.backgroundColor = targetBgColor
            self.pillCapsuleView.layer.borderColor = targetBorderColor.cgColor
            self.pillCapsuleView.layer.borderWidth = self.isSelected ? 0.5 : 0.0
        }

        if animated {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
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
            
            // Micro bounce feedback
            UIView.animate(withDuration: 0.12, animations: {
                self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            }) { _ in
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: [], animations: {
                    self.transform = .identity
                })
            }
            
            self.tapHandler?(type)
        }
    }
}
