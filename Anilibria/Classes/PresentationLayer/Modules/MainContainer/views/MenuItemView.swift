import UIKit

final class MenuItemView: LoadableView {
    @IBOutlet var iconView: UIImageView!
    private(set) var type: MenuItemType?

    private var tapHandler: Action<MenuItemType>?
    private let pillGlowView = UIView()

    public var isSelected: Bool = false {
        didSet {
            updateSelectionState(animated: true)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        iconView.contentMode = .center
        setupPillGlow()
    }

    private func setupPillGlow() {
        // Subtle spatial glow pill
        pillGlowView.backgroundColor = UIColor.Tint.active.withAlphaComponent(0.15)
        pillGlowView.layer.cornerCurve = .continuous
        pillGlowView.layer.cornerRadius = 22
        pillGlowView.translatesAutoresizingMaskIntoConstraints = false
        pillGlowView.alpha = 0
        pillGlowView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        insertSubview(pillGlowView, belowSubview: iconView)

        NSLayoutConstraint.activate([
            pillGlowView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            pillGlowView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            pillGlowView.widthAnchor.constraint(equalToConstant: 44),
            pillGlowView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func updateSelectionState(animated: Bool) {
        let targetColor: UIColor = isSelected ? .Tint.active : UIColor.white.withAlphaComponent(0.4)
        let targetScale: CGFloat = isSelected ? 1.08 : 1.0
        
        let glowAlpha: CGFloat = isSelected ? 1.0 : 0.0
        let glowScale: CGFloat = isSelected ? 1.0 : 0.5

        let changes = {
            self.iconView.tintColor = targetColor
            self.iconView.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
            self.pillGlowView.alpha = glowAlpha
            self.pillGlowView.transform = CGAffineTransform(scaleX: glowScale, y: glowScale)
            
            if self.isSelected {
                self.iconView.layer.shadowColor = UIColor.Tint.active.cgColor
                self.iconView.layer.shadowRadius = 8
                self.iconView.layer.shadowOpacity = 0.5
                self.iconView.layer.shadowOffset = .zero
            } else {
                self.iconView.layer.shadowOpacity = 0
            }
        }

        if animated {
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.65,
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
