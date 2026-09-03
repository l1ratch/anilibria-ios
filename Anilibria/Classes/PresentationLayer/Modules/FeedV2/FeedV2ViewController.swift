//
//  FeedV2ViewController.swift
//  Anilibria
//
//  Created by Antigravity on 02.09.2026.
//

import UIKit

final class FeedV2ViewController: BaseViewController {
    var handler: FeedV2EventHandler!

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    // MARK: - Sections

    // 1. Hero Showcase
    private var heroItems: [PromoItem] = []
    private var heroCollectionView: UICollectionView!
    private let pageControl = UIPageControl()
    private var autoScrollTimer: Timer?

    // 2. Quick Actions
    private let quickActionsView = FeedV2QuickActionsView()

    // 3. Continue Watching
    private let continueWatchingView = FeedV2ContinueWatchingView()
    private var continueSeries: Series?

    // 4. Today's Schedule
    private var scheduleItems: [ScheduleItem] = []
    private let scheduleHeaderContainer = UIView()
    private let scheduleTitleLabel = UILabel()
    private let scheduleAllButton = UIButton(type: .system)
    private var scheduleCollectionView: UICollectionView!

    private lazy var searchButton = BarButton(image: .System.search,
                                              imageEdge: inset(0, 5, 0, 5)) { [weak self] in
        self?.handler.search()
    }

