import UIKit
import Foundation

public final class CrashDebugger {
    private static var errorWindow: UIWindow?

    public static func setup() {
        NSSetUncaughtExceptionHandler { exception in
            let name = exception.name.rawValue
            let reason = exception.reason ?? "No reason given"
            let stack = exception.callStackSymbols.joined(separator: "\n")
            let fullError = "🔥 CRASH EXCEPTION 🔥\nName: \(name)\nReason: \(reason)\n\nStack:\n\(stack)"
            
            print(fullError)
            saveCrashLog(fullError)
            
            // Show alert synchronously if possible or loop runloop
            DispatchQueue.main.async {
                showError(title: "App Crash: \(name)", message: reason, details: stack)
            }
            
            // Keep main runloop alive long enough for UI to show
            let runLoop = CFRunLoopGetCurrent()
            let allModes = CFRunLoopCopyAllModes(runLoop)
            while true {
                for mode in (allModes as? [CFRunLoopMode]) ?? [] {
                    CFRunLoopRunInMode(mode, 0.5, true)
                }
            }
        }
    }

    public static func showError(title: String, message: String, details: String? = nil) {
        DispatchQueue.main.async {
            let fullText = "\(title)\n\n\(message)\n\n\(details ?? "")"
            UIPasteboard.general.string = fullText

            guard let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first else {
                return
            }

            let win = UIWindow(windowScene: windowScene)
            win.windowLevel = .alert + 1
            win.backgroundColor = .clear

            let alertController = UIViewController()
            alertController.view.backgroundColor = UIColor.black.withAlphaComponent(0.85)

            let container = UIView()
            container.backgroundColor = UIColor(white: 0.15, alpha: 0.95)
            container.layer.cornerRadius = 16
            container.clipsToBounds = true
            container.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.addSubview(container)

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textColor = .systemRed
            titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
            titleLabel.numberOfLines = 0
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(titleLabel)

            let textView = UITextView()
            textView.text = "\(message)\n\n--- Stack / Details ---\n\(details ?? "No extra details")"
            textView.textColor = .white
            textView.backgroundColor = UIColor(white: 0.08, alpha: 1.0)
            textView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
            textView.isEditable = false
            textView.layer.cornerRadius = 8
            textView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(textView)

            let copyButton = UIButton(type: .system)
            copyButton.setTitle("📋 Copy Error to Clipboard", for: .normal)
            copyButton.setTitleColor(.white, for: .normal)
            copyButton.backgroundColor = .systemRed
            copyButton.layer.cornerRadius = 8
            copyButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            copyButton.translatesAutoresizingMaskIntoConstraints = false
            copyButton.addAction(UIAction { _ in
                UIPasteboard.general.string = fullText
                copyButton.setTitle("✅ Copied to Clipboard!", for: .normal)
            }, for: .touchUpInside)
            container.addSubview(copyButton)

            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor),
                container.centerYAnchor.constraint(equalTo: alertController.view.centerYAnchor),
                container.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 16),
                container.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -16),
                container.heightAnchor.constraint(equalToConstant: 480),

                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

                textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
                textView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                textView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                textView.bottomAnchor.constraint(equalTo: copyButton.topAnchor, constant: -12),

                copyButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                copyButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                copyButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
                copyButton.heightAnchor.constraint(equalToConstant: 44)
            ])

            win.rootViewController = alertController
            win.makeKeyAndVisible()
            self.errorWindow = win
        }
    }

    private static func saveCrashLog(_ log: String) {
        if let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = docs.appendingPathComponent("crash.log")
            try? log.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }
}
