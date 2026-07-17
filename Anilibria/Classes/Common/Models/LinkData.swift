import UIKit

public enum LinkType: String, Codable {
    case vk
    case youtube
    case patreon
    case telegram
    case discord
    case boosty
    case site

    public var icon: UIImage {
        switch self {
        case .vk:
            return .iconVk
        case .youtube:
            return .iconYoutube
        case .patreon:
            return .iconPatreon
        case .telegram:
            return .iconTelegram
        case .discord:
            return .iconDiscord
        case .site:
            return .System.web
        case .boosty:
            return .iconBoosty
        }
    }
}

public struct LinkData: Codable, Hashable {
    let linkType: LinkType?
    let url: URL?

    public init(linkType: LinkType?, url: URL?) {
        self.linkType = linkType
        self.url = url
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.linkType = container.decode(.linkType)
        self.url = container.decode(.url)
    }
}

extension Optional where Wrapped == LinkType {
    var icon: UIImage {
        if let self {
            return self.icon
        }
        return .iconAnilibria
    }
}