    private lazy var otherMenuButton = BarButton(
        image: UIImage(systemName: "line.3.horizontal", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)) ?? .System.dots,
        imageEdge: inset(0, 5, 0, 5)
    ) { [weak self] in
        self?.openOtherScreen()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupScrollView()
        setupHeroSection()
        setupQuickActions()
        setupContinueWatching()
        setupScheduleSection()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDockItemsChanged),
            name: NSNotification.Name("dockItemsChanged"),
            object: nil
        )

        handler.didLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateOtherNavigationButton()
    }

    @objc private func handleDockItemsChanged() {
        updateOtherNavigationButton()
    }

    private func updateOtherNavigationButton() {
        let hasOtherInDock = MenuItemsFactory.getActiveTypes().contains(.other)
        if !hasOtherInDock {
            navigationItem.leftBarButtonItem = otherMenuButton
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }

    private func openOtherScreen() {
        let otherVC = OtherAssembly.createModule()
        otherVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(otherVC, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handler.refreshIfNeeded()
        startAutoScroll()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoScroll()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let contentHeight = contentStackView.frame.height + scrollView.contentInset.top + scrollView.contentInset.bottom
        scrollView.isScrollEnabled = contentHeight > scrollView.bounds.height

        let screenWidth = min(view.bounds.width, view.bounds.height)
        if screenWidth > 0, let layout = heroCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let expectedWidth = screenWidth - 32
            if layout.itemSize.width != expectedWidth {
                layout.itemSize = CGSize(width: expectedWidth, height: 220)
                layout.invalidateLayout()
            }
        }
    }

    // MARK: - Setup Navigation & Scroll

    private func setupNavigationBar() {
        navigationItem.title = "AniLiberty"
        navigationItem.rightBarButtonItem = searchButton
        view.backgroundColor = .Surfaces.background
        updateOtherNavigationButton()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 84, right: 0)

        self.addRefreshControl(scrollView: scrollView)

        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 12
        contentStackView.alignment = .fill

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Hero Section

    private func setupHeroSection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        layout.itemSize = CGSize(width: screenWidth - 32, height: 220)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        heroCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        heroCollectionView.translatesAutoresizingMaskIntoConstraints = false
        heroCollectionView.backgroundColor = .clear
        heroCollectionView.showsHorizontalScrollIndicator = false
        heroCollectionView.isPagingEnabled = false
        heroCollectionView.decelerationRate = .fast
        heroCollectionView.delegate = self
        heroCollectionView.dataSource = self
        heroCollectionView.register(FeedV2HeroCell.self, forCellWithReuseIdentifier: FeedV2HeroCell.reuseIdentifier)

        let heroContainer = UIStackView()
        heroContainer.translatesAutoresizingMaskIntoConstraints = false
        heroContainer.axis = .vertical
        heroContainer.spacing = 4
        heroContainer.alignment = .fill

        pageControl.currentPageIndicatorTintColor = UIColor(named: "buttons/selected") ?? .systemRed
        pageControl.pageIndicatorTintColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.25)
                : UIColor.black.withAlphaComponent(0.20)
        }
        pageControl.hidesForSinglePage = true
        pageControl.isUserInteractionEnabled = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        heroContainer.addArrangedSubview(heroCollectionView)
        heroContainer.addArrangedSubview(pageControl)

        contentStackView.addArrangedSubview(heroContainer)

        NSLayoutConstraint.activate([
            heroCollectionView.heightAnchor.constraint(equalToConstant: 220),
            pageControl.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    // MARK: - Quick Actions

    private func setupQuickActions() {
        quickActionsView.onRandomTap = { [weak self] in
            self?.handler.selectRandom()
        }
        quickActionsView.onScheduleTap = { [weak self] in
            self?.handler.allSchedule()
        }
        quickActionsView.onCatalogTap = { [weak self] in
            self?.handler.openCatalog()
        }

        contentStackView.addArrangedSubview(quickActionsView)
    }

    // MARK: - Continue Watching

    private func setupContinueWatching() {
        continueWatchingView.isHidden = true
        continueWatchingView.onTap = { [weak self] in
            guard let self = self, let series = self.continueSeries else { return }
            self.handler.continueWatching(series: series)
        }
        contentStackView.addArrangedSubview(continueWatchingView)
    }

    // MARK: - Today's Schedule

    private func setupScheduleSection() {
        scheduleHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        scheduleHeaderContainer.heightAnchor.constraint(equalToConstant: 32).isActive = true

        scheduleTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        scheduleTitleLabel.textColor = .Text.main
        scheduleTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleHeaderContainer.addSubview(scheduleTitleLabel)

        let formatter = DateFormatter()
        formatter.locale = Language.isEnglish ? Locale(identifier: "en_US") : Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        let dayName = formatter.string(from: Date()).capitalized
        let todayPrefix = Language.isEnglish ? "Today" : "Сегодня"
        scheduleTitleLabel.text = "\(todayPrefix), \(dayName)"

        let allWeekTitle = Language.isEnglish ? "Full week  " : "Вся неделя  "
        scheduleAllButton.setTitle(allWeekTitle, for: .normal)
        scheduleAllButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        scheduleAllButton.semanticContentAttribute = .forceRightToLeft
        scheduleAllButton.tintColor = UIColor(named: "buttons/selected") ?? .systemRed
        scheduleAllButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        scheduleAllButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleAllButton.addTarget(self, action: #selector(didTapAllSchedule), for: .touchUpInside)
        scheduleHeaderContainer.addSubview(scheduleAllButton)

        contentStackView.addArrangedSubview(scheduleHeaderContainer)

        NSLayoutConstraint.activate([
            scheduleHeaderContainer.heightAnchor.constraint(equalToConstant: 28),

            scheduleTitleLabel.leadingAnchor.constraint(equalTo: scheduleHeaderContainer.leadingAnchor, constant: 16),
            scheduleTitleLabel.centerYAnchor.constraint(equalTo: scheduleHeaderContainer.centerYAnchor),

            scheduleAllButton.trailingAnchor.constraint(equalTo: scheduleHeaderContainer.trailingAnchor, constant: -16),
            scheduleAllButton.centerYAnchor.constraint(equalTo: scheduleHeaderContainer.centerYAnchor)
        ])

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 114, height: 206)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        scheduleCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        scheduleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        scheduleCollectionView.backgroundColor = .clear
        scheduleCollectionView.showsHorizontalScrollIndicator = false
        scheduleCollectionView.delegate = self
        scheduleCollectionView.dataSource = self
        scheduleCollectionView.register(FeedV2ScheduleCell.self, forCellWithReuseIdentifier: FeedV2ScheduleCell.reuseIdentifier)

        contentStackView.addArrangedSubview(scheduleCollectionView)

        NSLayoutConstraint.activate([
            scheduleCollectionView.heightAnchor.constraint(equalToConstant: 206)
        ])
    }

    override func refresh() {
        super.refresh()
        handler.refresh()
    }

    private let heroMultiplier = 100

    @objc private func didTapAllSchedule() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        handler.allSchedule()
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension FeedV2ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == heroCollectionView {
            guard !heroItems.isEmpty else { return 0 }
            return heroItems.count > 1 ? heroItems.count * heroMultiplier : 1
        } else {
            return scheduleItems.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == heroCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedV2HeroCell.reuseIdentifier, for: indexPath) as! FeedV2HeroCell
            let item = heroItems[indexPath.item % heroItems.count]
            cell.configure(with: item)
            cell.onActionTap = { [weak self] in
                switch item.content {
                case .promo(let p) where p.url == nil:
                    self?.handler.selectPromoDetails(promo: item)
                case nil:
                    self?.handler.selectPromoDetails(promo: item)
                default:
                    self?.handler.select(promo: item)
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedV2ScheduleCell.reuseIdentifier, for: indexPath) as! FeedV2ScheduleCell
            let item = scheduleItems[indexPath.item]
            cell.configure(with: item)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == heroCollectionView {
            guard !heroItems.isEmpty else { return }
            let item = heroItems[indexPath.item % heroItems.count]
            switch item.content {
            case .release:
                return
            default:
                handler.selectPromoDetails(promo: item)
            }
        } else {
            guard indexPath.item < scheduleItems.count else { return }
            let item = scheduleItems[indexPath.item]
            handler.select(series: item.item)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == heroCollectionView {
            stopAutoScroll()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == heroCollectionView {
            startAutoScroll()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == heroCollectionView, heroItems.count > 1 {
            let screenWidth = min(view.bounds.width, view.bounds.height)
            let itemWidth = (screenWidth - 32) + 12
            guard itemWidth > 0 else { return }
            let rawIndex = Int(round(scrollView.contentOffset.x / itemWidth))
            if rawIndex < (heroMultiplier / 4) * heroItems.count || rawIndex > (3 * heroMultiplier / 4) * heroItems.count {
                let currentItem = ((rawIndex % heroItems.count) + heroItems.count) % heroItems.count
                let resetIndex = (heroMultiplier / 2) * heroItems.count + currentItem
                heroCollectionView.scrollToItem(at: IndexPath(item: resetIndex, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == heroCollectionView {
            let screenWidth = min(view.bounds.width, view.bounds.height)
            let cardWidth = screenWidth - 32
            let spacing: CGFloat = 12
            let itemWidth = cardWidth + spacing

            let rawTarget = targetContentOffset.pointee.x
            let index: CGFloat
            if velocity.x > 0.2 {
                index = ceil(scrollView.contentOffset.x / itemWidth)
            } else if velocity.x < -0.2 {
                index = floor(scrollView.contentOffset.x / itemWidth)
            } else {
                index = round(rawTarget / itemWidth)
            }
            let maxIndex = CGFloat(heroItems.count * heroMultiplier - 1)
            let clampedIndex = max(0, min(maxIndex, index))
            targetContentOffset.pointee = CGPoint(x: clampedIndex * itemWidth, y: targetContentOffset.pointee.y)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == heroCollectionView, !heroItems.isEmpty {
            let screenWidth = min(view.bounds.width, view.bounds.height)
            let itemWidth = (screenWidth - 32) + 12
            if itemWidth > 0 {
                let rawIndex = Int(round(scrollView.contentOffset.x / itemWidth))
                let page = ((rawIndex % heroItems.count) + heroItems.count) % heroItems.count
                pageControl.currentPage = page
            }
        }
    }

    // MARK: - Auto Scroll

    private func startAutoScroll() {
        stopAutoScroll()
        guard heroItems.count > 1 else { return }
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 5.5, repeats: true) { [weak self] _ in
            self?.scrollToNextHero()
        }
    }

    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    private func scrollToNextHero() {
        guard heroItems.count > 1,
              let cv = heroCollectionView,
              !cv.isTracking,
              !cv.isDragging,
              !cv.isDecelerating else { return }

        let screenWidth = min(view.bounds.width, view.bounds.height)
        let itemWidth = (screenWidth - 32) + 12
        guard itemWidth > 0 else { return }
        let currentRawIndex = Int(round(cv.contentOffset.x / itemWidth))
        let nextRawIndex = currentRawIndex + 1
        guard nextRawIndex < heroItems.count * heroMultiplier else {
            let middleIndex = (heroMultiplier / 2) * heroItems.count
            cv.scrollToItem(at: IndexPath(item: middleIndex, section: 0), at: .centeredHorizontally, animated: false)
            return
        }

        cv.scrollToItem(at: IndexPath(item: nextRawIndex, section: 0), at: .centeredHorizontally, animated: true)
        let page = ((nextRawIndex % heroItems.count) + heroItems.count) % heroItems.count
        pageControl.currentPage = page
    }
}

// MARK: - FeedV2ViewBehavior

extension FeedV2ViewController: FeedV2ViewBehavior {
    func set(heroItems: [PromoItem]) {
        self.heroItems = heroItems
        self.pageControl.numberOfPages = heroItems.count
        self.pageControl.currentPage = 0
        self.heroCollectionView.reloadData()
        self.heroCollectionView.superview?.isHidden = heroItems.isEmpty

        if heroItems.count > 1 {
            let middleIndex = (heroMultiplier / 2) * heroItems.count
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.heroCollectionView.scrollToItem(
                    at: IndexPath(item: middleIndex, section: 0),
                    at: .centeredHorizontally,
                    animated: false
                )
            }
        }
        startAutoScroll()
    }

    func set(continueWatching: Series?, episodeID: String?) {
        self.continueSeries = continueWatching
        if let series = continueWatching {
            self.continueWatchingView.isHidden = false
            self.continueWatchingView.configure(with: series, episodeID: episodeID)
        } else {
            self.continueWatchingView.isHidden = true
        }
    }

    func set(schedule: ShortSchedule) {
        let items = schedule.items[.today] ?? []
        self.scheduleItems = items
        self.scheduleCollectionView.reloadData()
        self.refreshControl?.endRefreshing()
        self.scheduleCollectionView.isHidden = items.isEmpty
    }
}
