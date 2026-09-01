import UIKit

public final class LinkView: UIView {
    @IBOutlet private var iconImageView: UIImageView!

    private var handler: Action<LinkData>?
    private var data: LinkData?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.smoothCorners(with: 14)
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.08)
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        self.layer.borderWidth = 0.5
    }

    func setTap(handler: Action<LinkData>?) {
        self.handler = handler
    }

    func configure(_ data: LinkData) {
        self.data = data
        self.iconImageView.image = data.linkType.icon?
            .withRenderingMode(.alwaysTemplate)
        self.iconImageView.tintColor = .Text.main
    }

    @IBAction func tapAction(_ sender: Any) {
        triggerHaptic(style: .light)
        if let value = data {
            self.handler?(value)
        }
    }
}
