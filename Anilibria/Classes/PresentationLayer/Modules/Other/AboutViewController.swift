//
//  AboutViewController.swift
//  Anilibria
//
//  Created by Antigravity on 05.09.2026.
//

import UIKit

final class AboutViewController: BaseViewController {

    private struct AboutItem {
        let title: String
        let subtitle: String?
        let iconName: String
        let iconColor: UIColor
        let url: URL?
    }

    private struct AboutSection {
        let header: String?
        let items: [AboutItem]
        let footer: String?
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var sections: [AboutSection] = []

    // MARK: - Life cycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Language.isEnglish ? "About" : "О программе"
        setupSections()
        setupTableView()
        setupHeaderView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup

    private func setupSections() {
        let isEn = Language.isEnglish

        let devSection = AboutSection(
            header: isEn ? "Development & Authors" : "Разработка и авторы",
            items: [
                AboutItem(
                    title: isEn ? "Redesign & Improvements v3.0.0" : "Редизайн и улучшения v3.0.0",
                    subtitle: "l1ratch",
                    iconName: "sparkles",
                    iconColor: UIColor(named: "buttons/selected") ?? .systemRed,
                    url: URL(string: "https://github.com/l1ratch/anilibria-ios")
                ),
                AboutItem(
                    title: isEn ? "Creator & Lead Developer" : "Создатель и ведущий разработчик",
                    subtitle: isEn ? "Ivan Morozov (@Allui)" : "Иван Морозов (@Allui)",
                    iconName: "person.fill",
                    iconColor: .systemBlue,
                    url: URL(string: "https://github.com/Allui")
                ),
                AboutItem(
                    title: isEn ? "Contributor" : "Контрибьютор",
                    subtitle: "teanet (@teanet)",
                    iconName: "person.2.fill",
                    iconColor: .systemTeal,
                    url: URL(string: "https://github.com/teanet")
                )
            ],
            footer: nil
        )

        let linksSection = AboutSection(
            header: isEn ? "Links" : "Ссылки",
            items: [
                AboutItem(
                    title: isEn ? "Fork Repository" : "Репозиторий модификации (GitHub)",
                    subtitle: "github.com/l1ratch/anilibria-ios",
                    iconName: "chevron.left.forwardslash.chevron.right",
                    iconColor: .systemPurple,
                    url: URL(string: "https://github.com/l1ratch/anilibria-ios")
                ),
                AboutItem(
                    title: isEn ? "Original Repository" : "Оригинальный репозиторий (GitHub)",
                    subtitle: "github.com/anilibria/anilibria-ios",
                    iconName: "folder.fill",
                    iconColor: .systemOrange,
                    url: URL(string: "https://github.com/anilibria/anilibria-ios")
                ),
                AboutItem(
                    title: isEn ? "Official Website" : "Официальный сайт AniLibria",
                    subtitle: "anilibria.top",
                    iconName: "globe",
                    iconColor: .systemGreen,
                    url: URL(string: "https://anilibria.top")
                )
            ],
            footer: nil
        )

        sections = [devSection, linksSection]
    }

    private func setupTableView() {
        view.backgroundColor = .Surfaces.background
        tableView.backgroundColor = .Surfaces.background
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 180))

        // App Icon
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 18
        iconImageView.layer.cornerCurve = .continuous
        iconImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        iconImageView.layer.borderWidth = 1

        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last,
           let iconImage = UIImage(named: lastIcon) {
            iconImageView.image = iconImage
        } else if let brandImage = UIImage(named: "icon_anilibria") {
            iconImageView.image = brandImage
        }

        // App Name Label
        let nameLabel = UILabel()
        nameLabel.text = Bundle.main.displayName ?? "AniLiberty"
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .Text.main
        nameLabel.textAlignment = .center

        // Version & Build Label
        let versionString = Bundle.main.releaseVersionNumber ?? "3.0.0"
        let buildString = Bundle.main.buildVersionNumber ?? "102"
        let versionLabel = UILabel()
        versionLabel.text = Language.isEnglish
            ? "Version \(versionString) (Build \(buildString))"
            : "Версия \(versionString) (Сборка \(buildString))"
        versionLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        versionLabel.textColor = .Text.secondary
        versionLabel.textAlignment = .center

        // Subtitle / Tagline
        let subtitleLabel = UILabel()
        subtitleLabel.text = Language.isEnglish
            ? "AniLibria Client for iOS"
            : "Клиент AniLibria для iOS"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = UIColor(named: "buttons/selected") ?? .systemRed
        subtitleLabel.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [iconImageView, nameLabel, versionLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 6
        stackView.setCustomSpacing(10, after: iconImageView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 72),
            iconImageView.heightAnchor.constraint(equalToConstant: 72),
            stackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])

        headerView.layoutIfNeeded()
        let fittingSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        headerView.frame.size.height = fittingSize.height
        tableView.tableHeaderView = headerView
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension AboutViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = .Surfaces.content
        cell.selectionStyle = item.url != nil ? .default : .none

        // Title
        cell.textLabel?.text = item.title
        cell.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        cell.textLabel?.textColor = .Text.main

        // Subtitle
        cell.detailTextLabel?.text = item.subtitle
        cell.detailTextLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        cell.detailTextLabel?.textColor = .Text.secondary

        // Icon
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let iconImage = UIImage(systemName: item.iconName, withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.image = iconImage
        cell.imageView?.tintColor = item.iconColor

        // Accessory
        if item.url != nil {
            let arrowConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            let arrowImage = UIImage(systemName: "arrow.up.right", withConfiguration: arrowConfig)
            let accessoryImageView = UIImageView(image: arrowImage)
            accessoryImageView.tintColor = .Text.secondary
            cell.accessoryView = accessoryImageView
        } else {
            cell.accessoryView = nil
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].items[indexPath.row]
        guard let url = item.url else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
