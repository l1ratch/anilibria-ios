import UIKit

final class MenuItemView: LoadableView {
    @IBOutlet var bubbleView: UIView!
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
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
        
        bubbleView.layer.cornerCurve = .continuous
        bubbleView.layer.cornerRadius = 22
        bubbleView.layer.masksToBounds = true
    }

    private func updateSelectionState(animated: Bool) {
        let activeBg = UIColor.black.withAlphaComponent(0.65)
        let activeBorder = UIColor.white.withAlphaComponent(0.15)
        
        let targetBg: UIColor = isSelected ? activeBg : .clear
        let targetBorder: UIColor = isSelected ? activeBorder : .clear
        let targetIconColor: UIColor = isSelected ? .white : UIColor.white.withAlphaComponent(0.6)
        let targetTextColor: UIColor = isSelected ? .white : UIColor.white.withAlphaComponent(0.6)
        let targetTextWeight: UIFont.Weight = isSelected ? .bold : .medium

        let changes = {
            self.bubbleView.backgroundColor = targetBg
            self.bubbleView.layer.borderColor = targetBorder.cgColor
            self.bubbleView.layer.borderWidth = self.isSelected ? 0.5 : 0.0
            self.iconView.tintColor = targetIconColor
            self.titleLabel.textColor = targetTextColor
            self.titleLabel.font = .systemFont(ofSize: 10, weight: targetTextWeight)
            self.bubbleView.transform = self.isSelected ? CGAffineTransform(scaleX: 1.04, y: 1.04) : .identity
        }

        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0.4,
                options: [.allowUserInteraction, .beginFromCurrentState],
                animations: changes
            )
        } else {
            changes()
        }
    }

    func configure(_ item: MenuItem) {
        self.iconView.image = item.icon?.withRenderingMode(.alwaysTemplate)
        self.type = item.type
        
        switch item.type {
        case .feed: titleLabel.text = "Главная"
        case .catalog: titleLabel.text = "Релизы"
        case .news: titleLabel.text = "Новости"
        case .collections: titleLabel.text = "Коллекции"
        case .other: titleLabel.text = "Другое"
        }
        
        self.updateSelectionState(animated: false)
    }

    func setTap(_ handler: @escaping Action<MenuItemType>) {
        self.tapHandler = handler
    }

    @IBAction func tapAction(_ sender: Any) {
        if let type = self.type {
            triggerHaptic(style: .light)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            }) { _ in
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: [], animations: {
                    self.transform = .identity
                })
            }
            
            self.tapHandler?(type)
        }
    }
}
