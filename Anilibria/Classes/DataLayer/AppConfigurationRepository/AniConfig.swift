import Foundation

struct AniConfig: Codable, Hashable {
    let addresses: [AniAddress]
    let urls: AniLinks?

    init(
        addresses: [AniAddress],
        urls: AniLinks? = nil
    ) {
        self.addresses = addresses
        self.urls = urls
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.addresses = try container.decode(required: .addresses)
        self.urls = container.decode(.urls)
    }
}

struct AniAddress: Codable, Hashable {
    let baseUrl: URL
    let baseImagesUrl: URL
}

struct AniLinks: Codable, Hashable {
    let donateUrl: URL
    let signUpUrl: URL
    let links: [LinkData]
}

extension AniConfig {
    static var `default`: AniConfig = {
        let url = URL(string: "https://www.anilibria.top")!
        let donateUrl = URL(string: "https://anilibria.top/support")!
        let signUpUrl = URL(string: "https://anilibria.top/app/auth/registration/newRegistration")!
        let defaultLinks: [LinkData] = [
            LinkData(linkType: .telegram, url: URL(string: "https://t.me/anilibria")),
            LinkData(linkType: .discord, url: URL(string: "https://discord.gg/M6yCGeGN9B")),
            LinkData(linkType: .vk, url: URL(string: "https://vk.com/anilibria")),
            LinkData(linkType: .youtube, url: URL(string: "https://www.youtube.com/user/anilibriatv")),
            LinkData(linkType: .patreon, url: URL(string: "https://www.patreon.com/anilibria")),
            LinkData(linkType: .boosty, url: URL(string: "https://boosty.to/anilibriatv"))
        ]
        return AniConfig(
            addresses: [
                AniAddress(
                    baseUrl: url,
                    baseImagesUrl: url
                )
            ],
            urls: AniLinks(
                donateUrl: donateUrl,
                signUpUrl: signUpUrl,
                links: defaultLinks
            )
        )
    }()
}

struct AniConfigInfo: Codable {
    struct Item: Codable, Hashable {
        var address: AniAddress
        var priority: Int
    }

    private(set) var config: AniConfig?
    private(set) var updatedAt: Date?

    var items: Set<Item> = []

    mutating func update(with new: AniConfig) {
        if config != new {
            set(config: new)
        }
        updatedAt = Date()
    }

    private mutating func set(config: AniConfig) {
        self.config = config
        var count = config.addresses.count
        self.items = Set(config.addresses.map {
            defer { count -= 1 }
            return Item(address: $0, priority: count)
        })
    }

    var isOutdated: Bool {
        guard let updatedAt else { return true }
        return Date().timeIntervalSince(updatedAt) > Self.cacheDuration
    }

    func topPriorityItem() -> Item? {
        items.sorted(by: { $0.priority > $1.priority }).first
    }
}

extension AniConfigInfo {
    static let cacheDuration: TimeInterval = 60 * 60
}
