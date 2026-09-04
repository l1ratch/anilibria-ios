//
//  FeedV2Views.swift
//  Anilibria
//
//  Created by Antigravity on 02.09.2026.
//

import UIKit

// MARK: - Hero Showcase Cell

final class FeedGradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
}

final class FeedV2HeroCell: UICollectionViewCell {
    static let reuseIdentifier = "FeedV2HeroCell"

    private let imageView = UIImageView()
    private let gradientView = FeedGradientView()
    private let badgeLabel = UILabel()
    private let badgeContainer = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton(type: .system)

    private var actionButtonBottomConstraint: NSLayoutConstraint!
    private var actionButtonTopConstraint: NSLayoutConstraint!
    private var actionButtonTrailingConstraint: NSLayoutConstraint!
    private var actionButtonHeightConstraint: NSLayoutConstraint!
    private var actionButtonWidthConstraint: NSLayoutConstraint!

    private var subtitleBottomToContent: NSLayoutConstraint!
    private var subtitleBottomToHint: NSLayoutConstraint!
    private var subtitleTrailingToButton: NSLayoutConstraint!
    private var subtitleTrailingToContent: NSLayoutConstraint!

    private let readMoreHintLabel = UILabel()

    var onActionTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 18
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        contentView.layer.borderWidth = 1
        contentView.backgroundColor = UIColor(white: 0.14, alpha: 1.0)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false
        contentView.addSubview(gradientView)

