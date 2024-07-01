//
//  ScannerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/6/24.
//

import SwiftUI
import VisionKit

struct ScannerView: View {
    var body: some View {
		if #available(iOS 16.0, *) {
			GeometryReader { proxy in
				Scanner(containerSize: proxy.size)
			}
		} else {
			EmptyView()
		}
    }
}

@available(iOS 16.0, *)
private struct Scanner: UIViewControllerRepresentable {
	
	@State var containerSize: CGSize

	func makeUIViewController(context: Context) -> DataScannerWrapperViewController {
		let controller = DataScannerWrapperViewController()
		controller.scannerDelegate = context.coordinator

		return controller
	}

	func updateUIViewController(_ uiViewController: DataScannerWrapperViewController, context: Context) {
		print(uiViewController.view.bounds)
	}

	func makeCoordinator() -> Coordinator {
		.init()
	}

	class Coordinator: DataScannerViewControllerDelegate {
		func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
			print(allItems)
		}
	}
}

@available(iOS 16.0, *)
private class DataScannerWrapperViewController: UIViewController {
	
	weak var scannerController: DataScannerViewController?
	weak var scannerDelegate: DataScannerViewControllerDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()
		let controller = DataScannerViewController(recognizedDataTypes: [.barcode(symbologies: [.qr])])
		scannerController = controller
		controller.delegate = scannerDelegate
		addChild(controller)
		controller.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(controller.view)
		
		NSLayoutConstraint.activate([
			controller.view.topAnchor.constraint(equalTo: view.topAnchor),
			controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])

		controller.didMove(toParent: self)

		let overlayVC = UIHostingController(rootView: QrScannerView())
		controller.addChild(overlayVC)
		overlayVC.view.translatesAutoresizingMaskIntoConstraints = false
		overlayVC.view.backgroundColor = .clear
		let overlayContainerView = controller.overlayContainerView
		overlayContainerView.addSubview(overlayVC.view)

		NSLayoutConstraint.activate([
			overlayVC.view.topAnchor.constraint(equalTo: overlayContainerView.topAnchor),
			overlayVC.view.bottomAnchor.constraint(equalTo: overlayContainerView.bottomAnchor),
			overlayVC.view.leadingAnchor.constraint(equalTo: overlayContainerView.leadingAnchor),
			overlayVC.view.trailingAnchor.constraint(equalTo: overlayContainerView.trailingAnchor)
		])

		overlayVC.didMove(toParent: self)


		try? controller.startScanning()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let viewBounds = view.bounds
		let region = CGRect(x: viewBounds.width / 4.0,
							y: viewBounds.height / 4.0,
							width: viewBounds.width / 2.0,
							height: viewBounds.width / 2.0)
		scannerController?.regionOfInterest = region
	}
}

#Preview {
    ScannerView()
}
