import DITranquillity
import Kingfisher
import UIKit
import AppMetricaCore

public protocol DependenciesConfiguration: AnyObject {
    func setup()
    func configuredContainer() -> DIContainer
}

public class DependenciesConfigurationBase: DependenciesConfiguration, Loggable {
    init() {}

    // MARK: - Configure

    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    private lazy var container: DIContainer = {
        let container = DIContainer()
        container.append(framework: AppFramework.self)
        return container
    }()

    public func configuredContainer() -> DIContainer {
        container
    }

    // MARK: - Setup

    public func setup() {
        self.setupMetrica()
        self.setupLoader()
        self.setupModulesDependencies()
        let modifier = ImageRequestModifier(appConfig: container.resolve())
        KingfisherManager.shared.defaultOptions.append(.requestModifier(modifier))
    }

    private func setupMetrica() {
        if let config = AppMetricaConfiguration(apiKey: Keys.yandexMetricaApiKey) {
            AppMetrica.activate(with: config)
        }
    }

    private func setupModulesDependencies() {
        // logger
        let logger = Logger()
        let swiftyLogger = SimpleLogger()
        logger.setupLogger(swiftyLogger)
        Logger.setSharedInstance(logger)
    }

    private func setupLoader() {
        MRLoaderManager.configure(with: MRLoaderView.self)
    }
}
