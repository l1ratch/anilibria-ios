//
//  UserCollectionsV2Views.swift
//  Anilibria
//
//  Created by Antigravity on 03.09.2026.
//

import UIKit

// MARK: - Section Header View

final class UserCollectionHeaderReusableView: UICollectionReusableView {
    static let reuseIdentifier = "UserCollectionHeaderReusableView"

    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let seeAllButton = UIButton(type: .system)

    var onSeeAllTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.layer.cornerRadius = 8
        iconContainer.layer.cornerCurve = .continuous
        iconContainer.clipsToBounds = true
        addSubview(iconContainer)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconImageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .Text.main
        addSubview(titleLabel)

        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        countLabel.textColor = .Text.secondary
        addSubview(countLabel)

        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.setTitle(Language.isEnglish ? "All  " : "Все  ", for: .normal)
        seeAllButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)), for: .normal)
        seeAllButton.semanticContentAttribute = .forceRightToLeft
        seeAllButton.tintColor = UIColor(named: "buttons/selected") ?? .systemRed
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        seeAllButton.addTarget(self, action: #selector(didTapSeeAll), for: .touchUpInside)
        addSubview(seeAllButton)

        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            iconContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 28),
            iconContainer.heightAnchor.constraint(equalToConstant: 28),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            countLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            seeAllButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    @objc private func didTapSeeAll() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onSeeAllTap?()
    }

    func configure(with key: UserCollectionKey, count: Int) {
        titleLabel.text = key.title
        countLabel.text = count > 0 ? "(\(count))" : ""

        let accent = UIColor(named: "buttons/selected") ?? .systemRed

        switch key {
        case .watching:
            iconContainer.backgroundColor = accent.withAlphaComponent(0.18)
            iconImageView.tintColor = accent
            iconImageView.image = UIImage(systemName: "play.circle.fill")
        case .planned:
            iconContainer.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.18)
            iconImageView.tintColor = .systemOrange
            iconImageView.image = UIImage(systemName: "bookmark.fill")
        case .watched:
            iconContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.18)
            iconImageView.tintColor = .systemGreen
            iconImageView.image = UIImage(systemName: "checkmark.circle.fill")
        case .postponed:
            iconContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.18)
            iconImageView.tintColor = .systemBlue
            iconImageView.image = UIImage(systemName: "pause.circle.fill")
        case .abandoned:
            iconContainer.backgroundColor = UIColor.systemGray.withAlphaComponent(0.18)
            iconImageView.tintColor = .systemGray
            iconImageView.image = UIImage(systemName: "xmark.circle.fill")
        case .favorite:
            iconContainer.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.18)
            iconImageView.tintColor = .systemYellow
            iconImageView.image = UIImage(systemName: "star.fill")
        }
    }
}

// MARK: - Collection Card Cell

final class UserCollectionCardCell: UICollectionViewCell {
    static let reuseIdentifier = "UserCollectionCardCell"

    private let posterImageView = UIImageView()
    private let gradientView = UIView()
    private let gradientLayer = CAGradientLayer()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }

    private func setupViews() {
        contentView.backgroundColor = .clear

        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 14
        posterImageView.layer.cornerCurve = .continuous
        posterImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        posterImageView.layer.borderWidth = 1
        posterImageView.backgroundColor = .Surfaces.content
        contentView.addSubview(posterImageView)

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false
        gradientView.clipsToBounds = true
        gradientView.layer.cornerRadius = 14
        gradientView.layer.cornerCurve = .continuous
        posterImageView.addSubview(gradientView)

        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor
        ]
        gradientLayer.locations = [0.6, 1.0]
        gradientView.layer.addSublayer(gradientLayer)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .Text.main
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.textColor = .Text.secondary
        subtitleLabel.numberOfLines = 1
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 154),

            gradientView.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func configure(with series: Series) {
        posterImageView.setImage(from: series.poster, placeholder: DefaultPlaceholder())
        titleLabel.text = series.name?.main ?? series.alias

        let genres = series.genres.prefix(2).map { $0.name }.joined(separator: " • ")
        let defaultAnime = Language.isEnglish ? "Anime" : "Аниме"
        subtitleLabel.text = genres.isEmpty ? (series.season?.description ?? defaultAnime) : genres
    }
}

// MARK: - Empty State Cell

final class UserCollectionEmptyCell: UICollectionViewCell {
    static let reuseIdentifier = "UserCollectionEmptyCell"

    private let container = UIView()
    private let iconImageView = UIImageView()
    private let messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(white: 0.15, alpha: 0.4)
        container.layer.cornerRadius = 14
        container.layer.cornerCurve = .continuous
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        container.layer.borderWidth = 1
        contentView.addSubview(container)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "tray")
        iconImageView.tintColor = .Text.secondary
        iconImageView.contentMode = .scaleAspectFit
        container.addSubview(iconImageView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = Language.isEnglish ? "This list is currently empty" : "В этом списке пока пусто"
        messageLabel.font = .systemFont(ofSize: 13, weight: .medium)
        messageLabel.textColor = .Text.secondary
        container.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.heightAnchor.constraint(equalToConstant: 64),

            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            messageLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            messageLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}
