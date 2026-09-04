//
//  SettingsControlView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 16.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class SettingsControlView: LoadableView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var button: UIButton!
    @IBOutlet private var iconImageView: UIImageView?
    @IBOutlet private var chevronImageView: UIImageView?
    @IBOutlet private var titleToValueConstraint: NSLayoutConstraint?

    private lazy var toggleSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = .Tint.active
        sw.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
        sw.setContentCompressionResistancePriority(.required, for: .horizontal)
        sw.setContentHuggingPriority(.required, for: .horizontal)
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.addTarget(self, action: #selector(onSwitchChanged(_:)), for: .valueChanged)
        return sw
    }()

    private var subscribers = Set<AnyCancellable>()
    private var currentItem: SettingsControlItem?
    private var titleSwitchConstraint: NSLayoutConstraint?

    func configure(item: SettingsControlItem) {
        subscribers.removeAll()
        currentItem = item
        titleLabel.text = item.title

        if let iconName = item.iconName {
            let tint = item.iconTint ?? .Tint.active
            let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
            iconImageView?.image = UIImage(systemName: iconName, withConfiguration: config)
            iconImageView?.tintColor = tint
        } else {
            setupIcon(for: item.title)
        }

        if item.isToggle {
            chevronImageView?.isHidden = true
            valueLabel.isHidden = true
            titleToValueConstraint?.isActive = false

            titleLabel.setContentCompressionResistancePriority(UILayoutPriority(250), for: .horizontal)
            titleLabel.setContentHuggingPriority(UILayoutPriority(250), for: .horizontal)
            titleLabel.numberOfLines = 0

            let container = self.view ?? self
            if toggleSwitch.superview == nil {
                container.addSubview(toggleSwitch)
                container.bringSubviewToFront(toggleSwitch)
                let trailingCst = toggleSwitch.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
                trailingCst.priority = .required
                NSLayoutConstraint.activate([
                    toggleSwitch.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                    trailingCst
                ])
            }
            if titleSwitchConstraint == nil {
                titleSwitchConstraint = titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggleSwitch.leadingAnchor, constant: -12)
                titleSwitchConstraint?.priority = UILayoutPriority(999)
            }
            titleSwitchConstraint?.isActive = true
            toggleSwitch.isHidden = false
            toggleSwitch.setOn(item.isOn, animated: false)

            item.$isOn
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isOn in
                    if self?.toggleSwitch.isOn != isOn {
                        self?.toggleSwitch.setOn(isOn, animated: true)
                    }
                }
                .store(in: &subscribers)

            button.publisher(for: .touchUpInside).sink { [weak self] in
                guard let self = self else { return }
                self.toggleSwitch.setOn(!self.toggleSwitch.isOn, animated: true)
                self.onSwitchChanged(self.toggleSwitch)
            }.store(in: &subscribers)
        } else {
            toggleSwitch.isHidden = true
            titleSwitchConstraint?.isActive = false
            titleToValueConstraint?.isActive = true
            chevronImageView?.isHidden = false
            valueLabel.isHidden = false

            titleLabel.setContentCompressionResistancePriority(UILayoutPriority(750), for: .horizontal)
            titleLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)

            item.$value
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    self?.valueLabel.text = value
                }
                .store(in: &subscribers)

            button.publisher(for: .touchUpInside).sink {
                item.select()
            }.store(in: &subscribers)
        }
    }

    @objc private func onSwitchChanged(_ sender: UISwitch) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        currentItem?.isOn = sender.isOn
        currentItem?.onToggle?(sender.isOn)
    }

    private func setupIcon(for title: String) {
        let lower = title.lowercased()
        let symbolName: String
        let tint: UIColor

        if title == L10n.Screen.Settings.language || lower.contains("язык") || lower.contains("language") {
            symbolName = "globe"
            tint = .systemBlue
        } else if title == L10n.Common.appearance || lower.contains("оформлен") || lower.contains("appearance") || lower.contains("тема") {
            symbolName = "circle.lefthalf.filled"
            tint = .systemIndigo
        } else if title == L10n.Common.orientation || lower.contains("ориентац") || lower.contains("orientation") {
            symbolName = "iphone"
            tint = .systemOrange
        } else if title == L10n.Screen.Settings.videoQuality || lower.contains("качеств") || lower.contains("quality") {
            symbolName = "tv"
            tint = .systemPurple
        } else if title == L10n.Common.playbackRate || lower.contains("скорост") || lower.contains("playback rate") || lower.contains("speed") {
            symbolName = "gauge.with.dots.needle.bottom.50percent"
            tint = .systemGreen
        } else if title == L10n.Common.skipCredits || lower.contains("пропуск") || lower.contains("skip") {
            symbolName = "forward.fill"
            tint = .systemTeal
        } else if title == L10n.Common.autoPlayLong || lower.contains("автовоспроизвед") || lower.contains("autoplay") || lower.contains("автопереход") {
            symbolName = "play.circle.fill"
            tint = .systemPink
        } else if title == L10n.Common.playOnStartup || lower.contains("при запуск") || lower.contains("startup") {
            symbolName = "play.rectangle.fill"
            tint = .systemRed
        } else if lower.contains("новост") || lower.contains("news") || lower.contains("баннер") {
            symbolName = "newspaper.fill"
            tint = .systemOrange
        } else if lower.contains("расписан") || lower.contains("schedule") {
            symbolName = "calendar"
            tint = .systemTeal
        } else if lower.contains("док") || lower.contains("dock") || lower.contains("панел") {
            symbolName = "dock.rectangle"
            tint = .systemPurple
        } else if lower.contains("списк") || lower.contains("коллекц") || lower.contains("list") || lower.contains("collection") {
            symbolName = "list.bullet.rectangle.portrait"
            tint = .systemTeal
        } else if lower.contains("истор") || lower.contains("history") {
            symbolName = "clock.arrow.circlepath"
            tint = .systemIndigo
        } else {
            symbolName = "gearshape.fill"
            tint = .Tint.active
        }

        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        iconImageView?.image = UIImage(systemName: symbolName, withConfiguration: config)
        iconImageView?.tintColor = tint
    }
}

public final class SettingsControlItem {
    let title: String
    @Published var value: String
    let iconName: String?
    let iconTint: UIColor?
    let isToggle: Bool
    @Published var isOn: Bool
    var onToggle: ((Bool) -> Void)?
    private let action: ((SettingsControlItem) -> Void)?

    init(
        title: String,
        value: String,
        iconName: String? = nil,
        iconTint: UIColor? = nil,
        action: @escaping (SettingsControlItem) -> Void
    ) {
        self.title = title
        self.value = value
        self.iconName = iconName
        self.iconTint = iconTint
        self.isToggle = false
        self.isOn = false
        self.onToggle = nil
        self.action = action
    }

    init(
        title: String,
        isOn: Bool,
        iconName: String? = nil,
        iconTint: UIColor? = nil,
        onToggle: @escaping (Bool) -> Void
    ) {
        self.title = title
        self.value = ""
        self.iconName = iconName
        self.iconTint = iconTint
        self.isToggle = true
        self.isOn = isOn
        self.onToggle = onToggle
        self.action = nil
    }

    func select() {
        action?(self)
    }
}
