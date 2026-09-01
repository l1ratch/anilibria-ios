import UIKit

// MARK: - View Controller

final class OtherViewController: BaseViewController {
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var authButton: UIButton!
    @IBOutlet var linksStackView: UIStackView!

    @IBOutlet var linkDeviceLabel: UILabel!
    @IBOutlet var linkDeviceView: UIView!
    @IBOutlet var historyTitleLabel: UILabel!
    @IBOutlet var historyView: UIView!
    @IBOutlet var teamTitleLabel: UILabel!
    @IBOutlet var donateTitleLabel: UILabel!
    @IBOutlet var settingsTitleLabel: UILabel!

    var handler: OtherEventHandler!

    override var isNavigationBarVisible: Bool { false }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLiquidGlassStyle()
        setupTabSettingsButton()

        if UIDevice.current.userInterfaceIdiom == .pad {
            historyView.isHidden = true
        }
    }

    private func setupLiquidGlassStyle() {
        view.backgroundColor = .Surfaces.background
        userNameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        userNameLabel.textColor = .Text.main

        authButton.smoothCorners(with: 16)
        authButton.backgroundColor = UIColor.Tint.active.withAlphaComponent(0.15)
        authButton.layer.borderColor = UIColor.Tint.active.withAlphaComponent(0.4).cgColor
        authButton.layer.borderWidth = 0.75
        authButton.setTitleColor(.Tint.active, for: .normal)
        authButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        authButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)

        // Style all BorderedView containers as grouped glass cards
        view.subviews.forEach { sub in
            applyGlassRecursively(sub)
        }
    }

    private func applyGlassRecursively(_ view: UIView) {
        if let bordered = view as? BorderedView {
            bordered.smoothCorners(with: 20)
            bordered.backgroundColor = UIColor.Surfaces.content.withAlphaComponent(0.65)
            bordered.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
            bordered.layer.borderWidth = 0.75
        }
        view.subviews.forEach { applyGlassRecursively($0) }
    }
    
    private func setupTabSettingsButton() {
        let tabSettingsBtn = UIButton(type: .system)
        tabSettingsBtn.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        tabSettingsBtn.tintColor = .white
        tabSettingsBtn.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        tabSettingsBtn.layer.cornerRadius = 22
        tabSettingsBtn.translatesAutoresizingMaskIntoConstraints = false
        tabSettingsBtn.addTarget(self, action: #selector(openTabSettings), for: .touchUpInside)
        
        view.addSubview(tabSettingsBtn)
        NSLayoutConstraint.activate([
            tabSettingsBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabSettingsBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tabSettingsBtn.widthAnchor.constraint(equalToConstant: 44),
            tabSettingsBtn.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func openTabSettings() {
        triggerHaptic(style: .medium)
        let vc = TabSettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func setupStrings() {
        super.setupStrings()
        handler.didLoad()
        linkDeviceLabel.text = L10n.Screen.LinkDevice.title
        historyTitleLabel.text = L10n.Screen.Feed.history
        teamTitleLabel.text = L10n.Screen.Other.team
        donateTitleLabel.text = L10n.Screen.Other.donate
        settingsTitleLabel.text = L10n.Screen.Settings.title
    }

    // MARK: - Actions

    @IBAction func loginLogOutAction(_ sender: Any) {
        triggerHaptic(style: .light)
        self.handler.loginOrLogout()
    }

    @IBAction func historyAction(_ sender: Any) {
        triggerHaptic(style: .light)
        self.handler.history()
    }

    @IBAction func teamAction(_ sender: Any) {
        triggerHaptic(style: .light)
        self.handler.team()
    }

    @IBAction func donateAction(_ sender: Any) {
        triggerHaptic(style: .light)
        self.handler.donate()
    }

    @IBAction func settingsAction(_ sender: Any) {
        triggerHaptic(style: .light)
        self.handler.settings()
    }

    @IBAction func linkDeviceAction(_ sender: Any) {
        triggerHaptic(style: .light)
        self.handler.linkDevice()
    }
}

extension OtherViewController: OtherViewBehavior {
    func set(user: User?, loading: Bool) {
        self.userNameLabel.isHidden = loading
        self.authButton.isHidden = loading
        self.userNameLabel.text = user?.name ?? L10n.Common.guest
        if user == nil {
            self.authButton.setTitle(L10n.Buttons.signIn, for: .normal)
            self.linkDeviceView.isHidden = true
        } else {
            self.authButton.setTitle(L10n.Buttons.signOut, for: .normal)
            self.linkDeviceView.isHidden = false
        }
    }

    func set(links: [LinkData]) {
        let views = links.lazy.compactMap { item -> LinkView? in
            let view = LinkView.fromNib()
            view?.configure(item)
            view?.setTap { [weak self] in
                self?.handler.tap(link: $0)
            }
            return view
        }
        self.linksStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        for view in views {
            self.linksStackView.addArrangedSubview(view)
        }
    }
}

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
