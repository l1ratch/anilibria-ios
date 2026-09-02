import UIKit

extension UIViewController {
    @objc open var isNavigationBarVisible: Bool {
        return true
    }
}

open class BaseNavigationController: UINavigationController {
    open var isInteractivePopEnabled: Bool = true

    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.viewControllers.last?.preferredStatusBarStyle ?? .default
    }

    // MARK: - Orientation

    open override var shouldAutorotate: Bool {
        return false
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

extension Notification.Name {
    static let shouldToggleBottomBar = Notification.Name("shouldToggleBottomBar")
}

extension BaseNavigationController: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController, animated: Bool) {

        setNavigationBarHidden(!viewController.isNavigationBarVisible, animated: animated)
        
        let isRoot = viewController == viewControllers.first
        let shouldHide = !isRoot || viewController.hidesBottomBarWhenPushed
        
        NotificationCenter.default.post(
            name: .shouldToggleBottomBar,
            object: nil,
            userInfo: ["hidden": shouldHide, "animated": animated]
        )

        topViewController?.transitionCoordinator?.notifyWhenInteractionChanges { [weak self] _ in
            let isVisible = self?.topViewController?.isNavigationBarVisible == true
            self?.setNavigationBarHidden(!isVisible, animated: true)
            
            let isCurrentRoot = self?.topViewController == self?.viewControllers.first
            let currentShouldHide = !isCurrentRoot || (self?.topViewController?.hidesBottomBarWhenPushed == true)
            NotificationCenter.default.post(
                name: .shouldToggleBottomBar,
                object: nil,
                userInfo: ["hidden": currentShouldHide, "animated": true]
            )
        }
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count > 1 && self.isInteractivePopEnabled {
            return true
        }
        return false
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return false
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return false
    }
}
