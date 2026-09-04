import DITranquillity
import Combine
import Foundation

final class LinksServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(LinksServiceImp.init)
            .as(LinksService.self)
            .lifetime(.single)
    }
}

protocol LinksService: AnyObject {
    func fetchLinks() -> AnyPublisher<[LinkData], any Error>
    func fetchDonateLink() -> AnyPublisher<URL, any Error>
    func fetchSignupLink() -> AnyPublisher<URL, any Error>
}

final class LinksServiceImp: LinksService {
    private let aniConfigRepository: AppConfigurationRepository

    private var bag = Set<AnyCancellable>()

    init(aniConfigRepository: AppConfigurationRepository) {
        self.aniConfigRepository = aniConfigRepository
    }

    func fetchLinks() -> AnyPublisher<[LinkData], Error> {
        return aniConfigRepository.fetchLinks()
            .map { $0?.links ?? [] }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func fetchDonateLink() -> AnyPublisher<URL, any Error> {
        return aniConfigRepository.fetchLinks()
            .tryMap {
                if let result = $0?.donateUrl {
                    return result
                }
                throw AppError.plain(message: L10n.Error.configirationEmpty)
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func fetchSignupLink() -> AnyPublisher<URL, any Error> {
        return aniConfigRepository.fetchLinks()
            .tryMap {
                if let result = $0?.signUpUrl {
                    return result
                }
                throw AppError.plain(message: L10n.Error.configirationEmpty)
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
