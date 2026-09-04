import DITranquillity
import Kingfisher
import Combine
import Foundation

final class AppConfigurationRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(AppConfigurationRepositoryImp.init)
            .as(AppConfigurationRepository.self)
            .lifetime(.single)
    }
}

protocol AppConfigurationRepository: AnyObject {
    func fetchBaseImageUrl() -> AnyPublisher<URL, any Error>
    func fetchBaseUrl() -> AnyPublisher<URL, Error>
    func updateBaseUrl(_ baseUrl: URL?) -> AnyPublisher<URL, Error>

    func fetchLinks() -> AnyPublisher<AniLinks?, any Error>
}

final class AppConfigurationRepositoryImp: AppConfigurationRepository {
    private let provider: AniConfigProvider

    init(configRepository: ConfigRepository) {
        provider = AniConfigProvider(configRepository: configRepository)
    }

    func fetchBaseImageUrl() -> AnyPublisher<URL, any Error> {
        return AnyPublisher.create(asyncFunc: { [unowned self] in
            return await provider.baseImageUrl
        })
        .flatMap { [unowned self] url -> AnyPublisher<URL, any Error> in
            if let url {
                .just(url)
            } else {
                updateBaseUrl(nil)
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchBaseUrl() -> AnyPublisher<URL, any Error> {
        return AnyPublisher.create(asyncFunc: { [unowned self] in
            let value = await provider.baseUrl
            return value
        })
        .flatMap { [unowned self] url -> AnyPublisher<URL, any Error> in
            return if let url {
                .just(url)
            } else {
                updateBaseUrl(nil)
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func updateBaseUrl(_ baseUrl: URL?) -> AnyPublisher<URL, any Error> {
        AnyPublisher.create { [unowned self] in
            return try await provider.next(for: baseUrl)
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchLinks() -> AnyPublisher<AniLinks?, any Error> {
        AnyPublisher.create { [unowned self] in
            return await provider.getLinks()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

private actor AniConfigProvider {
    private var activeTask: Task<URL, Error>?
    private let configRepository: ConfigRepository

    private var currentConfigData: AniConfigInfo
    private var infoItem: AniConfigInfo.Item?

    private var isOutdated: Bool {
        currentConfigData.isOutdated
    }

    var baseUrl: URL? {
        infoItem?.address.baseUrl
    }

    var baseImageUrl: URL? {
        infoItem?.address.baseImagesUrl
    }

    init(configRepository: ConfigRepository) {
        self.configRepository = configRepository
        currentConfigData = configRepository.getConfig()
        infoItem = currentConfigData.topPriorityItem()
    }

    func next(for url: URL?) async throws -> URL {
        if let task = activeTask { return try await task.value }

        let task = Task { try await fetch(with: url) }
        activeTask = task
        defer { activeTask = nil }

        return try await task.value
    }

    func getLinks() async -> AniLinks? {
        if isOutdated {
            try? await update()
        }
        return currentConfigData.config?.urls ?? AniConfig.default.urls
    }

    private func fetch(with url: URL?) async throws -> URL {
        if let baseUrl, url != baseUrl {
            return baseUrl
        }
        // First try to rotate to alternative mirror immediately if we already have one
        if (try? extractAlternative()) == true, let url = baseUrl {
            if isOutdated {
                Task { [weak self] in
                    try? await self?.update()
                }
            }
            return url
        }
        if isOutdated {
            do {
                try await update()
            } catch {
                _ = try? extractAlternative()
            }
        } else {
            _ = try? extractAlternative()
        }
        if let url = baseUrl {
            return url
        }
        throw AppError.error(code: MRKitErrorCode.noBaseUrl)
    }

    private func update() async throws {
        var request = URLRequest(url: URLS.config)
        request.timeoutInterval = 3
        let (data, _) = try await URLSession.shared.data(for: request)
        let config = try JSONDecoder().decode(AniConfig.self, from: data)
        currentConfigData.update(with: config)
        configRepository.set(config: currentConfigData)
        infoItem = currentConfigData.topPriorityItem()
    }

    @discardableResult
    private func extractAlternative() throws -> Bool {
        guard var item = infoItem else { return false }
        let count = currentConfigData.items.count
        if count <= 1 {
            return false
        }
        currentConfigData.items.remove(item)
        item.priority -= count
        currentConfigData.items.insert(item)
        configRepository.set(config: currentConfigData)
        infoItem = currentConfigData.topPriorityItem()
        return true
    }
}
