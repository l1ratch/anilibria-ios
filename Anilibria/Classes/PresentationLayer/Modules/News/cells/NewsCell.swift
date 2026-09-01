import UIKit

public final class NewsCell: RippleViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var viewsIconView: UIImageView!
    @IBOutlet var viewsCountLabel: UILabel!
    @IBOutlet var commentsIconView: UIImageView!
    @IBOutlet var commentsCountLabel: UILabel!

    private static let titleBuilder: AttributeStringBuilder = AttributeStringBuilder()
        .set(color: .Text.main)
        .set(font: UIFont.systemFont(ofSize: 15, weight: .semibold))

    public override func awakeFromNib() {
        super.awakeFromNib()
        imageView.smoothCorners(with: 16)
        imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        imageView.layer.borderWidth = 0.5
        rippleContainerView?.smoothCorners(with: 18)
        rippleContainerView?.backgroundColor = UIColor.Surfaces.content.withAlphaComponent(0.65)
        rippleContainerView?.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        rippleContainerView?.layer.borderWidth = 0.6
    }

    func configure(_ item: News) {
        self.titleLabel.attributedText = Self.titleBuilder.build(item.title)
        self.commentsCountLabel.text = "\(item.comments)"
        self.viewsCountLabel.text = "\(item.views)"
        self.imageView.setImage(from: item.image,
                                placeholder: DefaultPlaceholder())
        self.viewsIconView.tintColor = .Text.secondary
        self.commentsIconView.tintColor = .Text.secondary
        self.viewsCountLabel.textColor = .Text.secondary
        self.commentsCountLabel.textColor = .Text.secondary
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
