import io

menu_items_append = """
public final class MenuSettingsManager {
    public static let shared = MenuSettingsManager()
    
    private let activeTabsKey = "AniLiberty.ActiveTabs"
    private let inactiveTabsKey = "AniLiberty.InactiveTabs"
    
    private let defaultActive: [MenuItemType] = [.feed, .catalog, .news, .collections, .other]
    private let defaultInactive: [MenuItemType] = []
    
    public init() {}
    
    public func getActiveTabs() -> [MenuItemType] {
        if let saved = UserDefaults.standard.stringArray(forKey: activeTabsKey) {
            return saved.compactMap { MenuItemType(rawValue: $0) }
        }
        return defaultActive
    }
    
    public func getInactiveTabs() -> [MenuItemType] {
        if let saved = UserDefaults.standard.stringArray(forKey: inactiveTabsKey) {
            return saved.compactMap { MenuItemType(rawValue: $0) }
        }
        return defaultInactive
    }
    
    public func save(active: [MenuItemType], inactive: [MenuItemType]) {
        let activeStrings = active.map { $0.rawValue }
        let inactiveStrings = inactive.map { $0.rawValue }
        UserDefaults.standard.set(activeStrings, forKey: activeTabsKey)
        UserDefaults.standard.set(inactiveStrings, forKey: inactiveTabsKey)
    }
}
"""

with open("Anilibria/Classes/Common/Models/MenuItems.swift", "a", encoding="utf-8") as f:
    f.write(menu_items_append)

mr_other_append = """
final class TabSettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var activeTabs: [MenuItemType] = []
    private var inactiveTabs: [MenuItemType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройка вкладок"
        view.backgroundColor = .Surfaces.background
        
        activeTabs = MenuSettingsManager.shared.getActiveTabs()
        inactiveTabs = MenuSettingsManager.shared.getInactiveTabs()
        
        setupTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MenuSettingsManager.shared.save(active: activeTabs, inactive: inactiveTabs)
        NotificationCenter.default.post(name: NSNotification.Name("TabsSettingsDidChange"), object: nil)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TabCell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? activeTabs.count : inactiveTabs.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Активные вкладки" : "Скрытые вкладки"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TabCell", for: indexPath)
        let type = indexPath.section == 0 ? activeTabs[indexPath.row] : inactiveTabs[indexPath.row]
        
        let title: String
        let icon: UIImage?
        
        switch type {
        case .feed: title = "Главная"; icon = .System.feed
        case .catalog: title = "Каталог"; icon = .System.catalog
        case .news: title = "Новости"; icon = .System.media
        case .collections: title = "Избранное"; icon = .System.collections
        case .other: title = "Другое"; icon = .System.more
        }
        
        var content = cell.defaultContentConfiguration()
        content.text = title
        content.image = icon
        content.imageProperties.tintColor = .Tint.active
        cell.contentConfiguration = content
        cell.backgroundColor = .Surfaces.content
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == 0 {
            return activeTabs.count > 1 ? .delete : .none
        } else {
            return .insert
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = activeTabs.remove(at: indexPath.row)
            inactiveTabs.append(item)
            tableView.moveRow(at: indexPath, to: IndexPath(row: inactiveTabs.count - 1, section: 1))
        } else if editingStyle == .insert {
            let item = inactiveTabs.remove(at: indexPath.row)
            activeTabs.append(item)
            tableView.moveRow(at: indexPath, to: IndexPath(row: activeTabs.count - 1, section: 0))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section != 0 {
            return IndexPath(row: activeTabs.count - 1, section: 0)
        }
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = activeTabs.remove(at: sourceIndexPath.row)
        activeTabs.insert(movedObject, at: destinationIndexPath.row)
    }
}
"""

with open("Anilibria/Classes/PresentationLayer/Modules/Other/MROtherView.swift", "a", encoding="utf-8") as f:
    f.write(mr_other_append)

print("Done appending!")
