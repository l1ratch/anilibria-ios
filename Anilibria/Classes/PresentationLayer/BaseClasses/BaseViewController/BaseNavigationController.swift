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

    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !viewControllers.isEmpty {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
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

extension BaseNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController, animated: Bool) {
        setNavigationBarHidden(!viewController.isNavigationBarVisible, animated: animated)
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
        true
    }
}
