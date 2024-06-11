//
//  Toast.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/3/23.
//

import SwiftUI
import Toolkit

/// Toast view to show messages on top of the view hierarchy
class Toast: UIView {
    /// Use the singleton to handle internally consecutive `show`s
    static var shared = Toast()

    private var keyWindow: UIWindow? {
        UIApplication.shared.currentKeyWindow
    }
    private var hostVC: UIViewController?

    private init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	/// Show toast at the bottom of the screen.
	/// - Parameters:
	///   - text: The text to show
	///   - type: The toast type for the appropriate style, currentlye `error` or `info`
	///   - visibleDuration: The duration that the toast will be on screen
	///   - retryButtonTitle: The title of the retry buton, by default is LocalizableString.retry.localized
	///   - retryAction: Action to be exectuted once the retry button tapped. If not passed the retry button will be hidden
	func show(text: AttributedString,
			  type: ToastView.ToastType = .error,
			  visibleDuration: CGFloat = 3.0,
			  retryButtonTitle: String = LocalizableString.retry.localized,
			  retryAction: VoidCallback? = nil) {
        guard let keyWindow, superview == nil else {
            return
        }

        let view = ToastView(text: text, type: type,
							 dismissInterval: visibleDuration,
							 retryButtonTitle: retryButtonTitle,
							 dismissCompletion: { [weak self] in
            self?.hostVC?.view.removeFromSuperview()
            self?.removeFromSuperview()
        }, retryAction: retryAction)

        let hostVC = UIHostingController(rootView: view)
        hostVC.view.translatesAutoresizingMaskIntoConstraints = false
        hostVC.view.backgroundColor = .clear

        addSubview(hostVC.view)
        hostVC.view.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        hostVC.view.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: 0).isActive = true
        hostVC.view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        hostVC.view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        self.hostVC = hostVC

        keyWindow.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor, constant: 0).isActive = true
        leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor, constant: 0).isActive = true
        trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor, constant: 0).isActive = true
        self.keyboardLayoutGuide.followsUndockedKeyboard = true
    }
}
