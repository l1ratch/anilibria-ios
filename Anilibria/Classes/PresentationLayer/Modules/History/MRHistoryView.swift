import UIKit

// MARK: - View Controller

final class HistoryViewController: BaseCollectionViewController {
    var handler: HistoryEventHandler!

    private let searchView: SearchView? = SearchView(
        frame: CGRect(origin: .zero, size: .init(width: 320, height: 40))
    )
    private let stubView: StubView? = StubView.fromNib()?.apply {
        $0.set(image: .System.history, color: .Text.secondary)
        $0.title = L10n.Stub.title
    }

    private let sectionAdapter: SectionAdapter = {
        let section = SectionAdapter([])
        section.estimatedHeight = 88
        section.insets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 20, trailing: 16)
        section.minimumLineSpacing = 10
        section.ipad = .init(expectedWidth: 340)
        return section
    }()

    private lazy var historyHandler = HistorySeriesCellAdapterHandler(
        select: { [weak self] item in
            self?.searchView?.resignFirstResponder()
            self?.handler.select(item: item)
        },
        continueWatching: { [weak self] item in
            self?.searchView?.resignFirstResponder()
            self?.handler.continueWatching(item: item)
        },
        delete: { [weak self] item in
            self?.handler.delete(item: item)
        }
    )

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .Surfaces.base
        self.collectionView.backgroundColor = .Surfaces.base
        self.setupNavbar()
        self.addKeyboardObservers()
        self.handler.didLoad()
        self.collectionView.contentInset.top = 10
    }

    private func setupNavbar() {
        if let value = self.searchView {
            self.navigationItem.titleView = value
            value.querySequence()
                .sink(onNext: { [weak self] text in
                    self?.handler.search(query: text)
                })
                .store(in: &subscribers)
        }
    }

    override func keyBoardWillShow(keyboardHeight: CGFloat) {
        super.keyBoardWillShow(keyboardHeight: keyboardHeight)
        self.collectionView.contentInset.bottom = keyboardHeight
    }

    override func keyBoardWillHide() {
        super.keyBoardWillHide()
        self.collectionView.contentInset.bottom = self.defaultBottomInset
    }

    func updateEmptyView() {
        guard let searchView else { return }
        var text = L10n.Stub.History.message
        if searchView.isSearching {
            text = L10n.Stub.messageNotFound(searchView.text)
        }
        stubView?.message = text
    }
}

extension HistoryViewController: HistoryViewBehavior {
    func set(items: [HistoryItemModel]) {
        if items.isEmpty {
            self.updateEmptyView()
            self.collectionView.backgroundView = self.stubView
        } else {
            self.collectionView.backgroundView = nil
        }

        sectionAdapter.set(items.map {
            HistorySeriesCellAdapter(viewModel: $0, handler: historyHandler)
        })
        self.set(sections: [sectionAdapter])
    }
}

// MARK: - History Series Cell Adapter

struct HistorySeriesCellAdapterHandler {
    let select: ((HistoryItemModel) -> Void)?
    let continueWatching: ((HistoryItemModel) -> Void)?
    let delete: ((HistoryItemModel) -> Void)?
}

final class HistorySeriesCellAdapter: BaseCellAdapter<HistoryItemModel> {
    private let handler: HistorySeriesCellAdapterHandler

    init(viewModel: HistoryItemModel, handler: HistorySeriesCellAdapterHandler) {
        self.handler = handler
        super.init(viewModel: viewModel)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableCell(type: HistorySeriesCell.self, for: index)
        cell.configure(with: viewModel)
        let item = self.viewModel
        let handler = self.handler
        cell.onPlay = { [handler, item] in
            handler.continueWatching?(item)
        }
        cell.onDelete = { [handler, item] in
            handler.delete?(item)
        }
        return cell
    }

    override func didSelect(at index: IndexPath) {
        self.handler.select?(viewModel)
    }
}

// MARK: - History Series Cell

final class HistorySeriesCell: UICollectionViewCell, DraggableViewDelegate {
    static let reuseIdentifier = "HistorySeriesCell"

    var onPlay: (() -> Void)?
    var onDelete: (() -> Void)?

    private let draggableView = DraggableView()
    private let deleteBackgroundView = UIView()
    private let deleteButton = UIButton(type: .system)

    private let cardContainer = UIView()
    private let posterImageView = UIImageView()
    private let progressTrackView = UIView()
    private let progressFillView = UIView()
    private var progressWidthConstraint: NSLayoutConstraint?

    private let textStackView = UIStackView()
    private let titleLabel = UILabel()
    private let statusStackView = UIStackView()
    private let statusIconView = UIImageView()
    private let subtitleLabel = UILabel()

