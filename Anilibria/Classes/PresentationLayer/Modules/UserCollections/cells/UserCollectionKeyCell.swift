//
//  UserCollectionKeyCell.swift
//  AniLiberty
//

import UIKit
import Combine

public final class UserCollectionKeyCell: RippleViewCell {
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var backView: UIView!

    private var bag: AnyCancellable?

    public override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.systemFont(ofSize: 13.5, weight: .semibold)
        backView.layer.cornerCurve = .continuous
        backView.smoothCorners(with: backView.bounds.height / 2)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        backView.smoothCorners(with: backView.bounds.height / 2)
    }

    func configure(_ item: UserCollectionKeyViewModel) {
        titleLabel.text = item.key.title
        iconView.image = item.key.icon
        set(selected: item.isSelected, animated: false)
        bag = item.$isSelected.dropFirst().sink(receiveValue: { [weak self] value in
            self?.set(selected: value, animated: true)
        })
    }

    func set(selected: Bool, animated: Bool) {
        func apply() {
            if selected {
                backView.backgroundColor = .Tint.active
                backView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
                backView.layer.borderWidth = 0.5
                titleLabel.textColor = .white
                iconView.tintColor = .white
            } else {
                backView.backgroundColor = UIColor(white: 1.0, alpha: 0.08)
                backView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
                backView.layer.borderWidth = 0.5
                titleLabel.textColor = .Text.secondary
                iconView.tintColor = .Text.secondary
            }
        }

        if animated {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0.5,
                options: [.allowUserInteraction, .beginFromCurrentState],
                animations: apply
            )
        } else {
            apply()
        }
    }
}
