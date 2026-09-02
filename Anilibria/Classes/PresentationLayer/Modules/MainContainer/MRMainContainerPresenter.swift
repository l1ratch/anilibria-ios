import DITranquillity
import Combine
import UIKit

final class MainContainerPart: DIPart {
    static func load(container: DIContainer) {
        container.register(MainContainerPresenter.init)
            .as(MainContainerEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class MainContainerPresenter {
    private weak var view: MainContainerViewBehavior!
    private var router: MainContainerRoutable!

    private let menuService: MenuService
    private let sessionService: SessionService
    private let mainService: MainService

    private var bag = Set<AnyCancellable>()

    init(menuService: MenuService,
         sessionService: SessionService,
         mainService: MainService) {
        self.menuService = menuService
        self.sessionService = sessionService
        self.mainService = mainService
    }
}

extension MainContainerPresenter: MainContainerEventHandler {
    func bind(view: MainContainerViewBehavior, router: MainContainerRoutable) {
        self.view = view
        self.router = router
    }

    func didLoad() {
        let items = self.menuService.fetchItems()
        self.view.set(items: items)

        self.select(item: items.first?.type ?? .feedV2)

        self.menuService.fetchCurrentItem()
            .sink(onNext: { [weak self] type in
                self?.view.set(selected: type)
                self?.router.open(menu: type)
            })
            .store(in: &bag)

        self.sessionService
            .fetchState()
            .sink(onNext: { [weak self] value in
                switch value {
                case .guest:
                    if let current = self?.menuService.getSelected(), current == .collections {
                        self?.menuService.setMenuItem(type: items.first?.type ?? .feedV2)
                    }
                    self?.view.change(visible: false, for: .collections)
                case .user:
                    self?.view.change(visible: true, for: .collections)
                }

            })
            .store(in: &bag)

        NotificationCenter.default
            .publisher(for: NSNotification.Name("dockItemsChanged"))
            .sink { [weak self] _ in
                guard let self = self else { return }
                let items = self.menuService.fetchItems()
                self.view.set(items: items)
                if let current = self.menuService.getSelected(), items.contains(where: { $0.type == current }) {
                    self.view.set(selected: current)
                } else if let first = items.first {
                    self.select(item: first.type)
                }
            }
            .store(in: &bag)
    }

    func select(item: MenuItemType) {
        self.menuService.setMenuItem(type: item)
    }
}
