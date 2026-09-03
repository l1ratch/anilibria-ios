//
//  UserCollectionsEditorViewController.swift
//  Anilibria
//
//  Created by Antigravity on 03.09.2026.
//

import UIKit

final class UserCollectionEditorCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        backgroundColor = .Surfaces.content
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

final class UserCollectionsEditorViewController: BaseViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var activeItems: [UserCollectionKey] = []
    private var hiddenItems: [UserCollectionKey] = []

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Language.isEnglish ? "Lists Settings" : "Настройка списков"
        setupNavigation()
        setupTableView()
        loadData()
    }

    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Language.isEnglish ? "Reset" : "Сбросить",
            style: .plain,
            target: self,
            action: #selector(resetToDefaults)
        )
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = false
        tableView.alwaysBounceVertical = false
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .Surfaces.background
        tableView.register(UserCollectionEditorCell.self, forCellReuseIdentifier: "UserCollectionEditorCell")
    }

    private func loadData() {
        activeItems = UserCollectionsPreferences.getActiveKeys()
        hiddenItems = UserCollectionsPreferences.getHiddenKeys()
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || navigationController == nil {
            NotificationCenter.default.post(name: UserCollectionsPreferences.notificationName, object: nil)
        }
    }

    @objc private func resetToDefaults() {
        let alert = UIAlertController(
            title: Language.isEnglish ? "Reset Lists" : "Сброс списков",
            message: Language.isEnglish ? "Reset lists order and visibility to defaults?" : "Вернуть расположение и список категорий по умолчанию?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Language.isEnglish ? "Cancel" : "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: Language.isEnglish ? "Reset" : "Сбросить", style: .destructive) { [weak self] _ in
            UserCollectionsPreferences.resetToDefaults(notify: false)
            self?.loadData()
        })
        present(alert, animated: true)
    }

    private func saveChanges() {
        UserCollectionsPreferences.setActiveKeys(activeItems, notify: false)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension UserCollectionsEditorViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return hiddenItems.isEmpty ? 1 : 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return activeItems.count
        } else {
            return hiddenItems.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Language.isEnglish ? "Active Lists" : "Активные списки"
        } else {
            return Language.isEnglish ? "Hidden Lists" : "Скрытые списки"
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return Language.isEnglish
                ? "Drag handles on the right to reorder. At least one list must remain active."
                : "Перетаскивайте списки за правый край для изменения порядка. Минимум один список должен оставаться активным."
        }
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCollectionEditorCell", for: indexPath)
        cell.backgroundColor = .Surfaces.content
        cell.selectionStyle = .none

        let item: UserCollectionKey

        if indexPath.section == 0 {
            item = activeItems[indexPath.row]
            cell.textLabel?.text = item.title
            cell.textLabel?.textColor = .Text.main
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            cell.imageView?.image = item.icon
            cell.imageView?.tintColor = .Tint.active

            if activeItems.count <= 1 {
                cell.detailTextLabel?.text = Language.isEnglish ? "Required" : "Обязательный"
                cell.detailTextLabel?.textColor = .Text.secondary
                cell.detailTextLabel?.font = .systemFont(ofSize: 13, weight: .regular)
            } else {
                cell.detailTextLabel?.text = nil
            }
        } else {
            item = hiddenItems[indexPath.row]
            cell.textLabel?.text = item.title
            cell.textLabel?.textColor = .Text.secondary
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            cell.imageView?.image = item.icon
            cell.imageView?.tintColor = .Text.secondary
            cell.detailTextLabel?.text = nil
        }

        return cell
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == 0 {
            return activeItems.count <= 1 ? .none : .delete
        } else {
            return .insert
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == 0 {
            guard activeItems.count > 1 else { return }

            let item = activeItems.remove(at: indexPath.row)
            hiddenItems.append(item)
            saveChanges()

            tableView.reloadData()
        } else if editingStyle == .insert && indexPath.section == 1 {
            let item = hiddenItems.remove(at: indexPath.row)
            activeItems.append(item)

            saveChanges()
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath.section == 0, destinationIndexPath.section == 0 else { return }
        let movedItem = activeItems.remove(at: sourceIndexPath.row)
        activeItems.insert(movedItem, at: destinationIndexPath.row)
        saveChanges()
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section != 0 {
            return IndexPath(row: activeItems.count - 1, section: 0)
        }
        return proposedDestinationIndexPath
    }
}
