import UIKit
import Combine

public final class ActionCell: RippleViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    private var langSubscriber: AnyCancellable?

    public override func awakeFromNib() {
        super.awakeFromNib()
        rippleContainerView?.smoothCorners(with: 14)
        rippleContainerView?.layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor
        rippleContainerView?.layer.borderWidth = 1
    }

    func configure(_ item: ActionItem) {
        self.titleLabel.text = item.localizedTitle()
        langSubscriber = Language.languageChanged.sink { [weak self] in
            self?.titleLabel.text = item.localizedTitle()
        }
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
