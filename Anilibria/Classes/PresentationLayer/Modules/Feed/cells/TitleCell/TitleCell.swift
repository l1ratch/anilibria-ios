import UIKit
import Combine

public final class TitleCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    
    private var langSubscriber: AnyCancellable?

    public override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .font(ofSize: 22, weight: .bold)
        titleLabel.textColor = .Text.main
    }

    func configure(_ item: TitleItem) {
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
