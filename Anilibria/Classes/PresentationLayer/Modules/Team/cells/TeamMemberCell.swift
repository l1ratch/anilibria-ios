//
//  TeamMemberCell.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

public final class TeamTagView: UIView {
    @IBOutlet var titleLabel: UILabel!

    public override func layoutSubviews() {
        super.layoutSubviews()
        smoothCorners(with: bounds.height / 2)
    }
}

public final class TeamMemberCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var internView: TeamTagView!
    @IBOutlet var vacationView: TeamTagView!

    public override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .Surfaces.content
        contentView.layer.cornerRadius = 14
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        contentView.applyAdaptiveBorder()

        internView.titleLabel.text = L10n.Common.intern
        vacationView.titleLabel.text = L10n.Common.vacation
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        contentView.applyAdaptiveBorder()
    }

    func configure(_ item: TeamMember) {
        self.titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        self.titleLabel.textColor = .Text.main
        self.titleLabel.text = item.name

        let rolesText = item.roles.lazy
            .sorted(by: { $0.sortOrder < $1.sortOrder })
            .compactMap { $0.title }
            .joined(separator: ", ")

        self.subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        self.subtitleLabel.textColor = .Text.secondary
        self.subtitleLabel.text = rolesText

        self.internView.isHidden = !item.isIntern
        self.internView.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.85)
        self.internView.titleLabel.textColor = .white
        self.internView.titleLabel.font = .systemFont(ofSize: 10, weight: .semibold)

        self.vacationView.isHidden = !item.isVacation
        self.vacationView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.85)
        self.vacationView.titleLabel.textColor = .white
        self.vacationView.titleLabel.font = .systemFont(ofSize: 10, weight: .semibold)
    }
}
