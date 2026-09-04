import DITranquillity
import Combine
import Foundation

final class ConfigRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(ConfigRepositoryImp.init)
            .as(ConfigRepository.self)
            .lifetime(.single)
    }
}

protocol ConfigRepository {
    func set(config: AniConfigInfo)
    func getConfig() -> AniConfigInfo
}

final class ConfigRepositoryImp: ConfigRepository {
    private let keyConfig: String = "ANI_CONFIG_INFO_KEY_V2"

    func set(config: AniConfigInfo) {
        UserDefaults.standard[keyConfig] = config
    }

    func getConfig() -> AniConfigInfo {
        if let saved: AniConfigInfo = UserDefaults.standard[keyConfig], !saved.items.isEmpty {
            return saved
        }
        let defaultConfig = AniConfigInfo(config: .default)
        UserDefaults.standard[keyConfig] = defaultConfig
        return defaultConfig
    }
}
