//
//  RelatedSeriesCarouselView.swift
//  AniLiberty
//
//  Created on 03.09.2026.
//

import UIKit

final class RelatedSeriesCarouselView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var items: [Series] = []
    private var currentSeriesId: Int?
    private var onSelect: ((Series) -> Void)?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 240, height: 74)
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(RelatedSeriesCardCell.self, forCellWithReuseIdentifier: RelatedSeriesCardCell.reuseIdentifier)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 78)
        ])
    }

    func configure(series: [Series], current: Series, onSelect: @escaping (Series) -> Void) {
        self.items = series
        self.currentSeriesId = current.id
        self.onSelect = onSelect
        collectionView.reloadData()

        if let currentIndex = series.firstIndex(where: { $0.id == current.id }) {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.scrollToItem(
                    at: IndexPath(item: currentIndex, section: 0),
                    at: .centeredHorizontally,
                    animated: false
                )
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RelatedSeriesCardCell.reuseIdentifier,
            for: indexPath
        ) as? RelatedSeriesCardCell else {
            return UICollectionViewCell()
        }
        let item = items[indexPath.item]
        let isCurrent = (item.id == currentSeriesId)
        cell.configure(index: indexPath.item, series: item, isCurrent: isCurrent)
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        guard item.id != currentSeriesId else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onSelect?(item)
    }
}

// MARK: - Related Series Card Cell

final class RelatedSeriesCardCell: UICollectionViewCell {
    static let reuseIdentifier = "RelatedSeriesCardCell"

    private let containerView = UIView()
    private let posterImageView = UIImageView()
    private let partBadge = UILabel()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private let currentBadge = UILabel()

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

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .Surfaces.content
        containerView.layer.cornerRadius = 14
        containerView.layer.cornerCurve = .continuous
        containerView.clipsToBounds = true
        containerView.applyAdaptiveBorder()
        contentView.addSubview(containerView)

        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 10
        posterImageView.layer.cornerCurve = .continuous
        posterImageView.backgroundColor = .Surfaces.base
        containerView.addSubview(posterImageView)

        let infoStack = UIStackView()
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .vertical
        infoStack.spacing = 2
        infoStack.alignment = .leading
        containerView.addSubview(infoStack)

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.spacing = 6
        topRow.alignment = .center

        partBadge.font = .systemFont(ofSize: 10, weight: .bold)
        partBadge.textColor = .Text.secondary
        partBadge.translatesAutoresizingMaskIntoConstraints = false
        topRow.addArrangedSubview(partBadge)

        currentBadge.font = .systemFont(ofSize: 9, weight: .bold)
        currentBadge.textColor = .white
        currentBadge.backgroundColor = UIColor(named: "buttons/selected") ?? .systemRed
        currentBadge.layer.cornerRadius = 4
        currentBadge.layer.masksToBounds = true
        currentBadge.text = " ВЫ СМОТРИТЕ "
        currentBadge.isHidden = true
        topRow.addArrangedSubview(currentBadge)

        infoStack.addArrangedSubview(topRow)

        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .Text.main
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        infoStack.addArrangedSubview(titleLabel)

        infoLabel.font = .systemFont(ofSize: 11, weight: .regular)
        infoLabel.textColor = .Text.secondary
        infoStack.addArrangedSubview(infoLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            posterImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
            posterImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 44),
            posterImageView.heightAnchor.constraint(equalToConstant: 62),

            infoStack.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 8),
            infoStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            infoStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    func configure(index: Int, series: Series, isCurrent: Bool) {
        posterImageView.setImage(from: series.poster, placeholder: DefaultPlaceholder())
        let partPrefix = Language.isEnglish ? "Part" : "Часть"
        partBadge.text = "\(partPrefix) \(index + 1)"
        titleLabel.text = series.name?.main ?? series.alias

        var infoParts: [String] = []
        if let year = series.year {
            infoParts.append("\(year)")
        }
        if let type = series.type?.description {
            infoParts.append(type)
        }
        infoLabel.text = infoParts.joined(separator: " • ")

        if isCurrent {
            containerView.layer.borderColor = (UIColor(named: "buttons/selected") ?? .systemRed).cgColor
            containerView.layer.borderWidth = 1.5
            currentBadge.isHidden = false
            partBadge.textColor = UIColor(named: "buttons/selected") ?? .systemRed
        } else {
            containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
            containerView.layer.borderWidth = 1
            currentBadge.isHidden = true
            partBadge.textColor = .Text.secondary
        }
    }
}
