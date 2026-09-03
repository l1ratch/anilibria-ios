import UIKit
import Combine

// MARK: - View Controller

final class SeriesViewController: BaseViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var secondTitleLabel: UILabel!
    @IBOutlet var favoriteView: SeriesFavoriteView!
    @IBOutlet var typeView: SeriesCollectionTypeView!
    @IBOutlet var donateButton: UIButton!
    @IBOutlet var tagsView: TagsView!

    @IBOutlet var infoTextView: AttributeLinksView!
    @IBOutlet var anonceLabel: UILabel!
    @IBOutlet var supportLabel: UILabel!
    @IBOutlet var supportLabelContainer: BorderedView!
    @IBOutlet var supportButton: UIButton!
    @IBOutlet var torrentsStackView: UIStackView!
    @IBOutlet var relatedView: UIView!
    @IBOutlet var relatedStackView: UIStackView!
    @IBOutlet var relatedTitleLabel: UILabel!
    @IBOutlet var relatedShimmerView: ShimmerView!
    @IBOutlet var contentShimmerViews: [ShimmerView] = []

    @IBOutlet var playButtonLabel: UILabel!
    @IBOutlet var playButtonContainer: ShadowView!

    @IBOutlet var weekDayView: WeekDayView!
    @IBOutlet var seriesImageView: UIImageView!

    @IBOutlet var episodesContainer: UIView!
    @IBOutlet var compactEpisodesContainer: UIView!

    private let episodesView = EpisodesView()
    private var bag = Set<AnyCancellable>()

    private var episodesContainreHidden: Bool = true {
        didSet {
            if episodesContainreHidden != oldValue {
                episodesContainer.isHidden = episodesContainreHidden
                compactEpisodesContainer.isHidden = !episodesContainreHidden
                updateEpisodesUI()
            }
        }
    }

    var handler: SeriesEventHandler!

    private var keyboardInset: CGFloat = 0 {
        didSet { updateInsets() }
    }

    // MARK: - Modern UI Components

    private let modernHeaderView = UIView()
    private let posterWrapper = UIView()
    private let metaStackView = UIStackView()
    private let badgesScrollView = UIScrollView()
    private let badgesStackView = UIStackView()
    private let typeBadge = BadgeLabel()
    private let yearBadge = BadgeLabel()
    private let seasonBadge = BadgeLabel()
    private let episodesBadge = BadgeLabel()
    private let modernAnonceContainer = UIView()
    private let modernAnonceLabel = UILabel()

    private let modernWatchButton = UIButton(type: .system)
    private let modernWatchLabel = UILabel()
    private let modernWatchIcon = UIImageView()

    private let actionsContainerView = UIView()

    private let genresScrollView = UIScrollView()
    private let genresStackView = UIStackView()

    private let synopsisContainer = UIView()
    private let synopsisTitleLabel = UILabel()
    private let synopsisLabel = UILabel()
    private let expandSynopsisButton = UIButton(type: .system)
    private var isSynopsisExpanded = false

    private let creditsCard = UIView()
    private let creditsTitleLabel = UILabel()
    private let creditsStackView = UIStackView()

    private let relatedCarouselView = RelatedSeriesCarouselView()

    // MARK: - Life cycle

    override func viewDidLoad() {
        self.hidesBottomBarWhenPushed = true
        super.viewDidLoad()
        self.setupNavigationButtons()
        addRefreshControl(scrollView: scrollView)
        updateEpisodesUI()
        setupModernLayout()

        supportLabelContainer.cornerRadius = 14

        relatedShimmerView.smoothCorners(with: 14)
        relatedShimmerView.backgroundColor = .Tint.shimmer
        relatedShimmerView.shimmerColor = .Surfaces.base
        relatedShimmerView.run()

        contentShimmerViews.forEach {
            $0.stop()
            $0.isHidden = true
        }

        NotificationCenter.default
            .publisher(for: UIApplication.keyboardWillChangeFrameNotification)
            .sink { [weak self] notification in
                self?.updateKeyboard(notification)
            }
            .store(in: &bag)
    }

    private func setupModernLayout() {
        guard let mainStack = compactEpisodesContainer.superview as? UIStackView else { return }
        guard let headerContainer = infoTextView.superview else { return }
        guard let actionsContainer = favoriteView.superview?.superview else { return }

        // 1. Hide floating play button container
        playButtonContainer.superview?.isHidden = true
        playButtonContainer.isHidden = true

        // 2. Hide old title stack and old anonce
        titleLabel.superview?.isHidden = true
        anonceLabel.isHidden = true

        // 3. Clear headerContainer and mount modernHeaderView
        headerContainer.subviews.forEach { $0.removeFromSuperview() }
        setupHeaderSection()
        modernHeaderView.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(modernHeaderView)
        NSLayoutConstraint.activate([
            modernHeaderView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            modernHeaderView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            modernHeaderView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            modernHeaderView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
        ])

        // 4. Configure mainStack
        mainStack.spacing = 16

        // Position 0: Header
        mainStack.insertArrangedSubview(headerContainer, at: 0)

        // Position 1: Watch Button
        setupWatchButton()
        mainStack.insertArrangedSubview(modernWatchButton, at: 1)
        NSLayoutConstraint.activate([
            modernWatchButton.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 16),
            modernWatchButton.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -16)
        ])

        // Position 2: Secondary Actions
        mainStack.insertArrangedSubview(actionsContainer, at: 2)
        donateButton.layer.cornerRadius = 10
        donateButton.layer.cornerCurve = .continuous

        // Position 3: Genres
        setupGenresSection()
        mainStack.insertArrangedSubview(genresScrollView, at: 3)
        NSLayoutConstraint.activate([
            genresScrollView.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 16),
            genresScrollView.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -16)
        ])

        // Position 4: Synopsis
        setupSynopsisSection()
        mainStack.insertArrangedSubview(synopsisContainer, at: 4)
        NSLayoutConstraint.activate([
            synopsisContainer.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 16),
            synopsisContainer.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -16)
        ])

        // Position 5: Credits Card
        setupCreditsSection()
        mainStack.insertArrangedSubview(creditsCard, at: 5)
        NSLayoutConstraint.activate([
            creditsCard.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 16),
            creditsCard.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -16)
        ])

        // Position 6: Episodes
        setupEpisodesSection()
        mainStack.insertArrangedSubview(compactEpisodesContainer, at: 6)

        // Position 7: Related (franchise carousel)
        setupRelatedSection()
        if let relatedWrapper = relatedView.superview {
            mainStack.insertArrangedSubview(relatedWrapper, at: 7)
        }

        // Position 8: Support
        setupSupportSection()
        if let supportWrapper = supportLabelContainer.superview {
            mainStack.insertArrangedSubview(supportWrapper, at: 8)
        }
    }

    private func setupHeaderSection() {
        modernHeaderView.translatesAutoresizingMaskIntoConstraints = false

        let headerStack = UIStackView()
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.spacing = 14
        headerStack.alignment = .top
        modernHeaderView.addSubview(headerStack)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: modernHeaderView.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: modernHeaderView.leadingAnchor),
            headerStack.trailingAnchor.constraint(equalTo: modernHeaderView.trailingAnchor),
            headerStack.bottomAnchor.constraint(equalTo: modernHeaderView.bottomAnchor)
        ])

        // Poster
        posterWrapper.translatesAutoresizingMaskIntoConstraints = false
        posterWrapper.layer.cornerRadius = 14
        posterWrapper.layer.cornerCurve = .continuous
        posterWrapper.clipsToBounds = true

        seriesImageView.translatesAutoresizingMaskIntoConstraints = false
        seriesImageView.removeConstraints(seriesImageView.constraints)
        seriesImageView.contentMode = .scaleAspectFill
        seriesImageView.layer.cornerRadius = 14
        seriesImageView.layer.cornerCurve = .continuous
        seriesImageView.layer.borderWidth = 1
        seriesImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        seriesImageView.clipsToBounds = true
        posterWrapper.addSubview(seriesImageView)

        weekDayView.translatesAutoresizingMaskIntoConstraints = false
        weekDayView.constraints.forEach {
            if $0.firstAttribute == .width || $0.firstAttribute == .height {
                weekDayView.removeConstraint($0)
            }
        }
        posterWrapper.addSubview(weekDayView)

        NSLayoutConstraint.activate([
            posterWrapper.widthAnchor.constraint(equalToConstant: 114),
            posterWrapper.heightAnchor.constraint(equalToConstant: 164),

            seriesImageView.topAnchor.constraint(equalTo: posterWrapper.topAnchor),
            seriesImageView.leadingAnchor.constraint(equalTo: posterWrapper.leadingAnchor),
            seriesImageView.trailingAnchor.constraint(equalTo: posterWrapper.trailingAnchor),
            seriesImageView.bottomAnchor.constraint(equalTo: posterWrapper.bottomAnchor),

            weekDayView.topAnchor.constraint(equalTo: posterWrapper.topAnchor, constant: 6),
            weekDayView.leadingAnchor.constraint(equalTo: posterWrapper.leadingAnchor, constant: 6),
            weekDayView.widthAnchor.constraint(equalToConstant: 32),
            weekDayView.heightAnchor.constraint(equalToConstant: 32)
        ])

        headerStack.addArrangedSubview(posterWrapper)

        // Meta Column
        metaStackView.translatesAutoresizingMaskIntoConstraints = false
        metaStackView.axis = .vertical
        metaStackView.spacing = 5
        metaStackView.alignment = .leading

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .Text.main
        titleLabel.numberOfLines = 3
        metaStackView.addArrangedSubview(titleLabel)

        secondTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        secondTitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        secondTitleLabel.textColor = .Text.secondary
        secondTitleLabel.numberOfLines = 2
        metaStackView.addArrangedSubview(secondTitleLabel)

        // Badges
        badgesStackView.translatesAutoresizingMaskIntoConstraints = false
        badgesStackView.axis = .horizontal
        badgesStackView.spacing = 6
        badgesStackView.alignment = .center

        [typeBadge, yearBadge, seasonBadge, episodesBadge].forEach { badge in
            badge.font = .systemFont(ofSize: 11, weight: .medium)
            badge.textColor = .Text.secondary
            badge.backgroundColor = .Surfaces.content
            badge.layer.cornerRadius = 6
            badge.layer.cornerCurve = .continuous
            badge.layer.borderWidth = 0.5
            badge.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
            badge.clipsToBounds = true
            badgesStackView.addArrangedSubview(badge)
        }

        badgesScrollView.translatesAutoresizingMaskIntoConstraints = false
        badgesScrollView.showsHorizontalScrollIndicator = false
        badgesScrollView.addSubview(badgesStackView)
        NSLayoutConstraint.activate([
            badgesStackView.topAnchor.constraint(equalTo: badgesScrollView.topAnchor),
            badgesStackView.leadingAnchor.constraint(equalTo: badgesScrollView.leadingAnchor),
            badgesStackView.trailingAnchor.constraint(equalTo: badgesScrollView.trailingAnchor),
            badgesStackView.bottomAnchor.constraint(equalTo: badgesScrollView.bottomAnchor),
            badgesStackView.heightAnchor.constraint(equalTo: badgesScrollView.heightAnchor),
            badgesScrollView.heightAnchor.constraint(equalToConstant: 24)
        ])
        metaStackView.addArrangedSubview(badgesScrollView)

        // Anonce badge
        modernAnonceContainer.translatesAutoresizingMaskIntoConstraints = false
        modernAnonceContainer.backgroundColor = (UIColor(named: "buttons/selected") ?? .systemRed).withAlphaComponent(0.12)
        modernAnonceContainer.layer.cornerRadius = 8
        modernAnonceContainer.layer.cornerCurve = .continuous
        modernAnonceContainer.layer.borderWidth = 0.5
        modernAnonceContainer.layer.borderColor = (UIColor(named: "buttons/selected") ?? .systemRed).withAlphaComponent(0.3).cgColor
        modernAnonceContainer.isHidden = true

        modernAnonceLabel.translatesAutoresizingMaskIntoConstraints = false
        modernAnonceLabel.font = .systemFont(ofSize: 11, weight: .medium)
        modernAnonceLabel.textColor = UIColor(named: "buttons/selected") ?? .systemRed
        modernAnonceLabel.numberOfLines = 2
        modernAnonceContainer.addSubview(modernAnonceLabel)

        NSLayoutConstraint.activate([
            modernAnonceLabel.topAnchor.constraint(equalTo: modernAnonceContainer.topAnchor, constant: 4),
            modernAnonceLabel.bottomAnchor.constraint(equalTo: modernAnonceContainer.bottomAnchor, constant: -4),
            modernAnonceLabel.leadingAnchor.constraint(equalTo: modernAnonceContainer.leadingAnchor, constant: 8),
            modernAnonceLabel.trailingAnchor.constraint(equalTo: modernAnonceContainer.trailingAnchor, constant: -8)
        ])
        metaStackView.addArrangedSubview(modernAnonceContainer)

        headerStack.addArrangedSubview(metaStackView)
    }

    private func setupWatchButton() {
        modernWatchButton.translatesAutoresizingMaskIntoConstraints = false
        modernWatchButton.backgroundColor = UIColor(named: "buttons/selected") ?? .systemRed
        modernWatchButton.layer.cornerRadius = 14
        modernWatchButton.layer.cornerCurve = .continuous
        modernWatchButton.clipsToBounds = true

        let contentStack = UIStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .horizontal
        contentStack.spacing = 8
        contentStack.alignment = .center
        contentStack.isUserInteractionEnabled = false
        modernWatchButton.addSubview(contentStack)

        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        modernWatchIcon.image = UIImage(systemName: "play.fill", withConfiguration: config)
        modernWatchIcon.tintColor = .white
        modernWatchIcon.contentMode = .scaleAspectFit
        contentStack.addArrangedSubview(modernWatchIcon)

        modernWatchLabel.font = .systemFont(ofSize: 16, weight: .bold)
        modernWatchLabel.textColor = .white
        modernWatchLabel.text = Language.isEnglish ? "Watch Episode 1" : "Смотреть 1 эпизод"
        contentStack.addArrangedSubview(modernWatchLabel)

        NSLayoutConstraint.activate([
            modernWatchButton.heightAnchor.constraint(equalToConstant: 48),

            contentStack.centerXAnchor.constraint(equalTo: modernWatchButton.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: modernWatchButton.centerYAnchor)
        ])

        modernWatchButton.addTarget(self, action: #selector(didTapModernWatch), for: .touchUpInside)
    }

    @objc private func didTapModernWatch() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        handler.play()
    }

    private func setupSecondaryActions() {
        actionsContainerView.translatesAutoresizingMaskIntoConstraints = false

        let verticalStack = UIStackView()
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.axis = .vertical
        verticalStack.spacing = 10
        actionsContainerView.addSubview(verticalStack)

        let buttonsRow = UIStackView()
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 8
        buttonsRow.alignment = .center

        buttonsRow.addArrangedSubview(favoriteView)
        buttonsRow.addArrangedSubview(typeView)

        let spacer = UIView()
        buttonsRow.addArrangedSubview(spacer)

        buttonsRow.addArrangedSubview(donateButton)
        donateButton.layer.cornerRadius = 10
        donateButton.layer.cornerCurve = .continuous

        verticalStack.addArrangedSubview(buttonsRow)
        verticalStack.addArrangedSubview(tagsView)

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: actionsContainerView.topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: actionsContainerView.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: actionsContainerView.trailingAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: actionsContainerView.bottomAnchor)
        ])
    }

    private func setupGenresSection() {
        genresScrollView.translatesAutoresizingMaskIntoConstraints = false
        genresScrollView.showsHorizontalScrollIndicator = false

        genresStackView.translatesAutoresizingMaskIntoConstraints = false
        genresStackView.axis = .horizontal
        genresStackView.spacing = 8
        genresStackView.alignment = .center
        genresScrollView.addSubview(genresStackView)

        NSLayoutConstraint.activate([
            genresStackView.topAnchor.constraint(equalTo: genresScrollView.topAnchor),
            genresStackView.leadingAnchor.constraint(equalTo: genresScrollView.leadingAnchor),
            genresStackView.trailingAnchor.constraint(equalTo: genresScrollView.trailingAnchor),
            genresStackView.bottomAnchor.constraint(equalTo: genresScrollView.bottomAnchor),
            genresStackView.heightAnchor.constraint(equalTo: genresScrollView.heightAnchor),
            genresScrollView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    private func setupSynopsisSection() {
        synopsisContainer.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        synopsisContainer.addSubview(stack)

        synopsisTitleLabel.text = Language.isEnglish ? "Synopsis" : "Описание"
        synopsisTitleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        synopsisTitleLabel.textColor = .Text.main
        stack.addArrangedSubview(synopsisTitleLabel)

        synopsisLabel.font = .systemFont(ofSize: 14, weight: .regular)
        synopsisLabel.textColor = .Text.main
        synopsisLabel.numberOfLines = 4
        stack.addArrangedSubview(synopsisLabel)

        expandSynopsisButton.setTitle(Language.isEnglish ? "Show more ▾" : "Подробнее ▾", for: .normal)
        expandSynopsisButton.setTitleColor(UIColor(named: "buttons/selected") ?? .systemRed, for: .normal)
        expandSynopsisButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        expandSynopsisButton.addTarget(self, action: #selector(didTapExpandSynopsis), for: .touchUpInside)
        stack.addArrangedSubview(expandSynopsisButton)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: synopsisContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: synopsisContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: synopsisContainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: synopsisContainer.bottomAnchor)
        ])
    }

    @objc private func didTapExpandSynopsis() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        isSynopsisExpanded.toggle()
        UIView.animate(withDuration: 0.25) {
            self.synopsisLabel.numberOfLines = self.isSynopsisExpanded ? 0 : 4
            let title = self.isSynopsisExpanded
                ? (Language.isEnglish ? "Show less ▴" : "Свернуть ▴")
                : (Language.isEnglish ? "Show more ▾" : "Подробнее ▾")
            self.expandSynopsisButton.setTitle(title, for: .normal)
            self.view.layoutIfNeeded()
        }
    }

    private func setupCreditsSection() {
        creditsCard.translatesAutoresizingMaskIntoConstraints = false
        creditsCard.backgroundColor = .Surfaces.content
        creditsCard.layer.cornerRadius = 14
        creditsCard.layer.cornerCurve = .continuous
        creditsCard.layer.borderWidth = 1
        creditsCard.layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        creditsCard.addSubview(stack)

        creditsTitleLabel.text = Language.isEnglish ? "Dubbing & Details" : "Команда озвучки и детали"
        creditsTitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        creditsTitleLabel.textColor = .Text.main
        stack.addArrangedSubview(creditsTitleLabel)

        creditsStackView.axis = .vertical
        creditsStackView.spacing = 6
        creditsStackView.alignment = .fill
        stack.addArrangedSubview(creditsStackView)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: creditsCard.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: creditsCard.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: creditsCard.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: creditsCard.trailingAnchor, constant: -14)
        ])
    }

    private func setupEpisodesSection() {
        compactEpisodesContainer.translatesAutoresizingMaskIntoConstraints = false
        if let heightConstraint = compactEpisodesContainer.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = 216
        } else {
            compactEpisodesContainer.heightAnchor.constraint(equalToConstant: 216).isActive = true
        }
    }

    private func setupRelatedSection() {
        relatedView.translatesAutoresizingMaskIntoConstraints = false
        relatedTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        relatedTitleLabel.textColor = .Text.main

        relatedView.constraints.forEach {
            if $0.firstItem === relatedStackView || $0.secondItem === relatedStackView {
                relatedView.removeConstraint($0)
            }
        }
        relatedStackView.isHidden = true
        relatedCarouselView.translatesAutoresizingMaskIntoConstraints = false
        relatedView.addSubview(relatedCarouselView)

        NSLayoutConstraint.activate([
            relatedCarouselView.topAnchor.constraint(equalTo: relatedTitleLabel.bottomAnchor, constant: 10),
            relatedCarouselView.leadingAnchor.constraint(equalTo: relatedView.leadingAnchor),
            relatedCarouselView.trailingAnchor.constraint(equalTo: relatedView.trailingAnchor),
            relatedCarouselView.bottomAnchor.constraint(equalTo: relatedView.bottomAnchor),
            relatedCarouselView.heightAnchor.constraint(equalToConstant: 78)
        ])
    }

    private func setupSupportSection() {
        supportLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        supportLabelContainer.smoothCorners(with: 14)
        supportLabelContainer.backgroundColor = .Surfaces.content
    }

    private func updateKeyboard(_ note: Notification) {
        guard
            let info = note.userInfo,
            let endFrameScreen = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let endFrameInView = view.convert(endFrameScreen, from: nil)
        let overlap = view.bounds.intersection(endFrameInView).height

        keyboardInset = max(0, overlap - view.safeAreaInsets.bottom)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        episodesContainreHidden = view.bounds.width < 640
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        episodesView.invalidateLayout()
    }

    private func updateInsets() {
        scrollView.contentInset.bottom = max(keyboardInset, 24)
    }

    override func setupStrings() {
        super.setupStrings()
        self.navigationItem.title = L10n.Screen.Series.title
        self.supportLabel.text = L10n.Common.donatePls
        self.relatedTitleLabel.text = L10n.Common.related
        self.donateButton.setTitle(L10n.Screen.Other.donate, for: .normal)
        self.handler.didLoad()
    }

    private func updateEpisodesUI() {
        episodesView.removeFromSuperview()
        if episodesContainreHidden {
            episodesView.isCompact = true
            compactEpisodesContainer.addSubview(episodesView)
        } else {
            episodesView.isCompact = false
            episodesContainer.addSubview(episodesView)
        }
        episodesView.constraintEdgesToSuperview()
    }

    private func setupNavigationButtons() {
        var items = [UIBarButtonItem]()
        let shareButton = BarButton(image: .System.share) { [weak self] in
            self?.handler.share()
        }
        items.append(shareButton)
        #if targetEnvironment(macCatalyst)
        let refreshButton = BarButton(image: .System.refresh) { [weak self] in
            guard let self else { return }
            _ = showRefreshIndicator()
            handler.refresh()
        }
        items.append(refreshButton)
        #endif
        self.navigationItem.setRightBarButtonItems(items, animated: false)
    }

    override func refresh() {
        super.refresh()
        handler.refresh()
    }

    @IBAction func donateAction(_ sender: Any) {
        self.handler.donate()
    }

    @IBAction func favoriteAction(_ sender: Any) {
        favoriteView.isLoading = true
        let activity = ActivityHolder { [weak self] in
            self?.favoriteView.isLoading = false
        }
        self.handler.favorite(activity)
    }

    @IBAction func selectTypeAction(_ sender: Any) {
        typeView.isLoading = true
        let activity = ActivityHolder { [weak self] in
            self?.typeView.isLoading = false
        }
        self.handler.selectCollection(activity)
    }

    @IBAction func play(_ sender: Any) {
        handler.play()
    }
}

