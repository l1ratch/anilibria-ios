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

    private let avatarContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.Tint.active.withAlphaComponent(0.12)
        view.layer.cornerRadius = 19
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()

    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .Tint.active
        label.textAlignment = .center
        return label
    }()

    public override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .Surfaces.content
        contentView.layer.cornerRadius = 14
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor
        contentView.clipsToBounds = true

        contentView.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarLabel)

        NSLayoutConstraint.activate([
            avatarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            avatarContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 38),
            avatarContainer.heightAnchor.constraint(equalToConstant: 38),

            avatarLabel.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
            avatarLabel.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor),
            avatarLabel.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),
            avatarLabel.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor)
        ])

        if let leadingConstraint = constraints.first(where: { $0.firstAttribute == .leading && ($0.firstItem as? UIStackView) != nil }) {
            leadingConstraint.constant = 64
        }

        internView.titleLabel.text = L10n.Common.intern
        vacationView.titleLabel.text = L10n.Common.vacation
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

        let initial = item.name.prefix(1).uppercased()
        self.avatarLabel.text = initial.isEmpty ? "?" : initial

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
