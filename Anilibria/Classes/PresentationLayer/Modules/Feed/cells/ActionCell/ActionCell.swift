import UIKit
import Combine

public final class ActionCell: RippleViewCell {
    @IBOutlet var titleLabel: UILabel!
    
    private var langSubscriber: AnyCancellable?
    private var currentItem: ActionItem?

    public override func awakeFromNib() {
        super.awakeFromNib()
        rippleContainerView?.smoothCorners(with: 12)
        rippleContainerView?.backgroundColor = UIColor(white: 1.0, alpha: 0.08)
        rippleContainerView?.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        rippleContainerView?.layer.borderWidth = 0.5
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .Text.main
    }

    func configure(_ item: ActionItem) {
        self.currentItem = item
        renderText(item)

        langSubscriber = Language.languageChanged.sink { [weak self] in
            guard let self, let item = self.currentItem else { return }
            self.renderText(item)
        }
    }

    private func renderText(_ item: ActionItem) {
        if let icon = item.icon {
            let attachment = NSTextAttachment()
            attachment.image = icon.withTintColor(.Tint.active, renderingMode: .alwaysOriginal)
            attachment.bounds = CGRect(x: 0, y: -3, width: 17, height: 17)
            let attString = NSMutableAttributedString(attachment: attachment)
            attString.append(NSAttributedString(string: "  " + item.localizedTitle(), attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                .foregroundColor: UIColor.Text.main
            ]))
            self.titleLabel.attributedText = attString
        } else {
            self.titleLabel.text = item.localizedTitle()
        }
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
