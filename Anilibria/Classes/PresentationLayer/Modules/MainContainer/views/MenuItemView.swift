import UIKit

final class MenuItemView: LoadableView {
    @IBOutlet var iconView: UIImageView!
    private(set) var type: MenuItemType?

    private var tapHandler: Action<MenuItemType>?

    public var isSelected: Bool = false {
        didSet {
            updateSelectionState(animated: true)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        iconView.contentMode = .center
    }

    private func updateSelectionState(animated: Bool) {
        let targetColor: UIColor = isSelected ? .Tint.active : UIColor.white.withAlphaComponent(0.4)
        let targetScale: CGFloat = isSelected ? 1.08 : 1.0

        let changes = {
            self.iconView.tintColor = targetColor
            self.iconView.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
        }

        if animated {
            UIView.animate(
                withDuration: 0.25,
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
            self.tapHandler?(type)
        }
    }
}
