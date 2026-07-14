//
//  CursorHidingController.swift
//  Anilibria
//
//  Desktop (Mac Catalyst) only helper that hides the mouse cursor while the
//  user is idle (e.g. during full screen playback) and reveals it again as
//  soon as the mouse/trackpad pointer moves.
//

#if targetEnvironment(macCatalyst)
import UIKit

@available(macCatalyst 13.4, *)
final class CursorHidingController: NSObject {
    private weak var view: UIView?
    private let idleTimeout: TimeInterval
    private let onVisibilityChange: ((Bool) -> Void)?

    private lazy var interaction = UIPointerInteraction(delegate: self)
    private lazy var hoverRecognizer = UIHoverGestureRecognizer(
        target: self,
        action: #selector(handleHover(_:))
    )

    private var isHidden = false {
        didSet {
            guard isHidden != oldValue else { return }
            interaction.invalidate()
            onVisibilityChange?(!isHidden)
        }
    }

    private var idleTimer: Timer?

    init(
        view: UIView,
        idleTimeout: TimeInterval = 3,
        onVisibilityChange: ((Bool) -> Void)? = nil
    ) {
        self.view = view
        self.idleTimeout = idleTimeout
        self.onVisibilityChange = onVisibilityChange
        super.init()
        view.addInteraction(interaction)
        view.addGestureRecognizer(hoverRecognizer)
    }

    deinit {
        idleTimer?.invalidate()
    }

    /// Call to reveal the cursor immediately and restart the idle countdown.
    func resetIdleTimer() {
        isHidden = false
        scheduleIdleTimer()
    }

    /// Call to stop the idle countdown and force the cursor to stay visible.
    func stopIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = nil
        isHidden = false
    }

    private func scheduleIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: idleTimeout, repeats: false) { [weak self] _ in
            self?.isHidden = true
        }
    }

    @objc private func handleHover(_ recognizer: UIHoverGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed:
            resetIdleTimer()
        default:
            break
        }
    }
}

@available(macCatalyst 13.4, *)
extension CursorHidingController: UIPointerInteractionDelegate {
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        isHidden ? .hidden() : nil
    }
}
#endif
