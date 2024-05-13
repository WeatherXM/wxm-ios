//
//  ClaimDeviceSerialNumberViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/5/24.
//

import Foundation
import CodeScanner
import AVFoundation
import Toolkit

class ClaimDeviceSerialNumberViewModel: ObservableObject {
	let completion: GenericCallback<SerialNumber?>
	@Published var showQrScanner: Bool = false

	var bullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.prepareGatewayD1BulletOne.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.prepareGatewayD1BulletTwo.localized.attributedMarkdown ?? "")]
	}

	var caption: AttributedString? {
		nil
	}

	var gifFileName: String {
		"image_station_qr"
	}

	init(completion: @escaping GenericCallback<SerialNumber?>) {
		self.completion = completion
	}

	func handleSNButtonTap() {
		completion(nil)
	}

	func handleQRCodeButtonTap() {
		requestCameraPermission()
	}

	func handleQRScanResult(result: Result<ScanResult, ScanError>) {
		switch result {
			case .success(let result):
				let input = result.string.components(separatedBy: ",")
				guard let serialNumber = input[safe: 0]?.trimWhiteSpaces() else {
					return
				}
				let key = input[safe: 1]?.trimWhiteSpaces()
				completion(SerialNumber(serialNumber: serialNumber, key: key))
			case .failure(let error):
				print("Scan failed: \(error.localizedDescription)")
				Toast.shared.show(text: error.localizedDescription.attributedMarkdown ?? "")
		}
	}
}

extension ClaimDeviceSerialNumberViewModel {
	struct SerialNumber {
		let serialNumber: String
		let key: String?
	}
}

private extension ClaimDeviceSerialNumberViewModel {
	func requestCameraPermission() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
			case .notDetermined:
				AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
					if granted {
						self?.showQrScanner = true
					} else {
						
					}
				}
			case .restricted:
				break
			case .denied:
				let title = LocalizableString.ClaimDevice.cammeraPermissionDeniedTitle.localized
				let message = LocalizableString.ClaimDevice.cammeraPermissionDeniedText.localized
				let alertObj = AlertHelper.AlertObject.getNavigateToSettingsAlert(title: title,
																				  message: message)
				AlertHelper().showAlert(alertObj)
			case .authorized:
				showQrScanner = true
			@unknown default:
				break
		}
	}
}

class ClaimDeviceSerialNumberM5ViewModel: ClaimDeviceSerialNumberViewModel {
	override var bullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.prepareGatewayM5BulletOne.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.prepareGatewayM5BulletTwo.localized.attributedMarkdown ?? "")]
	}

	override var caption: AttributedString? {
		LocalizableString.ClaimDevice.prepareGatewayM5Caption.localized.attributedMarkdown
	}

	override var gifFileName: String {
		"image_m5_station_qr"
	}
}
