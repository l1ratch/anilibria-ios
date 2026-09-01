import UIKit

// MARK: - View Controller (Native Inset Grouped TableView)

final class OtherViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var handler: OtherEventHandler!

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var currentUser: User?
    private var links: [LinkData] = []
    private var isLoadingUser: Bool = false

    override var isNavigationBarVisible: Bool { true }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        view.backgroundColor = .Surfaces.background
        
        setupTableView()
        handler.didLoad()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StandardCell")
        tableView.register(ProfileTableCell.self, forCellReuseIdentifier: "ProfileCell")
        tableView.register(SocialLinksTableCell.self, forCellReuseIdentifier: "SocialCell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - TableView DataSource & Delegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            // Link Device (if user), History, Team, Donate
            return (currentUser != nil ? 1 : 0) + 3
        case 2:
            // Settings, Settings +
            return 2
        case 3:
            return links.isEmpty ? 0 : 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "РАЗДЕЛЫ"
        case 2: return "НАСТРОЙКИ"
        case 3: return "СООБЩЕСТВО"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileTableCell else {
                return UITableViewCell()
            }
            cell.configure(user: currentUser, loading: isLoadingUser) { [weak self] in
                self?.triggerHaptic(style: .light)
                self?.handler.loginOrLogout()
            }
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StandardCell", for: indexPath)
            cell.backgroundColor = .Surfaces.content
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = .Text.main
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)

            var rowOffset = indexPath.row
            if currentUser != nil {
                if rowOffset == 0 {
                    cell.textLabel?.text = L10n.Screen.LinkDevice.title
                    cell.imageView?.image = UIImage(systemName: "link")
                    cell.imageView?.tintColor = .Tint.active
                    return cell
                }
                rowOffset -= 1
            }

            switch rowOffset {
            case 0:
                cell.textLabel?.text = L10n.Screen.Feed.history
                cell.imageView?.image = UIImage(systemName: "clock.arrow.circlepath")
                cell.imageView?.tintColor = .Tint.active
            case 1:
                cell.textLabel?.text = L10n.Screen.Other.team
                cell.imageView?.image = UIImage(systemName: "person.3.fill")
                cell.imageView?.tintColor = .Tint.active
            case 2:
                cell.textLabel?.text = L10n.Screen.Other.donate
                cell.imageView?.image = UIImage(systemName: "heart.fill")
                cell.imageView?.tintColor = .Tint.active
            default:
                break
            }
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StandardCell", for: indexPath)
            cell.backgroundColor = .Surfaces.content
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = .Text.main
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)

            if indexPath.row == 0 {
                cell.textLabel?.text = L10n.Screen.Settings.title
                cell.imageView?.image = UIImage(systemName: "gearshape.fill")
                cell.imageView?.tintColor = .Tint.active
            } else {
                cell.textLabel?.text = "Настройки +"
                cell.imageView?.image = UIImage(systemName: "slider.horizontal.3")
                cell.imageView?.tintColor = .Tint.active
            }
            return cell

        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SocialCell", for: indexPath) as? SocialLinksTableCell else {
                return UITableViewCell()
            }
            cell.configure(links: self.links) { [weak self] link in
                self?.triggerHaptic(style: .light)
                self?.handler.tap(link: link)
            }
            return cell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        triggerHaptic(style: .light)

        switch indexPath.section {
        case 0:
            handler.loginOrLogout()

        case 1:
            var rowOffset = indexPath.row
            if currentUser != nil {
                if rowOffset == 0 {
                    handler.linkDevice()
                    return
                }
                rowOffset -= 1
            }

            switch rowOffset {
            case 0: handler.history()
            case 1: handler.team()
            case 2: handler.donate()
            default: break
            }

        case 2:
            if indexPath.row == 0 {
                handler.settings()
            } else {
                let vc = SettingsPlusViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }

        default:
            break
        }
    }
}

extension OtherViewController: OtherViewBehavior {
    func set(user: User?, loading: Bool) {
        self.currentUser = user
        self.isLoadingUser = loading
        self.tableView.reloadData()
    }

    func set(links: [LinkData]) {
        self.links = links
        self.tableView.reloadData()
    }
}

// MARK: - Profile Table Cell

final class ProfileTableCell: UITableViewCell {
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let authButton = UIButton(type: .system)
    private var authAction: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .Surfaces.content
        selectionStyle = .none

        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = .Tint.active
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .Text.main
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        authButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        authButton.layer.cornerRadius = 14
        authButton.layer.cornerCurve = .continuous
        authButton.backgroundColor = UIColor.Tint.active.withAlphaComponent(0.12)
        authButton.setTitleColor(.Tint.active, for: .normal)
        authButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        authButton.translatesAutoresizingMaskIntoConstraints = false
        authButton.addTarget(self, action: #selector(didTapAuth), for: .touchUpInside)

        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(authButton)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 14),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: authButton.leadingAnchor, constant: -12),

            authButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            authButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            authButton.heightAnchor.constraint(equalToConstant: 32),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])
    }

    @objc private func didTapAuth() {
        authAction?()
    }

    func configure(user: User?, loading: Bool, onAuthTap: @escaping () -> Void) {
        self.authAction = onAuthTap
        self.nameLabel.text = loading ? "Загрузка..." : (user?.name ?? L10n.Common.guest)
        let buttonTitle = user == nil ? L10n.Buttons.signIn : L10n.Buttons.signOut
        self.authButton.setTitle(buttonTitle, for: .normal)
    }
}

