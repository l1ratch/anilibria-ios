import UIKit

final class MenuItemView: LoadableView {
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var actionButton: RippleButton!
    private(set) var type: MenuItemType?

    private var tapHandler: Action<MenuItemType>?
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?

    public var isSelected: Bool = false {
        didSet {
            self.iconView.tintColor = if isSelected {
                .Tint.active
            } else {
                .Tint.main
            }
        }
    }

    override func setupNib() {
        super.setupNib()
        translatesAutoresizingMaskIntoConstraints = false

        let width = widthAnchor.constraint(equalToConstant: 42)
        width.priority = UILayoutPriority(999)
        width.isActive = true
        widthConstraint = width

        let height = heightAnchor.constraint(equalToConstant: 42)
        height.priority = UILayoutPriority(999)
        height.isActive = true
        heightConstraint = height

        actionButton.clipsToBounds = true
        actionButton.layer.cornerCurve = .continuous
        actionButton.layer.cornerRadius = 21
        actionButton.rippleColor = UIColor.Tint.main.withAlphaComponent(0.6)

        actionButton.addTarget(self, action: #selector(touchDownAnimation), for: [.touchDown, .touchDragEnter])
        actionButton.addTarget(self, action: #selector(touchUpAnimation), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = min(actionButton.bounds.width, actionButton.bounds.height) / 2
        if actionButton.layer.cornerRadius != radius {
            actionButton.layer.cornerRadius = radius
        }
    }

    func updateSize(_ size: CGFloat) {
        widthConstraint?.constant = size
        heightConstraint?.constant = size
    }

    @objc private func touchDownAnimation() {
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: 0.86, y: 0.86)
        }
    }

    @objc private func touchUpAnimation() {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction]
        ) {
            self.transform = .identity
        }
    }

    func configure(_ item: MenuItem) {
        self.iconView.image = item.icon
        self.type = item.type
    }

    func setTap(_ handler: @escaping Action<MenuItemType>) {
        self.tapHandler = handler
    }

    @IBAction func tapAction(_ sender: Any) {
        if let type = self.type {
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
            self.tapHandler?(type)
        }
    }
}
