//
//  LottieView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 26/5/22.
//

import Lottie
import SwiftUI

struct LottieView: View {
	var animationCase: String
	var loopMode: LottieLoopMode

	var body: some View {
		LottieViewRepresentable(animationCase: animationCase, loopMode: loopMode)
			.id(animationCase)
	}
}

private struct LottieViewRepresentable: UIViewRepresentable {
    typealias UIViewType = UIView

    var animationCase: String
    var loopMode: LottieLoopMode

    func makeUIView(context _: UIViewRepresentableContext<LottieViewRepresentable>) -> UIView {
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

    func updateUIView(_: UIView, context _: UIViewRepresentableContext<LottieViewRepresentable>) {}
}

#Preview {
	ScrollView {
		HStack {
			Spacer()
			
			VStack {
				ForEach(AnimationsEnums.allCases, id: \.rawValue) { anim in
					LottieView(animationCase: anim.animationString, loopMode: .loop)
						.frame(width: 100.0, height: 100.0, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
				}
			}

			Spacer()
		}
	}
}
