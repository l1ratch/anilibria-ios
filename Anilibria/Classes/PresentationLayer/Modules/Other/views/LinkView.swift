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
        self.layer.cornerCurve = .continuous
        self.smoothCorners(with: 20)
        self.backgroundColor = .Surfaces.content
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
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
        
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: [], animations: {
                self.transform = .identity
            })
        }
        
        if let value = data {
            self.handler?(value)
        }
    }
}
