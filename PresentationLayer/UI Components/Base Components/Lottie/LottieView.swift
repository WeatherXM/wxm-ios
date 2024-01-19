//
//  LottieView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 26/5/22.
//

import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    typealias UIViewType = UIView

    var animationCase: String
    var loopMode: LottieLoopMode

    func makeUIView(context _: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(animationCase)
        animationView.animation = animation
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_: UIView, context _: UIViewRepresentableContext<LottieView>) {}
}
