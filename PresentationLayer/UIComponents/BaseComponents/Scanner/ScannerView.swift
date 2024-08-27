//
//  ScannerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/6/24.
//

import SwiftUI
import VisionKit
import Toolkit
import CodeScanner
import AVFoundation

struct ScannerView: View {
	let mode: Mode
	let completion: GenericCallback<String?>

    var body: some View {
		if #available(iOS 16.0, *) {
			Scanner(mode: mode, completion: completion)
		} else {
			CodeScannerView(codeTypes: mode.toMetadataObjectTypes) { result in
				switch result {
					case .success(let input):
						completion(input.string)
					case .failure:
						completion(nil)
				}
			}
			.overlay(ScannerOverlayView(layout: mode.overlayLayout))
		}
    }
}

extension ScannerView {
	enum Mode {
		case qr
		case barcode

		@available(iOS 16.0, *)
		var toBarcodeSymbology: DataScannerViewController.RecognizedDataType {
			switch self {
				case .qr:
						.barcode(symbologies: [.qr])
				case .barcode:
						.barcode(symbologies: [.code128, .ean8, .ean13])
			}
		}

		var toMetadataObjectTypes: [AVMetadataObject.ObjectType] {
			switch self {
				case .qr:
					[.qr]
				case .barcode:
					[.code128, .ean8, .ean13]
			}
		}

		var overlayLayout: ScannerOverlayView.Layout {
			switch self {
				case .qr:
						.square
				case .barcode:
						.rectangle
			}
		}
	}
}

@available(iOS 16.0, *)
private struct Scanner: UIViewControllerRepresentable {

	let mode: ScannerView.Mode
	let completion: GenericCallback<String?>

	func makeUIViewController(context: Context) -> DataScannerWrapperViewController {
		let controller = DataScannerWrapperViewController(mode: mode)
		controller.scannerDelegate = context.coordinator

		return controller
	}

	func updateUIViewController(_ uiViewController: DataScannerWrapperViewController, context: Context) {
	}

	func makeCoordinator() -> Coordinator {
		.init(completion: completion)
	}

	class Coordinator: DataScannerViewControllerDelegate {
		let completion: GenericCallback<String?>
		
		init(completion: @escaping GenericCallback<String?>) {
			self.completion = completion
		}

		func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
			guard let firstItem = addedItems.first else {
				return
			}

			dataScanner.stopScanning()

			switch firstItem {
				case .text(let text):
					completion(text.transcript)
					Haptics.performSuccessHapticEffect()
				case .barcode(let barcode):
					completion(barcode.payloadStringValue)
					Haptics.performSuccessHapticEffect()
				@unknown default:
					break
			}
		}
	}
}

@available(iOS 16.0, *)
private class DataScannerWrapperViewController: UIViewController {
	
	weak var scannerController: DataScannerViewController?
	weak var scannerDelegate: DataScannerViewControllerDelegate?

	private let mode: ScannerView.Mode

	init(mode: ScannerView.Mode) {
		self.mode = mode
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let controller = DataScannerViewController(recognizedDataTypes: [mode.toBarcodeSymbology],
												   qualityLevel: .accurate,
												   isHighFrameRateTrackingEnabled: true,
												   isPinchToZoomEnabled: false,
												   isGuidanceEnabled: false)
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

		let overlayVC = UIHostingController(rootView: ScannerOverlayView(layout: mode.overlayLayout))
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
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Position of the region of interest is a rectangle at the center of the view
		let viewBounds = scannerController?.view.bounds ?? .zero
		let region = regionRect(viewBounds: viewBounds)
		scannerController?.regionOfInterest = region
		
		if scannerController?.isScanning == false {
			try? scannerController?.startScanning()
		}
	}

	func regionRect(viewBounds: CGRect) -> CGRect {
		switch mode {
			case .qr:
				let region = CGRect(x: viewBounds.width / 4.0,
									y: 3.0 * viewBounds.height / 8.0,
									width: viewBounds.width / 2.0,
									height: viewBounds.width / 2.0)

				return region
			case .barcode:
				let region = CGRect(x: viewBounds.width / 8.0,
									y: viewBounds.height / 2.0 - viewBounds.width / 8.0,
									width: 3.0 * viewBounds.width / 4.0,
									height: viewBounds.width / 4.0)

				return region
		}
	}
}

#Preview {
	ScannerView(mode: .barcode) { _ in }
}
