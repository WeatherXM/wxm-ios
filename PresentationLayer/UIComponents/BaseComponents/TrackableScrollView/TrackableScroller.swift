//
//  TrackableScroller.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/11/24.
//

import Foundation
import SwiftUI

struct TrackableScroller<V: View>: UIViewControllerRepresentable {

	var offsetObject: TrackableScrollOffsetObject?
	let content: () -> V

	func makeUIViewController(context: Context) -> UIViewController {
		let vc = ContainerViewController()
		vc.scrollView.delegate = context.coordinator
		let hostVc = UIHostingController(rootView: content())
		hostVc.view.backgroundColor = .clear
		_ = vc.view
		vc.insertChildVC(hostVc)
		return vc
	}

	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

	}

	func makeCoordinator() -> TrackableCoordinator {
		let coordinator = TrackableCoordinator()
		coordinator.offsetObject = offsetObject
		return coordinator
	}
}

class TrackableCoordinator: NSObject, UIScrollViewDelegate {
	weak var offsetObject: TrackableScrollOffsetObject?

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		offsetObject?.contentSize = scrollView.contentSize
		offsetObject?.scrollerSize = scrollView.frame.size
		offsetObject?.contentOffset = scrollView.contentOffset.y
		print(scrollView.contentOffset.y)
	}
}

private class ContainerViewController: UIViewController {
	
	lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView(frame: .zero)
		scrollView.backgroundColor = .red
		scrollView.alwaysBounceVertical = true
		return scrollView
	}()

	override func viewDidLoad() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: 0).isActive = true
		scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
		scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
	}

	func insertChildVC(_ vc: UIViewController) {
		vc.view.translatesAutoresizingMaskIntoConstraints = false
		addChild(vc)
		scrollView.addSubview(vc.view)

		NSLayoutConstraint.activate([
			vc.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
			vc.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
			vc.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
			vc.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
			vc.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
		])
	}
}


#Preview {
	TrackableScroller {
		Text("Text")
	}
}
