import DITranquillity
import Combine
import UIKit

final class SettingsPart: DIPart {
    static func load(container: DIContainer) {
        container.register(SettingsPresenter.init)
            .as(SettingsEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class SettingsPresenter {
    private weak var view: SettingsViewBehavior!
    private var router: SettingsRoutable!

    private var playerSettings: PlayerSettings?

    private let playerService: PlayerService
    private let sessionService: SessionService

    private var bag = Set<AnyCancellable>()

    init(playerService: PlayerService,
         sessionService: SessionService) {
        self.playerService = playerService
        self.sessionService = sessionService
    }
}

extension SettingsPresenter: SettingsEventHandler {
    func bind(view: SettingsViewBehavior,
              router: SettingsRoutable) {
        self.view = view
        self.router = router
    }

    func didLoad() {
        bag.removeAll()
        var commonItems: [SettingsControlItem] = []
        let languageItem = SettingsControlItem(
            title: L10n.Screen.Settings.language,
            value: Language.current.name,
            action: { [weak self] _ in self?.selectLanguage() }
        )
        commonItems.append(languageItem)

        let appearanceItem = SettingsControlItem(
            title: L10n.Common.appearance,
            value: InterfaceAppearance.current.title,
            action: { [weak self] in self?.selectAppearance($0) }
        )
        commonItems.append(appearanceItem)

        var playerItems: [SettingsControlItem] = []

        if UIDevice.current.userInterfaceIdiom == .phone {
            let orientation = SettingsControlItem(
                title: L10n.Common.orientation,
                value: InterfaceOrientation.current.title,
                action: { [weak self] in self?.selectOrientation($0) }
            )
            playerItems.append(orientation)
        }

        let qualityItem = SettingsControlItem(
            title: L10n.Screen.Settings.videoQuality,
            value: "",
            action: { [weak self] _ in self?.selectQuality() }
        )
        playerItems.append(qualityItem)

        let speedItem = SettingsControlItem(
            title: L10n.Common.playbackRate,
            value: "",
            action: { [weak self] _ in self?.selectPlaybackRate() }
        )
        playerItems.append(speedItem)

        let skipItem = SettingsControlItem(
            title: L10n.Common.skipCredits,
            value: "",
            action: { [weak self] _ in self?.selectSkipMode() }
        )
        playerItems.append(skipItem)

        let autoplayItem = SettingsControlItem(
            title: L10n.Common.autoPlayLong,
            isOn: playerSettings?.autoPlay ?? false,
            iconName: "play.circle.fill",
            iconTint: .systemPink,
            onToggle: { [weak self] isOn in
                self?.update(autoplay: isOn)
            }
        )
        playerItems.append(autoplayItem)

        let startupItem = SettingsControlItem(
            title: L10n.Common.playOnStartup,
            isOn: playerSettings?.playOnStartup ?? false,
            iconName: "play.rectangle.fill",
            iconTint: .systemRed,
            onToggle: { [weak self] isOn in
                self?.update(playOnStartup: isOn)
            }
        )
        playerItems.append(startupItem)

        playerService.observeSettings().sink { [weak self] settings in
            self?.playerSettings = settings
            qualityItem.value = settings.quality.name
            speedItem.value = PlayerSettings.nameFor(rate: settings.playbackRate)
            autoplayItem.isOn = settings.autoPlay
            skipItem.value = settings.skipMode.name
            startupItem.isOn = settings.playOnStartup
        }.store(in: &bag)

        self.view.set(name: Bundle.main.displayName ?? "",
                      version: Bundle.main.releaseVersionNumber ?? "")
        self.view.set(common: commonItems)
        self.view.set(player: playerItems)

        var customItems: [SettingsControlItem] = []

        let dockEditorItem = SettingsControlItem(
            title: Language.isEnglish ? "Dock Settings" : "Настройка Дока",
            value: "",
            iconName: "dock.rectangle",
            iconTint: .systemPurple,
            action: { [weak self] _ in self?.router.openDockEditor() }
        )
        customItems.append(dockEditorItem)

        let collectionsEditorItem = SettingsControlItem(
            title: Language.isEnglish ? "Lists Settings" : "Настройка списков",
            value: "",
            iconName: "list.bullet.rectangle.portrait",
            iconTint: .systemTeal,
            action: { [weak self] _ in self?.router.openCollectionsEditor() }
        )
        customItems.append(collectionsEditorItem)

        let historySettingsItem = SettingsControlItem(
            title: Language.isEnglish ? "History Settings" : "Настройки истории",
            value: "",
            iconName: "clock.arrow.circlepath",
            iconTint: .systemIndigo,
            action: { [weak self] _ in self?.router.openHistorySettings() }
        )
        customItems.append(historySettingsItem)

        self.view.set(customization: customItems)
    }

    func selectNewsVisibility(_ control: SettingsControlItem) {
        let isHidden = UserDefaults.standard.bool(forKey: "hideNewsOnFeed")
        let items = [
            ChoiceItem(
                value: false,
                title: "Показывать",
                isSelected: !isHidden,
                didSelect: { _ in
                    UserDefaults.standard.set(false, forKey: "hideNewsOnFeed")
                    NotificationCenter.default.post(name: NSNotification.Name("feedSettingsChanged"), object: nil)
                    control.value = "Показывается"
                    return true
                }
            ),
            ChoiceItem(
                value: true,
                title: "Скрывать",
                isSelected: isHidden,
                didSelect: { _ in
                    UserDefaults.standard.set(true, forKey: "hideNewsOnFeed")
                    NotificationCenter.default.post(name: NSNotification.Name("feedSettingsChanged"), object: nil)
                    control.value = "Скрыт"
                    return true
                }
            )
        ]
        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func selectQuality() {
        let qualities = VideoQuality.allCases

        let items = qualities.map {
            ChoiceItem(
                value: $0,
                title: $0.name,
                isSelected: playerSettings?.quality == $0,
                didSelect: { [weak self] item in
                    self?.update(item)
                    return true
                }
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func selectLanguage() {
        let languages = Language.allCases
        let items = languages.map { (lang: Language) in
            ChoiceItem(
                value: lang,
                title: lang.name,
                isSelected: Language.current == lang,
                didSelect: { [weak self] (selected: Language) in
                    guard Language.current != selected else { return true }
                    Language.current = selected
                    let isEn = selected == .en
                    let alert = UIAlertController(
                        title: isEn ? "Language Changed" : "Язык интерфейса",
                        message: isEn ? "To apply the new language across all screens, a quick reload is recommended. Reload now?" : "Для полного применения языка ко всем экранам рекомендуется быстрая перезагрузка. Перезагрузить сейчас?",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: isEn ? "Later" : "Позже", style: .cancel))
                    alert.addAction(UIAlertAction(title: isEn ? "Reload" : "Перезагрузить", style: .default) { _ in
                        MainAppCoordinator.shared.reloadScene()
                    })
                    self?.router.presentAlert(alert)
                    return true
                }
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func selectAppearance(_ control: SettingsControlItem) {
        let current = InterfaceAppearance.current
        let items = InterfaceAppearance.allCases.map {
            ChoiceItem(
                value: $0,
                title: $0.title,
                isSelected: current == $0,
                didSelect: { item in
                    item.save()
                    item.apply()
                    control.value = item.title
                    return true
                }
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func selectOrientation(_ control: SettingsControlItem) {
        let current = InterfaceOrientation.current
        let items = InterfaceOrientation.allCases.map {
            ChoiceItem(
                value: $0,
                title: $0.title,
                isSelected: current == $0,
                didSelect: { item in
                    item.save()
                    control.value = item.title
                    return true
                }
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func selectPlaybackRate() {
        let options = PlayerSettings.playbackRateOptions

        let items = options.map {
            ChoiceItem(
                value: $0,
                title: "\($0)x",
                isSelected: playerSettings?.playbackRate == $0,
                didSelect: { [weak self] item in
                    self?.update(item)
                    return true
                }
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func selectSkipMode() {
        let options = SkipCreditsMode.allCases

        let items = options.map {
            ChoiceItem(
                value: $0,
                title: $0.name,
                isSelected: playerSettings?.skipMode == $0,
                didSelect: { [weak self] item in
                    self?.update(item)
                    return true
                }
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }


    private func update(_ quality: VideoQuality) {
        guard var playerSettings else { return }
        playerSettings.quality = quality
        playerService.update(settings: playerSettings)
    }

    private func update(_ rate: Double) {
        guard var playerSettings else { return }
        playerSettings.playbackRate = rate
        playerService.update(settings: playerSettings)
    }

    private func update(_ mode: SkipCreditsMode) {
        guard var playerSettings else { return }
        playerSettings.skipMode = mode
        playerService.update(settings: playerSettings)
    }

    private func update(autoplay: Bool) {
        guard var playerSettings else { return }
        playerSettings.autoPlay = autoplay
        playerService.update(settings: playerSettings)
    }

    private func update(playOnStartup: Bool) {
        guard var playerSettings else { return }
        playerSettings.playOnStartup = playOnStartup
        playerService.update(settings: playerSettings)
    }
}
