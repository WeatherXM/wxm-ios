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

	func makeUIViewController(context: Context) -> DataScannerViewController {
		let controller = DataScannerViewController(recognizedDataTypes: [.barcode(symbologies: [.qr])])

		controller.delegate = context.coordinator
		return controller
	}

	func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
		let region = CGRect(x: containerSize.width / 4.0,
							y: containerSize.height / 4.0,
							width: containerSize.width / 2.0,
							height: containerSize.height / 2.0)
	}

	func makeCoordinator() -> Coordinator {
		.init()
	}

	class Coordinator: DataScannerViewControllerDelegate {
		
	}
}

#Preview {
    ScannerView()
}
