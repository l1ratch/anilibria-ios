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
        self.titleLabel.text = team.title
        if let desc = team.description, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.infoLabel.text = desc
            self.infoLabel.isHidden = false
        } else {
            self.infoLabel.text = nil
            self.infoLabel.isHidden = true
        }
    }
}