        gradientView.gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor,
            UIColor.black.withAlphaComponent(0.94).cgColor
        ]
        gradientView.gradientLayer.locations = [0.0, 0.35, 1.0]

        badgeContainer.clipsToBounds = true
        badgeContainer.layer.cornerRadius = 10
        badgeContainer.layer.cornerCurve = .continuous
        badgeContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        badgeContainer.layer.borderWidth = 0.5
        badgeContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(badgeContainer)

        badgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
        badgeLabel.textColor = .white
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeContainer.contentView.addSubview(badgeLabel)

        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.88)
        subtitleLabel.numberOfLines = 4
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)

        actionButton.setTitle("  Смотреть", for: .normal)
        actionButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        actionButton.tintColor = .white
        actionButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        actionButton.backgroundColor = UIColor(named: "buttons/selected") ?? .systemRed
        actionButton.layer.cornerRadius = 14
        actionButton.layer.cornerCurve = .continuous
        actionButton.clipsToBounds = true
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        contentView.addSubview(actionButton)

        readMoreHintLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        readMoreHintLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        readMoreHintLabel.translatesAutoresizingMaskIntoConstraints = false
        readMoreHintLabel.isHidden = true
        contentView.addSubview(readMoreHintLabel)

        actionButtonBottomConstraint = actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        actionButtonTopConstraint = actionButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14)
        actionButtonTrailingConstraint = actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14)
        actionButtonHeightConstraint = actionButton.heightAnchor.constraint(equalToConstant: 32)
        actionButtonWidthConstraint = actionButton.widthAnchor.constraint(equalToConstant: 110)

        subtitleBottomToContent = subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        subtitleBottomToHint = subtitleLabel.bottomAnchor.constraint(equalTo: readMoreHintLabel.topAnchor, constant: -3)
        subtitleTrailingToButton = subtitleLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -10)
        subtitleTrailingToContent = subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            badgeContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            badgeContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            badgeContainer.heightAnchor.constraint(equalToConstant: 22),

            badgeLabel.topAnchor.constraint(equalTo: badgeContainer.contentView.topAnchor, constant: 2),
            badgeLabel.bottomAnchor.constraint(equalTo: badgeContainer.contentView.bottomAnchor, constant: -2),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeContainer.contentView.leadingAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeContainer.contentView.trailingAnchor, constant: -8),

            actionButtonTrailingConstraint,
            actionButtonHeightConstraint,
            actionButtonWidthConstraint,

            readMoreHintLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            readMoreHintLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),

            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -4)
        ])
    }

    @objc private func didTapAction() {
        onActionTap?()
    }

    func configure(with item: PromoItem) {
        if let img = item.image {
            imageView.setImage(from: img, placeholder: DefaultPlaceholder())
            imageView.backgroundColor = .clear
        } else {
            imageView.image = nil
            imageView.backgroundColor = UIColor(white: 0.16, alpha: 1.0)
        }

        switch item.content {
        case .release(let series):
            badgeLabel.text = Language.isEnglish ? "🔥 TRENDING" : "🔥 В ТРЕНДЕ"
            titleLabel.text = series.name?.main ?? series.alias
            titleLabel.numberOfLines = 2
            let genres = series.genres.prefix(2).map { $0.name }.joined(separator: " • ")
            let defaultAnime = Language.isEnglish ? "Anime" : "Аниме"
            subtitleLabel.text = genres.isEmpty ? (series.season?.description ?? defaultAnime) : genres
            subtitleLabel.numberOfLines = 1

            actionButtonTopConstraint.isActive = false
            actionButtonBottomConstraint.isActive = true
            actionButtonHeightConstraint.constant = 32
            actionButtonWidthConstraint.constant = 110
            actionButton.layer.cornerRadius = 14
            actionButton.isHidden = false
            actionButton.setTitle(Language.isEnglish ? "  Watch" : "  Смотреть", for: .normal)
            actionButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            actionButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            actionButton.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
            actionButton.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
            actionButton.layer.borderWidth = 1

            readMoreHintLabel.isHidden = true
            subtitleBottomToHint.isActive = false
            subtitleBottomToContent.isActive = true
            subtitleTrailingToContent.isActive = false
            subtitleTrailingToButton.isActive = true

        case .ad(let ad):
            badgeLabel.text = Language.isEnglish ? "AD" : "РЕКЛАМА"
            titleLabel.text = ad.title
            titleLabel.numberOfLines = 2
            subtitleLabel.text = ad.info
            subtitleLabel.numberOfLines = 3

            // Button placed at top-right
            actionButtonBottomConstraint.isActive = false
            actionButtonTopConstraint.isActive = true
            actionButtonHeightConstraint.constant = 26
            actionButtonWidthConstraint.constant = 84
            actionButton.layer.cornerRadius = 13
            actionButton.isHidden = false
            actionButton.setTitle(Language.isEnglish ? "  Open" : "  Перейти", for: .normal)
            actionButton.setImage(UIImage(systemName: "arrow.up.right"), for: .normal)
            actionButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
            actionButton.backgroundColor = UIColor(named: "buttons/selected") ?? .systemRed
            actionButton.layer.borderWidth = 0

            readMoreHintLabel.isHidden = true
            subtitleTrailingToButton.isActive = false
            subtitleTrailingToContent.isActive = true
            subtitleBottomToHint.isActive = false
            subtitleBottomToContent.isActive = true

        case .promo(let promo):
            badgeLabel.text = Language.isEnglish ? "📢 ANNOUNCEMENT" : "📢 АНОНС"
            let title = promo.title?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let title = title, !title.isEmpty {
                titleLabel.text = title
            } else {
                titleLabel.text = Language.isEnglish ? "Announcement" : "Анонс"
            }
            titleLabel.numberOfLines = 1

            if promo.url != nil {
                subtitleLabel.text = item.info
                subtitleLabel.numberOfLines = 3

                // Button placed at top-right
                actionButtonBottomConstraint.isActive = false
                actionButtonTopConstraint.isActive = true
                actionButtonHeightConstraint.constant = 26
                actionButtonWidthConstraint.constant = 84
                actionButton.layer.cornerRadius = 13
                actionButton.isHidden = false
                actionButton.setTitle(Language.isEnglish ? "  Open" : "  Перейти", for: .normal)
                actionButton.setImage(UIImage(systemName: "arrow.up.right"), for: .normal)
                actionButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
                actionButton.backgroundColor = UIColor(named: "buttons/selected") ?? .systemRed
                actionButton.layer.borderWidth = 0

                readMoreHintLabel.isHidden = true
                subtitleTrailingToButton.isActive = false
                subtitleTrailingToContent.isActive = true
                subtitleBottomToHint.isActive = false
                subtitleBottomToContent.isActive = true
            } else {
                // Pure text post: full width, no button, non-overlapping hint only if long
                actionButton.isHidden = true
                actionButtonTopConstraint.isActive = false
                actionButtonBottomConstraint.isActive = false

                let text = item.info.trimmingCharacters(in: .whitespacesAndNewlines)
                subtitleLabel.text = text.isEmpty ? nil : text
                let isLong = text.count > 100

                readMoreHintLabel.text = Language.isEnglish ? "Details ›" : "Подробнее ›"
                readMoreHintLabel.isHidden = !isLong

                subtitleTrailingToButton.isActive = false
                subtitleTrailingToContent.isActive = true
                subtitleBottomToContent.isActive = !isLong
                subtitleBottomToHint.isActive = isLong
                subtitleLabel.numberOfLines = 4
            }

        case nil:
            // Pure text post: full width, no button, non-overlapping hint only if long
            badgeLabel.text = Language.isEnglish ? "📢 NEWS" : "📢 НОВОСТЬ"
            titleLabel.text = Language.isEnglish ? "Information" : "Информация"
            titleLabel.numberOfLines = 1

            actionButton.isHidden = true
            actionButtonTopConstraint.isActive = false
            actionButtonBottomConstraint.isActive = false

            let text = item.info.trimmingCharacters(in: .whitespacesAndNewlines)
            subtitleLabel.text = text.isEmpty ? nil : text
            let isLong = text.count > 100

            readMoreHintLabel.text = Language.isEnglish ? "Details ›" : "Подробнее ›"
            readMoreHintLabel.isHidden = !isLong

            subtitleTrailingToButton.isActive = false
            subtitleTrailingToContent.isActive = true
            subtitleBottomToContent.isActive = !isLong
            subtitleBottomToHint.isActive = isLong
            subtitleLabel.numberOfLines = 4
        }
    }
}

