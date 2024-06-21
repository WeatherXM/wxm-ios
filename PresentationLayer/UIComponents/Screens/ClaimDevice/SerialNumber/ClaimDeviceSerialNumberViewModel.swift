//
//  ClaimDeviceSerialNumberViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/5/24.
//

import Foundation
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

	var gifFileName: String? {
		"image_station_qr"
	}

	var image: AssetEnum? {
		nil
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

	func handleQRScanResult(result: String?) {
		guard let result,
			  case let input = result.components(separatedBy: ","),
			  let serialNumber = input[safe: 0]?.trimWhiteSpaces() else {
			return
		}

		showQrScanner = false

		let key = input[safe: 1]?.trimWhiteSpaces()
		let serialNumberObject = SerialNumber(serialNumber: serialNumber, key: key)
		if validate(serialNumber: serialNumberObject) {
			completion(serialNumberObject)
		} else {
			Toast.shared.show(text: LocalizableString.ClaimDevice.invalidQRMessage.localized.attributedMarkdown ?? "")
		}
	}

	fileprivate func validate(serialNumber: SerialNumber) -> Bool {
		guard let key = serialNumber.key else {
			return false
		}
		
		let validator = SNValidator(type: .d1)
		let serial = serialNumber.serialNumber

		return validator.validate(serialNumber: serial) && validator.validateStationKey(key: key)
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

	override func validate(serialNumber: SerialNumber) -> Bool {
		guard serialNumber.key == nil else {
			return false
		}
		let validator = SNValidator(type: .m5)
		let serial = serialNumber.serialNumber

		return validator.validate(serialNumber: serial)
	}
}

class ClaimDeviceSerialNumberPulseViewModel: ClaimDeviceSerialNumberViewModel {
	override var bullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.prepareGatewayPulseBulletOne.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.prepareGatewayPulseBulletTwo.localized.attributedMarkdown ?? "")]
	}

	override var caption: AttributedString? {
		nil
	}

	override var gifFileName: String? {
		nil
	}

	override var image: AssetEnum? {
		.pulseBarcode
	}
	
	override func validate(serialNumber: SerialNumber) -> Bool {
		guard serialNumber.key == nil else {
			return false
		}
		let validator = SNValidator(type: .m5)
		let serial = serialNumber.serialNumber

		return validator.validate(serialNumber: serial)
	}
}
