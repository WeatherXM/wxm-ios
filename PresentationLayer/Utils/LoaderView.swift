//
//  LoaderView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/3/23.
//

import SwiftUI
import Toolkit

/// Full screen loader to use during asynchronous processes (eg. API requests) to prevent user interaction
class LoaderView: UIView {
    /// Use the singleton to handle internally consecutive `show`s
    static let shared = LoaderView()

    private let iconDimensions: CGFloat = 150

    private init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var hostingVC: UIHostingController<some View> = {
        let lottieView = LottieView(animationCase: AnimationsEnums.loader.animationString, loopMode: .loop)
            .frame(width: iconDimensions, height: iconDimensions)
        let hostVC = UIHostingController(rootView: lottieView)
        hostVC.view.backgroundColor = .clear
        return hostVC
    }()

    /// Presents the loader on top of the view hierarchy
    func show() {
		guard superview == nil, let keyWindow = UIApplication.shared.currentKeyWindow else { return }
		keyWindow.addSubview(self)
		
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor).isActive = true

        alpha = 0.0
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1.0
        }
    }

    /// Dismisses the visible loader
    /// - Parameter completion: Called once the loader is removed from the screen
    func dismiss(completion: VoidCallback? = nil) {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.0
		} completion: { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
}

private extension LoaderView {
    func setup() {
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        addSubview(hostingVC.view)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        hostingVC.view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        hostingVC.view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
