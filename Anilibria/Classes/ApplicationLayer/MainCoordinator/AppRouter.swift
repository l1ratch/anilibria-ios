import UIKit

public class AppRouter {
    private(set) var window: UIWindow!

    init() {}

    public func openDefaultScene(on window: UIWindow) {
        self.window = window
        InterfaceAppearance.current.apply()
        let module = MainContainerAssembly.createModule()
        SetWindowRouter(target: module,
                        window: window).move()
    }

    public func reloadScene() {
        guard let win = self.window ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        openDefaultScene(on: win)
    }
}
