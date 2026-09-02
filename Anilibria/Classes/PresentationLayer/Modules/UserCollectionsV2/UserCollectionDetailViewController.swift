//
//  UserCollectionDetailViewController.swift
//  Anilibria
//
//  Created by Antigravity on 03.09.2026.
//

import Combine
import UIKit

final class UserCollectionDetailViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private let key: UserCollectionKey
    private var seriesList: [Series] = []
    private var currentPage: Int = 1
    private var hasMorePages: Bool = true
    private var isLoadingPage: Bool = false

    private var collectionView: UICollectionView!
    private var bag = Set<AnyCancellable>()

    private lazy var userCollectionsService: UserCollectionsService = MainAppCoordinator.shared.container.resolve()
    private lazy var favoriteService: FavoriteService = MainAppCoordinator.shared.container.resolve()

    init(key: UserCollectionKey) {
        self.key = key
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isNavigationBarVisible: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = key.title
        view.backgroundColor = .Surfaces.background

        setupCollectionView()
        loadData(page: 1)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let spacing: CGFloat = 12
        let sideInset: CGFloat = 16
        let totalSpacing = sideInset * 2 + spacing
        let itemWidth = floor((screenWidth - totalSpacing) / 2)
        let itemHeight: CGFloat = itemWidth * 1.5 + 44

        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: sideInset, bottom: 96, right: sideInset)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(UserCollectionCardCell.self, forCellWithReuseIdentifier: UserCollectionCardCell.reuseIdentifier)

        self.addRefreshControl(scrollView: collectionView)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func refresh() {
        super.refresh()
        loadData(page: 1)
    }

    private func loadData(page: Int) {
        guard !isLoadingPage else { return }
        isLoadingPage = true

        let publisher: AnyPublisher<[Series], Error>
        if let type = key.collectionType {
            publisher = userCollectionsService.fetchSeries(type: type, limit: 20, page: page, data: SeriesSearchData())
        } else {
            publisher = favoriteService.fetchSeries(limit: 20, page: page, data: SeriesSearchData())
        }

        publisher
            .sink(onNext: { [weak self] items in
                guard let self = self else { return }
                self.isLoadingPage = false
                self.refreshControl?.endRefreshing()
                if page == 1 {
                    self.seriesList = items
                } else {
                    self.seriesList.append(contentsOf: items)
                }
                self.hasMorePages = items.count >= 20
                self.currentPage = page
                self.collectionView.reloadData()
            }, onError: { [weak self] _ in
                guard let self = self else { return }
                self.isLoadingPage = false
                self.refreshControl?.endRefreshing()
            })
            .store(in: &bag)
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        seriesList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserCollectionCardCell.reuseIdentifier,
            for: indexPath
        ) as? UserCollectionCardCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: seriesList[indexPath.item])
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let series = seriesList[indexPath.item]
        let seriesVC = SeriesAssembly.createModule(series: series)
        navigationController?.pushViewController(seriesVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == seriesList.count - 4 && hasMorePages && !isLoadingPage {
            loadData(page: currentPage + 1)
        }
    }
}
