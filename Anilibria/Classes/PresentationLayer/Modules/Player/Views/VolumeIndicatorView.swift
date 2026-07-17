//
//  VolumeIndicatorView.swift
//  Anilibria
//
//  Desktop (Mac Catalyst) only transient overlay that shows the current
//  player volume level when it's changed via keyboard shortcuts.
//

import UIKit

final class VolumeIndicatorView: UIView {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        smoothCorners(with: bounds.height / 2)
    }

    func set(volume: Float, isMuted: Bool) {
        let percent = Int((volume * 100).rounded())
        titleLabel.text = "\(percent)%"

        let imageName: String
        if isMuted || volume == 0 {
            imageName = "speaker.slash.fill"
        } else if volume < 0.33 {
            imageName = "speaker.wave.1.fill"
        } else if volume < 0.66 {
            imageName = "speaker.wave.2.fill"
        } else {
            imageName = "speaker.wave.3.fill"
        }
        iconView.image = UIImage(systemName: imageName)
    }

    private func setup() {
        backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        layer.borderColor = backgroundColor?.cgColor
        layer.borderWidth = 1

        iconView.tintColor = .Text.monoLight
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        titleLabel.font = .monospacedSystemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .Text.monoLight

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
