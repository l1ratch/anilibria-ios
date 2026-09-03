//
//  EpisodesView.swift
//  AniLiberty
//
//  Created by Ivan Morozov on 30.04.2026.
//  Copyright © 2026 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class EpisodesView: UIView {
    private static let actionsViewHeight: CGFloat = 44

    private let headerContainer = UIView()
    private let titleLabel = UILabel()
    private let countBadge = UILabel()

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

    public lazy var adapter = CollectionViewAdapter(collectionView: collectionView)

    private lazy var reverseButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.up.arrow.down", withConfiguration: config), for: .normal)
        btn.tintColor = .Text.main
        btn.backgroundColor = .Surfaces.content
        btn.layer.cornerRadius = 16
        btn.layer.cornerCurve = .continuous
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var optionsButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: config), for: .normal)
        btn.tintColor = .Text.main
        btn.backgroundColor = .Surfaces.content
        btn.layer.cornerRadius = 16
        btn.layer.cornerCurve = .continuous
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let stubView: StubView? = StubView.fromNib()?.apply {
        $0.set(image: .System.play, color: .Text.secondary)
        $0.title = L10n.Stub.title
        $0.message = L10n.Stub.noEpisodes
    }

    private let sectionAdapter = EpisodesSectionAdapter([])

    private var subscribers = Set<AnyCancellable>()
    private var itemsSubscribers = Set<AnyCancellable>()
    private var viewModel: EpisodesViewModel?

    private lazy var episodesHandler = EpisodeCellAdapterHandler(
        select: { [weak self] item in
            self?.viewModel?.play(item: item)
        }
    )

    var isCompact: Bool = true {
        didSet {
            sectionAdapter.isCompact = isCompact
            stubView?.isHorizontal = isCompact

            if isCompact {
                collectionView.contentInset.top = 0
                let conf = UICollectionViewCompositionalLayoutConfiguration()
                conf.scrollDirection = .horizontal
                self.adapter.setLayout(
                    type: UICollectionViewCompositionalLayout.self,
                    configuration: conf
                )
                stubView?.messageLinesLimit = 3
            } else {
                collectionView.contentInset.top = 8
                self.adapter.setLayout(
                    type: UICollectionViewCompositionalLayout.self
                )
                stubView?.messageLinesLimit = 0
            }
            invalidateLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        setupHeader()

        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        isCompact = true

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }

    private func setupHeader() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerContainer)

        titleLabel.text = Language.isEnglish ? "Episodes" : "Серии"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .Text.main
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        countBadge.font = .systemFont(ofSize: 12, weight: .medium)
        countBadge.textColor = .Text.secondary
        countBadge.translatesAutoresizingMaskIntoConstraints = false

        let leftStack = UIStackView(arrangedSubviews: [titleLabel, countBadge])
        leftStack.axis = .horizontal
        leftStack.spacing = 8
        leftStack.alignment = .firstBaseline
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(leftStack)

        let rightStack = UIStackView(arrangedSubviews: [reverseButton, optionsButton])
        rightStack.axis = .horizontal
        rightStack.spacing = 8
        rightStack.alignment = .center
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(rightStack)

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 34),

            leftStack.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            leftStack.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),

            rightStack.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            rightStack.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),

            reverseButton.widthAnchor.constraint(equalToConstant: 32),
            reverseButton.heightAnchor.constraint(equalToConstant: 32),

            optionsButton.widthAnchor.constraint(equalToConstant: 32),
            optionsButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        reverseButton.addTarget(self, action: #selector(didTapReverse), for: .touchUpInside)
        optionsButton.addTarget(self, action: #selector(didTapOptions), for: .touchUpInside)
    }

    @objc private func didTapReverse() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        viewModel?.toggleDirection()
    }

    @objc private func didTapOptions() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        viewModel?.showOptions()
    }

    func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func configure(viewModel: EpisodesViewModel) {
        self.viewModel = viewModel
        itemsSubscribers.removeAll()
        viewModel.items.removeDuplicates().sink { [weak self] items in
            self?.set(items: items)
            self?.updateCountBadge(items: items)
        }.store(in: &itemsSubscribers)

        viewModel.$isEmpty.removeDuplicates().sink { [weak self] empty in
            guard let self else { return }
            reverseButton.isHidden = empty
            optionsButton.isHidden = empty
        }.store(in: &itemsSubscribers)
    }

    private func updateCountBadge(items: [EpisodeViewModel]?) {
        guard let items, !items.isEmpty else {
            countBadge.text = ""
            return
        }
        let total = items.count
        let watched = items.filter { $0.timecode.isWatched }.count
        if watched > 0 {
            countBadge.text = "\(watched)/\(total)"
        } else {
            let epWord = Language.isEnglish ? "episodes" : "эпизодов"
            countBadge.text = "\(total) \(epWord)"
        }
    }
}

extension EpisodesView {
    func set(items: [EpisodeViewModel]?) {
        guard let items else {
            return
        }
        if items.isEmpty {
            self.collectionView.backgroundView = self.stubView
        } else {
            self.collectionView.backgroundView = nil
        }

        sectionAdapter.set(items.map {
            EpisodeCellAdapter(viewModel: $0, handler: episodesHandler)
        })
        adapter.set(sections: [sectionAdapter])
    }
}