// MARK: - Social Links Table Cell

final class SocialLinksTableCell: UITableViewCell {
    private let stackView = UIStackView()
    private var onLinkTap: ((LinkData) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .Surfaces.content
        selectionStyle = .none

        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(links: [LinkData], onLinkTap: @escaping (LinkData) -> Void) {
        self.onLinkTap = onLinkTap
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for link in links {
            let button = UIButton(type: .system)
            button.setImage(link.linkType.icon?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tintColor = .Tint.active
            button.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
            button.layer.cornerRadius = 20
            button.layer.cornerCurve = .continuous
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            button.addAction(UIAction(handler: { [weak self] _ in
                self?.onLinkTap?(link)
            }), for: .touchUpInside)

            stackView.addArrangedSubview(button)
        }
    }
}

// MARK: - Settings Plus Hub Screen

final class SettingsPlusViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройки +"
        view.backgroundColor = .Surfaces.background
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlusCell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "НАВИГАЦИЯ И ИНТЕРФЕЙС"
        } else {
            return "ГЛАВНЫЙ ЭКРАН"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "PlusCell")
            cell.backgroundColor = .Surfaces.content
            cell.accessoryType = .disclosureIndicator
            
            let count = MenuSettingsManager.shared.getActiveTabs().count
            cell.textLabel?.text = "Настройка навигации"
            cell.textLabel?.textColor = .Text.main
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            
            cell.detailTextLabel?.text = "\(count) вкл."
            cell.detailTextLabel?.textColor = .Text.secondary
            cell.detailTextLabel?.font = .systemFont(ofSize: 14, weight: .regular)
            
            cell.imageView?.image = UIImage(systemName: "slider.horizontal.3")
            cell.imageView?.tintColor = .Tint.active
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SwitchCell")
            cell.backgroundColor = .Surfaces.content
            cell.selectionStyle = .none
            
            cell.textLabel?.text = "Скрывать промо-баннер"
            cell.textLabel?.textColor = .Text.main
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            
            cell.detailTextLabel?.text = "Скрыть блок новостей/промо в ленте"
            cell.detailTextLabel?.textColor = .Text.secondary
            cell.detailTextLabel?.font = .systemFont(ofSize: 12, weight: .regular)
            
            cell.imageView?.image = UIImage(systemName: "rectangle.badge.xmark")
            cell.imageView?.tintColor = .Tint.active
            
            let switchView = UISwitch()
            switchView.isOn = UserDefaults.standard.bool(forKey: "AniLiberty.HideFeedPromo")
            switchView.onTintColor = .Tint.active
            switchView.addTarget(self, action: #selector(toggleFeedPromo(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            return cell
        }
    }
    
    @objc private func toggleFeedPromo(_ sender: UISwitch) {
        triggerHaptic(style: .light)
        UserDefaults.standard.set(sender.isOn, forKey: "AniLiberty.HideFeedPromo")
        NotificationCenter.default.post(name: NSNotification.Name("FeedSettingsDidChange"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            triggerHaptic(style: .light)
            let vc = TabSettingsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Tab Settings Screen

final class TabSettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var activeTabs: [MenuItemType] = []
    private var inactiveTabs: [MenuItemType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройка навигации"
        view.backgroundColor = .Surfaces.background
        
        activeTabs = MenuSettingsManager.shared.getActiveTabs()
        inactiveTabs = MenuSettingsManager.shared.getInactiveTabs()
        
        setupTableView()
    }
    
    private func persistChanges() {
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
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
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
        return section == 0 ? "АКТИВНЫЕ ВКЛАДКИ ДОКА" : "СКРЫТЫЕ ВКЛАДКИ"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TabCell", for: indexPath)
        let type = indexPath.section == 0 ? activeTabs[indexPath.row] : inactiveTabs[indexPath.row]
        
        let title: String
        let iconName: String
        
        switch type {
        case .feed: title = "Главная"; iconName = "house.fill"
        case .catalog: title = "Релизы"; iconName = "play.rectangle.on.rectangle.fill"
        case .news: title = "Новости"; iconName = "newspaper.fill"
        case .collections: title = "Коллекции"; iconName = "square.stack.3d.up.fill"
        case .other: title = "Другое"; iconName = "ellipsis.circle.fill"
        }
        
        cell.textLabel?.text = title
        cell.textLabel?.textColor = .Text.main
        cell.imageView?.image = UIImage(systemName: iconName) ?? type.icon
        cell.imageView?.tintColor = .Tint.active
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
        
        persistChanges()
        
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
        persistChanges()
    }
}
