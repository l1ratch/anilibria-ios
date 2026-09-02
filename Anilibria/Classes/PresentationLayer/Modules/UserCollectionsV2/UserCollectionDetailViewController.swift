//
//  UserCollectionDetailViewController.swift
//  Anilibria
//
//  Created by Antigravity on 03.09.2026.
//

import Combine
import UIKit

final class UserCollectionDetailViewController: BaseCollectionViewController {
    private let key: UserCollectionKey
    private var viewModel: (any UserCollectionViewModelProtocol)!
    private var bag = Set<AnyCancellable>()

    private let searchView = SearchView()
    private var searchHeightConstraint: NSLayoutConstraint!
    private var isSearchVisible = false

    private lazy var searchButton = BarButton(
        image: .System.search,
        imageEdge: inset(0, 5, 0, 5)
    ) { [weak self] in
        self?.toggleSearch()
    }

    private lazy var filterButton = BarButton(image: .iconFilter) { [weak self] in
        self?.viewModel.openFilter()
    }

    private let stubView: StubView? = StubView.fromNib()?.apply {
        $0.set(image: .System.book, color: .Text.secondary)
        $0.title = L10n.Stub.title
    }

    init(key: UserCollectionKey) {
        self.key = key
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isNavigationBarVisible: Bool { true }

    override func loadView() {
        let root = UIView()
        root.backgroundColor = .Surfaces.background

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false

        root.addSubview(cv)
        self.collectionView = cv
        self.view = root
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = key.title
        self.view.backgroundColor = .Surfaces.background

        setupNavbar()
        setupSearchView()
        setupViewModel()
        self.addRefreshControl(scrollView: collectionView)
        self.collectionView.contentInset.top = 10
        self.collectionView.contentInset.bottom = 88
    }

    override func refresh() {
        super.refresh()
        viewModel.refresh()
    }

    private func setupNavbar() {
        navigationItem.setRightBarButtonItems([searchButton, filterButton], animated: false)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupSearchView() {
        searchView.translatesAutoresizingMaskIntoConstraints = false
        searchView.clipsToBounds = true
        view.addSubview(searchView)

        searchHeightConstraint = searchView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchHeightConstraint,

            collectionView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        searchView.querySequence()
            .dropFirst()
            .map { $0.trim() }
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.viewModel.search(query: text)
            }
            .store(in: &bag)
    }

    private func toggleSearch() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        isSearchVisible.toggle()
        searchHeightConstraint.constant = isSearchVisible ? 44 : 0

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            if !self.isSearchVisible {
                self.viewModel.search(query: "")
            }
        }
    }

    private func setupViewModel() {
        let router = UserCollectionRouter(view: self, parent: nil)
        if let type = key.collectionType {
            let vm: UserCollectionViewModel = MainAppCoordinator.shared.container.resolve()
            router.responder = vm
            vm.bind(type: type, router: router)
            self.viewModel = vm
        } else {
            let vm: FavoriteViewModel = MainAppCoordinator.shared.container.resolve()
            router.responder = vm
            vm.bind(router: router)
            self.viewModel = vm
        }

        viewModel.activityBehavior = self
        set(sections: [SeriesSectionsAdapter(viewModel)])

        viewModel.items.dropFirst().sink { [weak self] items in
            guard let self = self else { return }
            if items.isEmpty {
                self.stubView?.message = L10n.Stub.Collection.message
                self.collectionView.backgroundView = self.stubView
            } else {
                self.collectionView.backgroundView = nil
            }
        }.store(in: &bag)

        viewModel.filterActive.sink { [weak self] active in
            guard let self = self else { return }
            self.filterButton.tintColor = active ? .Tint.active : .Tint.main
        }.store(in: &bag)

        viewModel.didLoad()
    }
}
