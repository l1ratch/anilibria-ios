//
//  LiquidGlassView.swift
//  AniLiberty
//
//  Created for iOS Liquid Glass Design System.
//

import UIKit

/// A modern Liquid Glass surface component with frosted material blur,
/// specular gradient border highlights, continuous squircle corners, and fluid touch interactions.
open class LiquidGlassView: UIView {

    // MARK: - Properties

    public var cornerRadius: CGFloat = 24 {
        didSet {
            updateCorners()
        }
    }

    public var blurStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark {
        didSet {
            blurView.effect = UIBlurEffect(style: blurStyle)
        }
    }

    public var isInteractive: Bool = false
    public var glowColor: UIColor? {
        didSet {
            updateGlow()
        }
    }
    public var glowRadius: CGFloat = 16 {
        didSet {
            updateGlow()
        }
    }

    // MARK: - Subviews & Layers

    public let contentView = UIView()
    private let blurView = UIVisualEffectView()
    private let tintOverlayView = UIView()
    private let borderLayer = CAGradientLayer()
    private let borderShapeMask = CAShapeLayer()

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    public convenience init(
        cornerRadius: CGFloat = 24,
        blurStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark,
        isInteractive: Bool = false
    ) {
        self.init(frame: .zero)
        self.cornerRadius = cornerRadius
        self.blurStyle = blurStyle
        self.isInteractive = isInteractive
        self.blurView.effect = UIBlurEffect(style: blurStyle)
        updateCorners()
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = .clear
        clipsToBounds = false

        // Blur View
        blurView.effect = UIBlurEffect(style: blurStyle)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)

        // Tint Overlay for deep liquid glass feel
        tintOverlayView.backgroundColor = UIColor(white: 1.0, alpha: 0.03)
        tintOverlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tintOverlayView)

        // Content View
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        // Specular Border Gradient (Light reflection on curved glass edges)
        borderLayer.colors = [
            UIColor.white.withAlphaComponent(0.22).cgColor,
            UIColor.white.withAlphaComponent(0.06).cgColor,
            UIColor.white.withAlphaComponent(0.02).cgColor,
            UIColor.white.withAlphaComponent(0.12).cgColor
        ]
        borderLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        borderLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.addSublayer(borderLayer)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            tintOverlayView.topAnchor.constraint(equalTo: topAnchor),
            tintOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tintOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tintOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor),

            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        updateCorners()
    }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        updateCorners()
        updateBorder()
    }

    private func updateCorners() {
        layer.cornerCurve = .continuous
        layer.cornerRadius = cornerRadius

        blurView.layer.cornerCurve = .continuous
        blurView.layer.cornerRadius = cornerRadius
        blurView.clipsToBounds = true

        tintOverlayView.layer.cornerCurve = .continuous
        tintOverlayView.layer.cornerRadius = cornerRadius
        tintOverlayView.clipsToBounds = true

        contentView.layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = cornerRadius
    }

    private func updateBorder() {
        borderLayer.frame = bounds

        let path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: cornerRadius
        )

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = 1.0

        borderLayer.mask = mask
    }

    private func updateGlow() {
        if let glowColor = glowColor {
            layer.shadowColor = glowColor.cgColor
            layer.shadowRadius = glowRadius
            layer.shadowOpacity = 0.35
            layer.shadowOffset = CGSize(width: 0, height: 4)
        } else {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 12
            layer.shadowOpacity = 0.25
            layer.shadowOffset = CGSize(width: 0, height: 6)
        }
    }

    // MARK: - Touch Interaction

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard isInteractive else { return }
        animatePress(isDown: true)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard isInteractive else { return }
        animatePress(isDown: false)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard isInteractive else { return }
        animatePress(isDown: false)
    }

    private func animatePress(isDown: Bool) {
        let scale: CGFloat = isDown ? 0.97 : 1.0
        let alpha: CGFloat = isDown ? 0.85 : 1.0

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.5,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
                self.contentView.alpha = alpha
            }
        )
    }
}

// MARK: - UIView Liquid Glass Extensions

extension UIView {

    /// Applies a liquid glass background effect with frosted blur and specular highlight border to any view
    @discardableResult
    public func applyLiquidGlass(
        cornerRadius: CGFloat = 20,
        blurStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark,
        borderAlpha: CGFloat = 0.15,
        backgroundColor: UIColor = UIColor(white: 1.0, alpha: 0.04)
    ) -> UIVisualEffectView {
        self.layer.cornerCurve = .continuous
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = UIColor.white.withAlphaComponent(borderAlpha).cgColor
        self.layer.borderWidth = 0.75
        self.layer.masksToBounds = false
        self.clipsToBounds = true

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerCurve = .continuous
        blurView.layer.cornerRadius = cornerRadius
        blurView.clipsToBounds = true

        let tintView = UIView()
        tintView.backgroundColor = backgroundColor
        tintView.translatesAutoresizingMaskIntoConstraints = false

        insertSubview(blurView, at: 0)
        insertSubview(tintView, at: 1)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            tintView.topAnchor.constraint(equalTo: topAnchor),
            tintView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tintView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        return blurView
    }

    /// Triggers physical haptic feedback
    public func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
