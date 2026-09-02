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

    private var subscribers = Set<AnyCancellable>()

    func configure(item: SettingsControlItem) {
        titleLabel.text = item.title
        setupIcon(for: item.title)

        item.$value
            .sink { [weak self] value in
                self?.valueLabel.text = value
            }
            .store(in: &subscribers)
        
        button.publisher(for: .touchUpInside).sink {
            item.select()
        }.store(in: &subscribers)
    }

    private func setupIcon(for title: String) {
        let symbolName: String
        let tint: UIColor

        if title == L10n.Screen.Settings.language {
            symbolName = "globe"
            tint = .systemBlue
        } else if title == L10n.Common.appearance {
            symbolName = "circle.lefthalf.filled"
            tint = .systemIndigo
        } else if title == L10n.Common.orientation {
            symbolName = "iphone"
            tint = .systemOrange
        } else if title == L10n.Screen.Settings.videoQuality {
            symbolName = "tv"
            tint = .systemPurple
        } else if title == L10n.Common.playbackRate {
            symbolName = "gauge.with.dots.needle.bottom.50percent"
            tint = .systemGreen
        } else if title == L10n.Common.skipCredits {
            symbolName = "forward.fill"
            tint = .systemTeal
        } else if title == L10n.Common.autoPlayLong {
            symbolName = "play.circle.fill"
            tint = .systemPink
        } else if title == L10n.Common.playOnStartup {
            symbolName = "play.rectangle.fill"
            tint = .systemRed
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
    private let action: ((SettingsControlItem) -> Void)

    init(
        title: String,
        value: String,
        action: @escaping (SettingsControlItem) -> Void
    ) {
        self.title = title
        self.value = value
        self.action = action
    }

    func select() {
        action(self)
    }
}