extension SeriesViewController: SeriesViewBehavior {
    func showUpdatesActivity() -> (any ActivityDisposable)? {
        typeView.isLoading = true
        favoriteView.isLoading = true
        let activity = ActivityHolder { [weak self] in
            self?.typeView.isLoading = false
            self?.favoriteView.isLoading = false
        }
        return activity
    }

    func can(favorite: Bool) {
        self.favoriteView.isUserInteractionEnabled = favorite
    }

    func set(playInfo: String?) {
        playButtonContainer.superview?.isHidden = true
        playButtonContainer.isHidden = true
        if let playInfo {
            modernWatchButton.isHidden = false
            modernWatchLabel.text = playInfo
        } else {
            modernWatchButton.isHidden = true
        }
    }

    func set(favorite: Bool) {
        favoriteView.set(favorite: favorite)
    }

    func set(collection: UserCollectionType?) {
        typeView.configure(with: collection)
    }

    func set(episodes: EpisodesViewModel) {
        episodesView.configure(viewModel: episodes)
    }

    func set(series: Series) {
        seriesImageView.setImage(from: series.poster, placeholder: DefaultPlaceholder())
        contentShimmerViews.forEach {
            $0.stop()
            $0.isHidden = true
        }
        self.navigationItem.backButtonTitle = series.name?.main

        self.set(name: series.name)
        self.setParams(from: series)

        if let publishDay = series.publishDay, series.isOngoing {
            weekDayView.configure(publishDay.value)
            weekDayView.isSelected = true
            weekDayView.isHidden = false
        } else {
            weekDayView.isHidden = true
        }

        tagsView.set(tags: series.tags)

        #if targetEnvironment(macCatalyst)
        self.set(torrents: series.torrents)
        #endif
        view.fadeTransition()
    }

