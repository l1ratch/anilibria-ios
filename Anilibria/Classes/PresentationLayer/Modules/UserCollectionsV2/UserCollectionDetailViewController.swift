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

    private var router: UserCollectionRouter!

    private lazy var searchButton = BarButton(
        image: .System.search,
        imageEdge: inset(0, 5, 0, 5)
    ) { [weak self] in
        self?.router.openSearchScreen()
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

        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: root.topAnchor),
            cv.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            cv.bottomAnchor.constraint(equalTo: root.bottomAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = key.title
        self.view.backgroundColor = .Surfaces.background

        setupNavbar()
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
    }

    private func setupViewModel() {
        let router = UserCollectionRouter(view: self, parent: nil)
        self.router = router
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