// MARK: - Quick Actions View

final class FeedV2QuickActionsView: UIView {
    var onRandomTap: (() -> Void)?
    var onScheduleTap: (() -> Void)?
    var onCatalogTap: (() -> Void)?

    private let stackView = UIStackView()
    private var actionButtons: [UIButton] = []

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
        updateBorders()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBorders()
    }

    private func updateBorders() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        let color = isDark
            ? UIColor.white.withAlphaComponent(0.12).cgColor
            : UIColor.black.withAlphaComponent(0.08).cgColor
        for btn in actionButtons {
            btn.layer.borderColor = color
        }
    }

    private func setupViews() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 48)
        ])

        let randomBtn = makeButton(
            title: Language.isEnglish ? "Random" : "Рандом",
            icon: "dice.fill",
            tint: UIColor(named: "buttons/selected") ?? .systemRed,
            action: #selector(didTapRandom)
        )
        let scheduleBtn = makeButton(
            title: Language.isEnglish ? "Week" : "Неделя",
            icon: "calendar",
            tint: .systemTeal,
            action: #selector(didTapSchedule)
        )
        let catalogBtn = makeButton(
            title: Language.isEnglish ? "Catalog" : "Каталог",
            icon: "square.grid.2x2.fill",
            tint: .systemOrange,
            action: #selector(didTapCatalog)
        )

        stackView.addArrangedSubview(randomBtn)
        stackView.addArrangedSubview(scheduleBtn)
        stackView.addArrangedSubview(catalogBtn)
    }

    private func makeButton(title: String, icon: String, tint: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 0.20, alpha: 0.6)
                : UIColor(white: 0.94, alpha: 0.95)
        }
        button.layer.cornerRadius = 14
        button.layer.cornerCurve = .continuous
        button.layer.borderWidth = 1
        button.clipsToBounds = true

        let iconImg = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
        button.setImage(iconImg, for: .normal)
        button.setTitle("  " + title, for: .normal)
        button.tintColor = tint
        button.setTitleColor(.Text.main, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.addTarget(self, action: action, for: .touchUpInside)

        actionButtons.append(button)
        return button
    }

    @objc private func didTapRandom() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onRandomTap?()
    }

    @objc private func didTapSchedule() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onScheduleTap?()
    }

    @objc private func didTapCatalog() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onCatalogTap?()
    }
}

