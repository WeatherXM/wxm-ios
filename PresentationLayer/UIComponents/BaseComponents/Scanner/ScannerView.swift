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
			Scanner(completion: completion)
		} else {
			CodeScannerView(codeTypes: [mode.toMetadataObjectType]) { result in
				switch result {
					case .success(let input):
						completion(input.string)
					case .failure(_):
						completion(nil)
				}
			}
			.overlay(QrScannerView())
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
						.barcode(symbologies: [.code128])
			}
		}

		var toMetadataObjectType: AVMetadataObject.ObjectType {
			switch self {
				case .qr:
						.qr
				case .barcode:
						.code128
			}
		}
	}
}

@available(iOS 16.0, *)
private struct Scanner: UIViewControllerRepresentable {

	let completion: GenericCallback<String?>

	func makeUIViewController(context: Context) -> DataScannerWrapperViewController {
		let controller = DataScannerWrapperViewController()
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

	override func viewDidLoad() {
		super.viewDidLoad()
		let controller = DataScannerViewController(recognizedDataTypes: [.barcode(symbologies: [.qr])],
												   qualityLevel: .balanced,
												   isHighFrameRateTrackingEnabled: false,
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
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let viewBounds = scannerController?.view.bounds ?? .zero
		let region = CGRect(x: viewBounds.width / 4.0,
							y: viewBounds.height / 4.0,
							width: viewBounds.width / 2.0,
							height: viewBounds.width / 2.0)
		print(scannerController?.regionOfInterest)
		scannerController?.regionOfInterest = region
		
		if scannerController?.isScanning == false {
			try? scannerController?.startScanning()
		}

		print(scannerController?.view.frame)
	}
}

#Preview {
	ScannerView(mode: .qr) { _ in }
}
