//
//  UserCollectionKey.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.06.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

enum UserCollectionKey: String, Hashable, Codable, CaseIterable {
    case favorite
    case planned
    case watching
    case postponed
    case watched
    case abandoned

    var collectionType: UserCollectionType? {
        switch self {
        case .favorite: return nil
        case .planned: return .planned
        case .watching: return .watching
        case .postponed: return .postponed
        case .watched: return .watched
        case .abandoned: return .abandoned
        }
    }

    var icon: UIImage {
        switch self {
        case .favorite: return .System.star
        case .planned: return .System.calendar
        case .watching: return .System.play
        case .postponed: return .System.pause
        case .watched: return .System.checkmark
        case .abandoned: return .System.xmark
        }
    }

    var title: String {
        collectionType?.localizedTitle ?? L10n.Common.Collections.favorites
    }
}

final class UserCollectionsPreferences {
    static let notificationName = NSNotification.Name("userCollectionsChanged")
    private static let storageKey = "userCollections_active_keys"

    static let defaultOrder: [UserCollectionKey] = [
        .favorite,
        .watching,
        .planned,
        .postponed,
        .abandoned,
        .watched
    ]

    static func getActiveKeys() -> [UserCollectionKey] {
        guard let rawValues = UserDefaults.standard.stringArray(forKey: storageKey) else {
            return defaultOrder
        }
        let keys = rawValues.compactMap { UserCollectionKey(rawValue: $0) }
        return keys.isEmpty ? defaultOrder : keys
    }

    static func getHiddenKeys() -> [UserCollectionKey] {
        let active = Set(getActiveKeys())
        return defaultOrder.filter { !active.contains($0) }
    }

    static func setActiveKeys(_ keys: [UserCollectionKey], notify: Bool = true) {
        let rawValues = keys.map { $0.rawValue }
        UserDefaults.standard.set(rawValues, forKey: storageKey)
        if notify {
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }

    static func resetToDefaults(notify: Bool = true) {
        UserDefaults.standard.removeObject(forKey: storageKey)
        if notify {
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }
}