//// MARK: - Continue Watching Cells

final class FeedV2ContinueWatchingCell: UICollectionViewCell {
    static let reuseIdentifier = "FeedV2ContinueWatchingCell"

    private let container = UIView()
    private let posterImageView = UIImageView()
    private let progressTrackView = UIView()
    private let progressFillView = UIView()
    private var progressWidthConstraint: NSLayoutConstraint?

    private let sectionLabel = UILabel()
    private let titleLabel = UILabel()
    private let episodeLabel = UILabel()
    private let playImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        progressTrackView.isHidden = true
        titleLabel.text = nil
        episodeLabel.text = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCardAppearance()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateCardAppearance()
    }

    private func updateCardAppearance() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        container.layer.borderColor = isDark
            ? UIColor.white.withAlphaComponent(0.10).cgColor
            : UIColor.black.withAlphaComponent(0.08).cgColor
    }

    private func setupViews() {
        contentView.backgroundColor = .clear

        container.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? .Surfaces.content
                : UIColor(white: 0.96, alpha: 0.95)
        }
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        container.layer.borderWidth = 1
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 10
        posterImageView.layer.cornerCurve = .continuous
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(posterImageView)

        // Progress bar on poster
        progressTrackView.translatesAutoresizingMaskIntoConstraints = false
        progressTrackView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        progressTrackView.clipsToBounds = true
        posterImageView.addSubview(progressTrackView)

        progressFillView.translatesAutoresizingMaskIntoConstraints = false
        progressFillView.backgroundColor = UIColor(named: "buttons/selected") ?? .systemRed
        progressTrackView.addSubview(progressFillView)

        let initialWidth = progressFillView.widthAnchor.constraint(equalTo: progressTrackView.widthAnchor, multiplier: 0)
        self.progressWidthConstraint = initialWidth

        NSLayoutConstraint.activate([
            progressTrackView.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            progressTrackView.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor),
            progressTrackView.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor),
            progressTrackView.heightAnchor.constraint(equalToConstant: 3),

            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor),
            initialWidth
        ])

        sectionLabel.text = Language.isEnglish ? "CONTINUE WATCHING" : "ПРОДОЛЖИТЬ ПРОСМОТР"
        sectionLabel.font = .systemFont(ofSize: 10, weight: .bold)
        sectionLabel.textColor = UIColor(named: "buttons/selected") ?? .systemRed
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(sectionLabel)

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .Text.main
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        episodeLabel.font = .systemFont(ofSize: 12, weight: .regular)
        episodeLabel.textColor = .Text.secondary
        episodeLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(episodeLabel)

        playImageView.image = UIImage(systemName: "play.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .regular))
        playImageView.tintColor = UIColor(named: "buttons/selected") ?? .systemRed
        playImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(playImageView)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            posterImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            posterImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 44),
            posterImageView.heightAnchor.constraint(equalToConstant: 58),

            sectionLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 1),
            sectionLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            sectionLabel.trailingAnchor.constraint(equalTo: playImageView.leadingAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 3),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: playImageView.leadingAnchor, constant: -8),

            episodeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            episodeLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            episodeLabel.trailingAnchor.constraint(equalTo: playImageView.leadingAnchor, constant: -8),

            playImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            playImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            playImageView.widthAnchor.constraint(equalToConstant: 32),
            playImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    func configure(with series: Series, episodeID: String?, timeCode: TimeCodeData?) {
        posterImageView.setImage(from: series.poster, placeholder: DefaultPlaceholder())
        titleLabel.text = series.name?.main ?? series.alias

        let playlistItem = series.playlist.first(where: { $0.id == episodeID })
        let result = HistoryTimecodeHelper.formatEpisodeAndDuration(
            playlistItem: playlistItem,
            timeCode: timeCode,
            totalDuration: playlistItem?.duration
        )

        episodeLabel.text = result.text

        if result.progress > 0 {
            progressTrackView.isHidden = false
            progressWidthConstraint?.isActive = false
            let safeProgress = CGFloat(min(max(result.progress, 0.0), 1.0))
            let newWidth = progressFillView.widthAnchor.constraint(equalTo: progressTrackView.widthAnchor, multiplier: safeProgress)
            newWidth.isActive = true
            progressWidthConstraint = newWidth
        } else {
            progressTrackView.isHidden = true
        }
    }
}

