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

        topViewController?.transitionCoordinator?.animate(alongsideTransition: nil, completion: { [weak self] context in
            guard let self = self else { return }
            if context.isCancelled {
                let isVisible = self.topViewController?.isNavigationBarVisible == true
                self.setNavigationBarHidden(!isVisible, animated: false)
                
                let isCurrentRoot = self.topViewController == self.viewControllers.first
                let currentShouldHide = !isCurrentRoot || (self.topViewController?.hidesBottomBarWhenPushed == true)
                NotificationCenter.default.post(
                    name: .shouldToggleBottomBar,
                    object: nil,
                    userInfo: ["hidden": currentShouldHide, "animated": false]
                )
            }
        })
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == self.interactivePopGestureRecognizer else { return true }
        if self.viewControllers.count > 1 && self.isInteractivePopEnabled && self.transitionCoordinator == nil {
            return true
        }
        return false
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            return true
        }
        return false
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return false
    }
}