    func set(series: [Series], current: Series) {
        relatedShimmerView.isHidden = true
        relatedShimmerView.stop()
        if series.isEmpty {
            relatedView.isHidden = true
            return
        }
        relatedView.isHidden = false
        relatedStackView.isHidden = true
        relatedCarouselView.configure(series: series, current: current) { [weak self] selected in
            self?.handler.select(series: selected)
        }
        relatedView.fadeTransition()
    }

    func set(torrents: [Torrent]) {
        torrentsStackView.arrangedSubviews.forEach {
            torrentsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        let views = torrents.lazy.compactMap { item -> TorrentView? in
            let view = TorrentView.fromNib()
            view?.configure(item)
            view?.setTap { [weak self] in
                self?.handler.download(torrent: $0)
            }
            return view
        }
        for view in views {
            self.torrentsStackView.addArrangedSubview(view)
        }
    }

    func set(name: SeriesName?) {
        self.titleLabel.text = name?.main

        if name?.english.isEmpty == false {
            secondTitleLabel.isHidden = false
            secondTitleLabel.text = name?.english
        } else {
            secondTitleLabel.isHidden = true
        }
    }

    private func setParams(from series: Series) {
        // 1. Badges
        if let type = series.type?.description {
            typeBadge.text = type
            typeBadge.isHidden = false
        } else {
            typeBadge.isHidden = true
        }

        if let year = series.year {
            yearBadge.text = "\(year)"
            yearBadge.isHidden = false
        } else {
            yearBadge.isHidden = true
        }

        if let season = series.season?.description {
            seasonBadge.text = season
            seasonBadge.isHidden = false
        } else {
            seasonBadge.isHidden = true
        }

        let availableCount = series.playlist.count
        let totalCount = series.episodesTotal.map { "\($0)" } ?? "?"
        let epSuffix = Language.isEnglish ? "ep." : "эп."
        episodesBadge.text = "\(availableCount)/\(totalCount) \(epSuffix)"
        episodesBadge.isHidden = false

        // 2. Anonce
        if !series.notification.isEmpty {
            modernAnonceLabel.text = series.notification
            modernAnonceContainer.isHidden = false
        } else {
            modernAnonceContainer.isHidden = true
        }

        // 3. Genre Chips
        genresStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for genre in series.genres {
            let chip = GenreChipButton(type: .system)
            chip.setTitle(genre.name, for: .normal)
            chip.setTitleColor(.Text.main, for: .normal)
            chip.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            chip.backgroundColor = .Surfaces.content
            chip.layer.cornerRadius = 14
            chip.layer.cornerCurve = .continuous
            chip.layer.borderWidth = 1
            chip.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
            chip.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            chip.onSelect = { [weak self] in
                self?.handler.select(genre: "\(genre.id)")
            }
            genresStackView.addArrangedSubview(chip)
        }
        genresScrollView.isHidden = series.genres.isEmpty

        // 4. Synopsis
        if let desc = series.desc, !desc.string.isEmpty {
            let mutableDesc = NSMutableAttributedString(attributedString: desc)
            mutableDesc.addAttribute(.foregroundColor, value: UIColor.Text.main, range: NSRange(location: 0, length: mutableDesc.length))
            mutableDesc.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .regular), range: NSRange(location: 0, length: mutableDesc.length))
            synopsisLabel.attributedText = mutableDesc
            synopsisContainer.isHidden = false
            expandSynopsisButton.isHidden = desc.string.count < 140
        } else {
            synopsisContainer.isHidden = true
        }

