//
//  TeamTitleView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

public final class TeamTitleView: UICollectionReusableView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!

    public override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .Text.main
        infoLabel.font = .systemFont(ofSize: 13, weight: .regular)
        infoLabel.textColor = .Text.secondary
    }

    func configure(_ team: TeamMember.Team) {
        let icon = iconFor(title: team.title)
        self.titleLabel.text = "\(icon) \(team.title)"
        if let desc = team.description, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.infoLabel.text = desc
            self.infoLabel.isHidden = false
        } else {
            self.infoLabel.text = nil
            self.infoLabel.isHidden = true
        }
    }

    private func iconFor(title: String) -> String {
        let lower = title.lowercased()
        if lower.contains("озвуч") || lower.contains("голос") { return "🎙️" }
        if lower.contains("тайм") || lower.contains("звук") || lower.contains("монтаж") { return "🎬" }
        if lower.contains("перевод") || lower.contains("саб") { return "📝" }
        if lower.contains("оформлен") || lower.contains("дизайн") { return "🎨" }
        if lower.contains("тех") || lower.contains("разработ") || lower.contains("it") { return "💻" }
        if lower.contains("руковод") || lower.contains("админ") { return "👑" }
        if lower.contains("пресс") || lower.contains("пиар") || lower.contains("smm") { return "📢" }
        return "👥"
    }
}
