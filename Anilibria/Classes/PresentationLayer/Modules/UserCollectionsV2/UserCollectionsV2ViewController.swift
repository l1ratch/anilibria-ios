//
//  UserCollectionsV2ViewController.swift
//  Anilibria
//
//  Created by Antigravity on 03.09.2026.
//

import Combine
import UIKit

final class UserCollectionsV2ViewController: BaseViewController {
    var handler: UserCollectionsV2EventHandler!

    private var sections: [UserCollectionGroupSection] = []
    private var collectionView: UICollectionView!
    private var loadingActivity: ActivityDisposable?

    private lazy var searchButton = BarButton(
        image: .System.search,
        imageEdge: inset(0, 5, 0, 5)
    ) { [weak self] in
        self?.handler.search()
    }

    override var isNavigationBarVisible: Bool { true }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Language.isEnglish ? "Lists" : "Списки"
        view.backgroundColor = .Surfaces.background

        setupNavigationBar()
        setupCollectionView()

        handler.didLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup Navigation Bar

    private func setupNavigationBar() {
        navigationItem.title = Language.isEnglish ? "Lists" : "Списки"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.setRightBarButtonItems([searchButton], animated: false)
    }

    // MARK: - Setup Collection View

    private func setupCollectionView() {
        let layout = createCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 88, right: 0)
        collectionView.showsVerticalScrollIndicator = false

        collectionView.register(UserCollectionCardCell.self, forCellWithReuseIdentifier: UserCollectionCardCell.reuseIdentifier)
        collectionView.register(UserCollectionEmptyCell.self, forCellWithReuseIdentifier: UserCollectionEmptyCell.reuseIdentifier)
        collectionView.register(
            UserCollectionHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: UserCollectionHeaderReusableView.reuseIdentifier
        )

        self.addRefreshControl(scrollView: collectionView)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let self = self, sectionIndex < self.sections.count else { return nil }
            let sectionData = self.sections[sectionIndex]

            // Header definition
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(36)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )

            if sectionData.items.isEmpty && !sectionData.isLoading {
                // Empty state card
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(64)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                section.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 0, bottom: 20, trailing: 0)
                return section
            }

            // Horizontal gallery item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(114),
                heightDimension: .absolute(206)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(114),
                heightDimension: .absolute(206)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 22, trailing: 16)
            section.boundarySupplementaryItems = [header]

            return section
        }
    }

    override func refresh() {
        super.refresh()
        handler.refresh()
    }
}

// MARK: - UICollectionViewDataSource

extension UserCollectionsV2ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = sections[section].items.count
        if count == 0 && !sections[section].isLoading {
            return 1 // Shows UserCollectionEmptyCell
        }
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionData = sections[indexPath.section]

        if sectionData.items.isEmpty && !sectionData.isLoading {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: UserCollectionEmptyCell.reuseIdentifier,
                for: indexPath
            )
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserCollectionCardCell.reuseIdentifier,
            for: indexPath
        ) as? UserCollectionCardCell else {
            return UICollectionViewCell()
        }

        if indexPath.item < sectionData.items.count {
            cell.configure(with: sectionData.items[indexPath.item])
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: UserCollectionHeaderReusableView.reuseIdentifier,
                for: indexPath
              ) as? UserCollectionHeaderReusableView else {
            return UICollectionReusableView()
        }

        let sectionData = sections[indexPath.section]
        header.configure(with: sectionData.key, count: sectionData.items.count)
        header.onSeeAllTap = { [weak self] in
            self?.handler.openDetail(for: sectionData.key)
        }
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionData = sections[indexPath.section]
        guard indexPath.item < sectionData.items.count else { return }
        handler.select(series: sectionData.items[indexPath.item])
    }
}

// MARK: - UserCollectionsV2ViewBehavior

extension UserCollectionsV2ViewController: UserCollectionsV2ViewBehavior {
    func set(sections: [UserCollectionGroupSection]) {
        self.sections = sections
        self.collectionView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    func update(section: UserCollectionGroupSection, at index: Int) {
        if index < sections.count {
            self.sections[index] = section
            self.collectionView.reloadSections(IndexSet(integer: index))
        }
    }

    func showLoading(_ show: Bool) {
        if show {
            if loadingActivity == nil {
                loadingActivity = showLoading(fullscreen: false)
            }
        } else {
            loadingActivity = nil
            self.refreshControl?.endRefreshing()
        }
    }
}
