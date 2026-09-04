//
//  HistorySettingsViewController.swift
//  Anilibria
//
//  Created by Antigravity on 04.09.2026.
//

import UIKit

final class HistorySettingsViewController: BaseViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let promoSwitch = UISwitch()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Language.isEnglish ? "History Settings" : "Настройки истории"
        setupTableView()
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

        let isPromoEnabled = UserDefaults.standard.object(forKey: "showEmptyHistoryPromo") as? Bool ?? true
        promoSwitch.isOn = isPromoEnabled
        promoSwitch.onTintColor = UIColor(named: "buttons/selected") ?? .systemRed
        promoSwitch.addTarget(self, action: #selector(promoSwitchChanged(_:)), for: .valueChanged)
    }

    @objc private func promoSwitchChanged(_ sender: UISwitch) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UserDefaults.standard.set(sender.isOn, forKey: "showEmptyHistoryPromo")
        NotificationCenter.default.post(name: NSNotification.Name("feedSettingsChanged"), object: nil)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension HistorySettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.backgroundColor = .Surfaces.content
        cell.selectionStyle = .none

        cell.textLabel?.text = Language.isEnglish ? "Catalog prompt in feed" : "Подсказка в ленте"
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        cell.textLabel?.textColor = .Text.main

        cell.accessoryView = promoSwitch
        return cell
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return Language.isEnglish
            ? "When watch history is empty, a friendly card is displayed in the Continue Watching section offering to explore the catalog."
            : "Если история просмотров пуста, в блоке «Продолжить просмотр» на главной отображается карточка с предложением выбрать тайтл из каталога."
    }
}
