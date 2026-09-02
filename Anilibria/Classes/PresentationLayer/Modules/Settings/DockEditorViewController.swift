//
//  DockEditorViewController.swift
//  Anilibria
//
//  Created by Antigravity on 02.09.2026.
//

import UIKit

final class DockCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        backgroundColor = .Surfaces.content
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

final class DockEditorViewController: BaseViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var activeItems: [MenuItemType] = []
    private var hiddenItems: [MenuItemType] = []

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройка Дока"
        setupNavigation()
        setupTableView()
        loadData()
    }

    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Сбросить",
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
        tableView.backgroundColor = .Surfaces.background
        tableView.register(DockCell.self, forCellReuseIdentifier: "DockCell")
    }

    private func loadData() {
        activeItems = MenuItemsFactory.getActiveTypes()
        hiddenItems = MenuItemsFactory.getHiddenTypes()
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("dockItemsChanged"), object: nil)
    }

    @objc private func resetToDefaults() {
        let alert = UIAlertController(
            title: "Сброс панели",
            message: "Вернуть расположение и список кнопок в доке по умолчанию?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Сбросить", style: .destructive) { [weak self] _ in
            MenuItemsFactory.setActiveTypes(MenuItemsFactory.defaultActiveTypes, notify: false)
            self?.loadData()
        })
        present(alert, animated: true)
    }

    private func saveChanges() {
        MenuItemsFactory.setActiveTypes(activeItems, notify: false)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension DockEditorViewController: UITableViewDataSource, UITableViewDelegate {
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
            return "Активные кнопки в доке"
        } else {
            return "Скрытые кнопки"
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Перетаскивайте кнопки за правый край для изменения порядка. Кнопку «Другое» скрыть нельзя."
        }
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DockCell", for: indexPath)
        cell.backgroundColor = .Surfaces.content
        cell.selectionStyle = .none

        let item: MenuItemType

        if indexPath.section == 0 {
            item = activeItems[indexPath.row]
            cell.textLabel?.text = item.title
            cell.textLabel?.textColor = .Text.main
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            cell.imageView?.image = item.icon
            cell.imageView?.tintColor = .Tint.active

            if item == .other {
                cell.detailTextLabel?.text = "Обязательная"
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
            let item = activeItems[indexPath.row]
            return item == .other ? .none : .delete
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
            let item = activeItems[indexPath.row]
            guard item != .other else { return }

            activeItems.remove(at: indexPath.row)
            hiddenItems.append(item)
            saveChanges()

            tableView.reloadData()
        } else if editingStyle == .insert && indexPath.section == 1 {
            let item = hiddenItems[indexPath.row]
            hiddenItems.remove(at: indexPath.row)

            // Insert before .other if .other is last, or at the end
            if let otherIndex = activeItems.firstIndex(of: .other) {
                activeItems.insert(item, at: otherIndex)
            } else {
                activeItems.append(item)
            }

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