final class FeedV2ContinueHistoryCell: UICollectionViewCell {
    static let reuseIdentifier = "FeedV2ContinueHistoryCell"

    private let container = UIView()
    private let iconCircle = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevronImageView = UIImageView()

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
        updateCardAppearance()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateCardAppearance()
    }

    private func updateCardAppearance() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        container.layer.borderColor = isDark
            ? UIColor.white.withAlphaComponent(0.10).cgColor
            : UIColor.black.withAlphaComponent(0.08).cgColor
    }

    private func setupViews() {
        contentView.backgroundColor = .clear

        container.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? .Surfaces.content
                : UIColor(white: 0.96, alpha: 0.95)
        }
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        container.layer.borderWidth = 1
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)

        iconCircle.backgroundColor = (UIColor(named: "buttons/selected") ?? .systemRed).withAlphaComponent(0.12)
        iconCircle.layer.cornerRadius = 19
        iconCircle.layer.cornerCurve = .continuous
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconCircle)

        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconImageView.image = UIImage(systemName: "clock.arrow.circlepath", withConfiguration: config)
        iconImageView.tintColor = UIColor(named: "buttons/selected") ?? .systemRed
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.addSubview(iconImageView)

        titleLabel.text = Language.isEnglish ? "Watch History" : "История просмотров"
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .Text.main
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        subtitleLabel.text = Language.isEnglish ? "Browse all watched anime" : "Смотреть все начатые релизы"
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .Text.secondary
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subtitleLabel)

        let chevConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        chevronImageView.image = UIImage(systemName: "chevron.right", withConfiguration: chevConfig)
        chevronImageView.tintColor = .Text.secondary
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            iconCircle.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            iconCircle.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconCircle.widthAnchor.constraint(equalToConstant: 38),
            iconCircle.heightAnchor.constraint(equalToConstant: 38),

            iconImageView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconCircle.topAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: iconCircle.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),

            subtitleLabel.bottomAnchor.constraint(equalTo: iconCircle.bottomAnchor, constant: -1),
            subtitleLabel.leadingAnchor.constraint(equalTo: iconCircle.trailingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),

            chevronImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            chevronImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
}

// MARK: - Empty History Promo Cell

final class FeedV2EmptyHistoryCell: UICollectionViewCell {
    static let reuseIdentifier = "FeedV2EmptyHistoryCell"

    private let container = UIView()
    private let iconCircle = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevronImageView = UIImageView()

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
        updateCardAppearance()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateCardAppearance()
    }

    private func updateCardAppearance() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        container.layer.borderColor = isDark
            ? UIColor.white.withAlphaComponent(0.10).cgColor
            : UIColor.black.withAlphaComponent(0.08).cgColor
    }

    private func setupViews() {
        contentView.backgroundColor = .clear

        container.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? .Surfaces.content
                : UIColor(white: 0.96, alpha: 0.95)
        }
        container.layer.cornerRadius = 14
        container.layer.cornerCurve = .continuous
        container.layer.borderWidth = 1
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        updateCardAppearance()

        iconCircle.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.systemIndigo.withAlphaComponent(0.20)
                : UIColor.systemIndigo.withAlphaComponent(0.12)
        }
        iconCircle.layer.cornerRadius = 12
        iconCircle.layer.cornerCurve = .continuous
        iconCircle.clipsToBounds = true
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconCircle)

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconImageView.image = UIImage(systemName: "sparkles.tv", withConfiguration: iconConfig)
        iconImageView.tintColor = .systemIndigo
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.addSubview(iconImageView)

        titleLabel.text = Language.isEnglish ? "History is empty? Time to start!" : "История пуста? Время начать!"
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .Text.main
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        subtitleLabel.text = Language.isEnglish ? "Thousands of anime are waiting in the catalog →" : "Тысячи аниме уже ждут тебя в каталоге →"
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .Text.secondary
        subtitleLabel.numberOfLines = 1
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subtitleLabel)

        let chevConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chevronImageView.image = UIImage(systemName: "chevron.right", withConfiguration: chevConfig)
        chevronImageView.tintColor = .systemIndigo
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            iconCircle.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            iconCircle.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconCircle.widthAnchor.constraint(equalToConstant: 42),
            iconCircle.heightAnchor.constraint(equalToConstant: 42),

            iconImageView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconCircle.topAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: iconCircle.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),

            subtitleLabel.bottomAnchor.constraint(equalTo: iconCircle.bottomAnchor, constant: -2),
            subtitleLabel.leadingAnchor.constraint(equalTo: iconCircle.trailingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),

            chevronImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            chevronImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
}

