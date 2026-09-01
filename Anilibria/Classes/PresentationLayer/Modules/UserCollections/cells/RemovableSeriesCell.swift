import UIKit

public final class RemovableSeriesCell: DraggableRippleCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var deleteIconView: UIView!

    private var deleteHandler: ActionFunc?

    private static let textBuilder: AttributeStringBuilder = AttributeStringBuilder()
        .set(font: .font(ofSize: 14, weight: .regular))
        .set(color: .Text.secondary)
        .set(lineBreakMode: .byTruncatingTail)

    public override func awakeFromNib() {
        super.awakeFromNib()
        draggableView.swipeOffset = 100
        titleLabel.font = .font(ofSize: 16, weight: .bold)
        titleLabel.textColor = .Text.main
        imageView.smoothCorners(with: 12)
        containerView.smoothCorners(with: 16)
        containerView.backgroundColor = UIColor.Surfaces.content.withAlphaComponent(0.65)
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        containerView.layer.borderWidth = 0.6
    }

    func configure(_ item: Series) {
        self.deleteIconView.transform = .identity
        self.imageView.setImage(from: item.poster, placeholder: DefaultPlaceholder())
        self.titleLabel.text = item.name?.main ?? ""
        self.descLabel.attributedText = Self.textBuilder.build(item.desc?.string ?? "")
    }

    func setDelete(handler: ActionFunc?) {
        self.deleteHandler = handler
    }

    @IBAction func deleteAction(_ sender: Any) {
        self.deleteHandler?()
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }

    public override func callPrimaryAction() {
        self.deleteHandler?()
    }

    public override func willCallPrimaryAction() {
        apply(transform: .init(scaleX: 1.5, y: 1.5))
    }

    public override func cancelCallPrimaryAction() {
        apply(transform: .identity)
    }

    private func apply(transform: CGAffineTransform) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.deleteIconView.transform = transform
            }
        )
    }
}
