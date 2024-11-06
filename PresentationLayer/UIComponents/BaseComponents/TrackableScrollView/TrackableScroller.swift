//
//  TrackableScroller.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/11/24.
//

import Foundation
import SwiftUI
import Toolkit

struct TrackableScroller<V: View>: UIViewControllerRepresentable {
	@Binding var contentSize: CGSize
	var showIndicators: Bool = true
	var offsetObject: TrackableScrollOffsetObject?
	let content: () -> V

	func makeUIViewController(context: Context) -> ContainerViewController {
		let vc = ContainerViewController()
		vc.scrollView.delegate = context.coordinator
		vc.scrollView.showsVerticalScrollIndicator = showIndicators
		let hostVc = UIHostingController(rootView: content())
		hostVc.view.backgroundColor = .clear
		_ = vc.view
		vc.insertChildVC(hostVc)
		context.coordinator.hostVC = hostVc

		return vc
	}

	func updateUIViewController(_ uiViewController: ContainerViewController, context: Context) {
		let sizeChanged = contentSize != uiViewController.scrollView.contentSize
		guard sizeChanged else {
			return
		}

		uiViewController.scrollView.contentSize = contentSize

		if let vc = context.coordinator.hostVC {
			vc.view.removeFromSuperview()
			uiViewController.insertChildVC(vc)
		}
	}

	func makeCoordinator() -> TrackableCoordinator {
		let coordinator = TrackableCoordinator()
		coordinator.offsetObject = offsetObject
		return coordinator
	}
}

class TrackableCoordinator: NSObject, UIScrollViewDelegate {
	weak var offsetObject: TrackableScrollOffsetObject?
	weak var hostVC: UIViewController?

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		offsetObject?.contentSize = scrollView.contentSize
		offsetObject?.scrollerSize = scrollView.frame.size
		offsetObject?.contentOffset = scrollView.contentOffset.y
	}
}

class ContainerViewController: UIViewController {
	
	lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView(frame: .zero)
		scrollView.backgroundColor = .clear
		scrollView.alwaysBounceVertical = true
		return scrollView
	}()

	override func viewDidLoad() {
		view.backgroundColor = .clear
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
		scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
		scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
	}

	func insertChildVC(_ vc: UIViewController) {
		vc.view.layoutIfNeeded()
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

		view.layoutIfNeeded()
	}
}


#Preview {
	NavigationStack {
		NavigationContainerView {
			TrackableScroller(contentSize: .constant(.zero)) {
				Text("Text")
			}
		}
	}
}