// MARK: - Schedule Card Cell

final class FeedV2ScheduleCell: UICollectionViewCell {
    static let reuseIdentifier = "FeedV2ScheduleCell"

    private let posterImageView = UIImageView()
    private let timeBadge = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let timeLabel = UILabel()
    private let titleLabel = UILabel()
    private let episodeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.backgroundColor = .clear

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 14
        posterImageView.layer.cornerCurve = .continuous
        posterImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        posterImageView.layer.borderWidth = 1
        posterImageView.backgroundColor = .Surfaces.content
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterImageView)

        timeBadge.clipsToBounds = true
        timeBadge.layer.cornerRadius = 8
        timeBadge.layer.cornerCurve = .continuous
        timeBadge.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        timeBadge.layer.borderWidth = 0.5
        timeBadge.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.addSubview(timeBadge)

        timeLabel.font = .systemFont(ofSize: 10, weight: .bold)
        timeLabel.textColor = .white
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeBadge.contentView.addSubview(timeLabel)

        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .Text.main
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        episodeLabel.font = .systemFont(ofSize: 11, weight: .regular)
        episodeLabel.textColor = .Text.secondary
        episodeLabel.numberOfLines = 1
        episodeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(episodeLabel)

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 154),

            timeBadge.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 8),
            timeBadge.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: -8),
            timeBadge.heightAnchor.constraint(equalToConstant: 18),

            timeLabel.topAnchor.constraint(equalTo: timeBadge.contentView.topAnchor, constant: 1),
            timeLabel.bottomAnchor.constraint(equalTo: timeBadge.contentView.bottomAnchor, constant: -1),
            timeLabel.leadingAnchor.constraint(equalTo: timeBadge.contentView.leadingAnchor, constant: 6),
            timeLabel.trailingAnchor.constraint(equalTo: timeBadge.contentView.trailingAnchor, constant: -6),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            episodeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            episodeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            episodeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func configure(with item: ScheduleItem) {
        posterImageView.setImage(from: item.item.poster, placeholder: DefaultPlaceholder())
        titleLabel.text = item.item.name?.main ?? item.item.alias

        if let episode = item.newEpisode, let ord = episode.ordinal {
            episodeLabel.text = Language.isEnglish ? "Ep. \(Int(ord)) out" : "\(Int(ord)) серия вышла"
            timeLabel.text = Language.isEnglish ? "OUT" : "ВЫШЛА"
            timeBadge.contentView.backgroundColor = (UIColor(named: "buttons/selected") ?? .systemRed).withAlphaComponent(0.9)
        } else if let ordinal = item.newEpisodeOrdinal {
            episodeLabel.text = Language.isEnglish ? "Episode \(Int(ordinal))" : "\(Int(ordinal)) серия"
            timeLabel.text = Language.isEnglish ? "SOON" : "СКОРО"
            timeBadge.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        } else {
            let defaultOngoing = Language.isEnglish ? "Ongoing" : "Онгоинг"
            episodeLabel.text = item.item.season?.description ?? defaultOngoing
            timeLabel.text = Language.isEnglish ? "TODAY" : "СЕГОДНЯ"
            timeBadge.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        }
    }
}
