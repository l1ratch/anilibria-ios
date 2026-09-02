//
//  FeedV2Views.swift
//  Anilibria
//
//  Created by Antigravity on 02.09.2026.
//

import UIKit

// MARK: - Hero Showcase Cell

final class FeedV2HeroCell: UICollectionViewCell {
    static let reuseIdentifier = "FeedV2HeroCell"

    private let imageView = UIImageView()
    private let gradientView = UIView()
    private let gradientLayer = CAGradientLayer()
    private let badgeLabel = UILabel()
    private let badgeContainer = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton(type: .system)

    private var subtitleTrailingToButton: NSLayoutConstraint!
    private var subtitleTrailingToContent: NSLayoutConstraint!

    var onActionTap: (() -> Void)?

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
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 18
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        contentView.layer.borderWidth = 1
        contentView.backgroundColor = .Surfaces.content

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false
        contentView.addSubview(gradientView)

        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor,
            UIColor.black.withAlphaComponent(0.94).cgColor
        ]
        gradientLayer.locations = [0.0, 0.35, 1.0]
        gradientView.layer.addSublayer(gradientLayer)

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

            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            actionButton.heightAnchor.constraint(equalToConstant: 32),
            actionButton.widthAnchor.constraint(equalToConstant: 110),

            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            subtitleTrailingToButton,

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -4)
        ])
    }

    @objc private func didTapAction() {
        onActionTap?()
    }

    func configure(with item: PromoItem) {
        imageView.setImage(from: item.image, placeholder: DefaultPlaceholder())

        switch item.content {
        case .release(let series):
            badgeLabel.text = "🔥 В ТРЕНДЕ"
            titleLabel.text = series.name?.main ?? series.alias
            titleLabel.numberOfLines = 2
            let genres = series.genres.prefix(2).map { $0.name }.joined(separator: " • ")
            subtitleLabel.text = genres.isEmpty ? (series.season?.description ?? "Аниме") : genres
            subtitleLabel.numberOfLines = 1
            actionButton.isHidden = false
            actionButton.setTitle("  Смотреть", for: .normal)
            actionButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            subtitleTrailingToContent.isActive = false
            subtitleTrailingToButton.isActive = true

        case .ad(let ad):
            badgeLabel.text = "РЕКЛАМА"
            titleLabel.text = ad.title
            titleLabel.numberOfLines = 2
            subtitleLabel.text = ad.info
            subtitleLabel.numberOfLines = 2
            actionButton.isHidden = false
            actionButton.setTitle("  Перейти", for: .normal)
            actionButton.setImage(UIImage(systemName: "arrow.up.right"), for: .normal)
            subtitleTrailingToContent.isActive = false
            subtitleTrailingToButton.isActive = true

        case .promo(let promo):
            badgeLabel.text = "📢 АНОНС"
            let title = promo.title?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let title = title, !title.isEmpty {
                titleLabel.text = title
            } else {
                titleLabel.text = "Анонс"
            }
            titleLabel.numberOfLines = 2
            subtitleLabel.text = item.info
            subtitleLabel.numberOfLines = 4

            if promo.url != nil {
                actionButton.isHidden = false
                actionButton.setTitle("  Подробнее", for: .normal)
                actionButton.setImage(UIImage(systemName: "arrow.up.right"), for: .normal)
                actionButton.backgroundColor = UIColor(named: "buttons/selected") ?? .systemRed
                subtitleTrailingToContent.isActive = false
                subtitleTrailingToButton.isActive = true
            } else {
                actionButton.isHidden = false
                actionButton.setTitle("  Читать", for: .normal)
                actionButton.setImage(UIImage(systemName: "doc.text.fill"), for: .normal)
                actionButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                subtitleTrailingToContent.isActive = false
                subtitleTrailingToButton.isActive = true
            }

        case nil:
            badgeLabel.text = "📢 НОВОСТЬ"
            titleLabel.text = "Информация"
            titleLabel.numberOfLines = 1
            subtitleLabel.text = item.info
            subtitleLabel.numberOfLines = 4
            actionButton.isHidden = false
            actionButton.setTitle("  Читать", for: .normal)
            actionButton.setImage(UIImage(systemName: "doc.text.fill"), for: .normal)
            actionButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            subtitleTrailingToContent.isActive = false
            subtitleTrailingToButton.isActive = true
        }
    }
}

// MARK: - Quick Actions View

final class FeedV2QuickActionsView: UIView {
    var onRandomTap: (() -> Void)?
    var onScheduleTap: (() -> Void)?
    var onCatalogTap: (() -> Void)?

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
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
            title: "Рандом",
            icon: "dice.fill",
            tint: UIColor(named: "buttons/selected") ?? .systemRed,
            action: #selector(didTapRandom)
        )
        let scheduleBtn = makeButton(
            title: "Неделя",
            icon: "calendar",
            tint: .systemTeal,
            action: #selector(didTapSchedule)
        )
        let catalogBtn = makeButton(
            title: "Каталог",
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
        button.backgroundColor = .Surfaces.content
        button.layer.cornerRadius = 14
        button.layer.cornerCurve = .continuous
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        button.layer.borderWidth = 1
        button.clipsToBounds = true

        let iconImg = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
        button.setImage(iconImg, for: .normal)
        button.setTitle("  " + title, for: .normal)
        button.tintColor = tint
        button.setTitleColor(.Text.main, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.addTarget(self, action: action, for: .touchUpInside)

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

// MARK: - Continue Watching View

final class FeedV2ContinueWatchingView: UIView {
    var onTap: (() -> Void)?

    private let container = UIView()
    private let posterImageView = UIImageView()
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

    private func setupViews() {
        container.backgroundColor = .Surfaces.content
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        container.layer.borderWidth = 1
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 10
        posterImageView.layer.cornerCurve = .continuous
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(posterImageView)

        sectionLabel.text = "ПРОДОЛЖИТЬ ПРОСМОТР"
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
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 76),

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

    @objc private func didTapCard() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onTap?()
    }

    func configure(with series: Series, episodeID: String?) {
        posterImageView.setImage(from: series.poster, placeholder: DefaultPlaceholder())
        titleLabel.text = series.name?.main ?? series.alias

        if let ep = episodeID, !ep.isEmpty {
            episodeLabel.text = "Серия \(ep)"
        } else {
            episodeLabel.text = "Нажмите для воспроизведения"
        }
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
            episodeLabel.text = "\(Int(ord)) серия вышла"
            timeLabel.text = "ВЫШЛА"
            timeBadge.contentView.backgroundColor = (UIColor(named: "buttons/selected") ?? .systemRed).withAlphaComponent(0.9)
        } else if let ordinal = item.newEpisodeOrdinal {
            episodeLabel.text = "\(Int(ordinal)) серия"
            timeLabel.text = "СКОРО"
            timeBadge.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        } else {
            episodeLabel.text = item.item.season?.description ?? "Онгоинг"
            timeLabel.text = "СЕГОДНЯ"
            timeBadge.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        }
    }
}