        // 5. Credits
        creditsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if let duration = series.averageDurationOfEpisode {
            let durationTitle = Language.isEnglish ? "Duration" : "Длительность"
            let durationValue = Language.isEnglish ? "~ \(duration) min" : "~ \(duration) мин"
            addCreditRow(title: durationTitle, value: durationValue)
        }

        if !series.members.isEmpty {
            let items = Dictionary(grouping: series.members, by: { $0.role })
            let roles = items.compactMap { $0.key }.sorted(by: { $0.value < $1.value })
            roles.forEach { role in
                let members = items[role] ?? []
                let names = members.map { $0.name }.joined(separator: ", ")
                addCreditRow(title: role.description, value: names)
            }
        }
        creditsCard.isHidden = creditsStackView.arrangedSubviews.isEmpty
    }

    private func addCreditRow(title: String, value: String) {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .top

        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLbl.textColor = .Text.secondary
        titleLbl.text = "\(title):"
        titleLbl.widthAnchor.constraint(equalToConstant: 105).isActive = true
        row.addArrangedSubview(titleLbl)

        let valueLbl = UILabel()
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.font = .systemFont(ofSize: 13, weight: .regular)
        valueLbl.textColor = .Text.main
        valueLbl.numberOfLines = 0
        valueLbl.text = value
        row.addArrangedSubview(valueLbl)

        creditsStackView.addArrangedSubview(row)
    }
}

final class BadgeLabel: UILabel {
    var insets = UIEdgeInsets(top: 3, left: 6, bottom: 3, right: 6)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}

final class GenreChipButton: UIButton {
    var onSelect: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    @objc private func didTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onSelect?()
    }
}

private extension Series {
    var tags: [TagsView.Tag] {
        UserCollectionKey.allCases.compactMap {
            if let count = addedIn[$0], count > 0 {
                return .init(icon: $0.icon, title: "\(count)")
            }
            return nil
        }
    }
}

private extension String {
    func withColon() -> String {
        "\(self): "
    }
}

public final class ExpandedSpaceView: UIView {
    public override var intrinsicContentSize: CGSize {
        UIView.layoutFittingExpandedSize
    }
}