    private let playButton = UIButton(type: .system)

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
        draggableView.close(false)
        posterImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        progressTrackView.isHidden = true
        onPlay = nil
        onDelete = nil
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateCardAppearance()
    }

    private func updateCardAppearance() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        cardContainer.layer.borderColor = isDark
            ? UIColor.white.withAlphaComponent(0.10).cgColor
            : UIColor.black.withAlphaComponent(0.08).cgColor
    }

    private func setupViews() {
        contentView.backgroundColor = .clear

        // 1. Draggable View for swipe-to-delete
        draggableView.translatesAutoresizingMaskIntoConstraints = false
        draggableView.swipeOffset = 80
        draggableView.delegate = self
        contentView.addSubview(draggableView)

        NSLayoutConstraint.activate([
            draggableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            draggableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            draggableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            draggableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // 2. Delete background with circular red trash button
        deleteBackgroundView.backgroundColor = .clear
        deleteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        draggableView.insertSubview(deleteBackgroundView, at: 0)

        NSLayoutConstraint.activate([
            deleteBackgroundView.topAnchor.constraint(equalTo: draggableView.topAnchor),
            deleteBackgroundView.leadingAnchor.constraint(equalTo: draggableView.leadingAnchor),
            deleteBackgroundView.trailingAnchor.constraint(equalTo: draggableView.trailingAnchor),
            deleteBackgroundView.bottomAnchor.constraint(equalTo: draggableView.bottomAnchor)
        ])

        let trashIcon = UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))
        deleteButton.setImage(trashIcon, for: .normal)
        deleteButton.tintColor = .white
        deleteButton.backgroundColor = UIColor.systemRed
        deleteButton.layer.cornerRadius = 20
        deleteButton.clipsToBounds = true
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteBackgroundView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 40),
            deleteButton.heightAnchor.constraint(equalToConstant: 40),
            deleteButton.trailingAnchor.constraint(equalTo: deleteBackgroundView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: deleteBackgroundView.centerYAnchor)
        ])

        // 3. Foreground Card Container (inside draggableView.contentView)
        guard let dragContent = draggableView.contentView else { return }
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.backgroundColor = .Surfaces.content
        cardContainer.layer.cornerRadius = 14
        cardContainer.layer.cornerCurve = .continuous
        cardContainer.layer.borderWidth = 1
        cardContainer.clipsToBounds = true
        dragContent.addSubview(cardContainer)
        updateCardAppearance()

        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: dragContent.topAnchor),
            cardContainer.leadingAnchor.constraint(equalTo: dragContent.leadingAnchor),
            cardContainer.trailingAnchor.constraint(equalTo: dragContent.trailingAnchor),
            cardContainer.bottomAnchor.constraint(equalTo: dragContent.bottomAnchor)
        ])

        // 4. Poster Image View (left)
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 9
        posterImageView.layer.cornerCurve = .continuous
        cardContainer.addSubview(posterImageView)

        // Progress bar at the bottom of poster
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
            posterImageView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 10),
            posterImageView.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 52),
            posterImageView.heightAnchor.constraint(equalToConstant: 70),

            progressTrackView.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            progressTrackView.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor),
            progressTrackView.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor),
            progressTrackView.heightAnchor.constraint(equalToConstant: 3),

            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor),
            initialWidth
        ])

        // 5. Quick Play Button (right)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        let playIcon = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))
        playButton.setImage(playIcon, for: .normal)
        playButton.tintColor = .white
        playButton.backgroundColor = UIColor(named: "buttons/selected") ?? .systemRed
        playButton.layer.cornerRadius = 19
        playButton.clipsToBounds = true
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        cardContainer.addSubview(playButton)

        NSLayoutConstraint.activate([
            playButton.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -12),
            playButton.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 38),
            playButton.heightAnchor.constraint(equalToConstant: 38)
        ])

        // 6. Text Stack (middle)
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.alignment = .leading
        textStackView.spacing = 5
        cardContainer.addSubview(textStackView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .Text.main
        titleLabel.numberOfLines = 2
        textStackView.addArrangedSubview(titleLabel)

        statusStackView.translatesAutoresizingMaskIntoConstraints = false
        statusStackView.axis = .horizontal
        statusStackView.alignment = .center
        statusStackView.spacing = 5
        textStackView.addArrangedSubview(statusStackView)

        statusIconView.translatesAutoresizingMaskIntoConstraints = false
        statusIconView.image = UIImage(systemName: "clock.arrow.circlepath", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .medium))
        statusIconView.tintColor = .Text.secondary
        statusIconView.contentMode = .scaleAspectFit
        statusStackView.addArrangedSubview(statusIconView)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .Text.secondary
        subtitleLabel.numberOfLines = 1
        statusStackView.addArrangedSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            statusIconView.widthAnchor.constraint(equalToConstant: 13),
            statusIconView.heightAnchor.constraint(equalToConstant: 13),

            textStackView.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            textStackView.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -10),
            textStackView.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor)
        ])
    }

    func configure(with item: HistoryItemModel) {
        posterImageView.setImage(from: item.series.poster, placeholder: DefaultPlaceholder())
        titleLabel.text = item.series.name?.main ?? item.series.alias

        let result = HistoryTimecodeHelper.formatEpisodeAndDuration(
            playlistItem: item.playlistItem,
            timeCode: item.timeCode,
            totalDuration: item.playlistItem?.duration
        )

        subtitleLabel.text = result.text

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

    @objc private func playButtonTapped() {
        onPlay?()
    }

    @objc private func deleteButtonTapped() {
        draggableView.close(false)
        onDelete?()
    }

    // DraggableViewDelegate
    func callPrimaryAction() {
        draggableView.close(false)
        onDelete?()
    }
}
