//
//  ClaimDeviceSerialNumberViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/5/24.
//

import Foundation
@preconcurrency import AVFoundation
import Toolkit

@MainActor
class ClaimDeviceSerialNumberViewModel: ObservableObject {
	let completion: GenericCallback<SerialNumber?>
	@Published var showQrScanner: Bool = false

	var validator: SNValidator { SNValidator(type: .d1) }

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

	var scanButton: (icon: FontIcon, text: String) {
		(.qrcode, LocalizableString.ClaimDevice.scanQRCode.localized)
	}

	var scanType: ScannerView.Mode {
		.qr
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
		showQrScanner = false

		guard let result, let serialNumberObject = getSerialNumber(input: result) else {
			return
		}

		if validate(serialNumber: serialNumberObject) {
			completion(serialNumberObject)
		} else {
			Toast.shared.show(text: LocalizableString.ClaimDevice.invalidQRMessage.localized.attributedMarkdown ?? "")
		}
	}

	fileprivate func getSerialNumber(input: String) -> SerialNumber? {
		let inputArray = input.components(separatedBy: ",")
		guard var serialNumber = inputArray[safe: 0]?.trimWhiteSpaces() else {
			return nil
		}
		
		serialNumber = validator.normalized(serialNumber: serialNumber)
		let key = inputArray[safe: 1]?.trimWhiteSpaces()
		let serialNumberObject = SerialNumber(serialNumber: serialNumber, key: key)

		return serialNumberObject
	}

	fileprivate func validate(serialNumber: SerialNumber) -> Bool {
		guard let key = serialNumber.key else {
			return false
		}
		
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
				AVCaptureDevice.requestAccess(for: .video) { @Sendable [weak self] granted in
					if granted {
						DispatchQueue.main.async {
							self?.showQrScanner = true
						}
					}
				}
			case .restricted:
				break
			case .denied:
				let title = LocalizableString.ClaimDevice.cammeraPermissionDeniedTitle.localized
				let message = LocalizableString.ClaimDevice.cammeraPermissionDeniedText.localized
				let alertObj = AlertHelper.AlertObject.getNavigateToSettingsAlert(title: title,
																				  message: message)
				DispatchQueue.main.async {
					AlertHelper().showAlert(alertObj)
				}
			case .authorized:
				showQrScanner = true
			@unknown default:
				break
		}
	}
}

class ClaimDeviceSerialNumberM5ViewModel: ClaimDeviceSerialNumberViewModel {

	override var validator: SNValidator { .init(type: .m5) }

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

		let serial = serialNumber.serialNumber

		return validator.validate(serialNumber: serial)
	}
}

class ClaimDeviceSerialNumberPulseViewModel: ClaimDeviceSerialNumberViewModel {

	override var validator: SNValidator { .init(type: .pulse) }
	
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

	override var scanButton: (icon: FontIcon, text: String) {
		(.barcode, LocalizableString.ClaimDevice.scanBarcode.localized)
	}

	override var scanType: ScannerView.Mode {
		.barcode
	}

	override func getSerialNumber(input: String) -> SerialNumber? {
		let serial = validator.normalized(serialNumber: input.trimWhiteSpaces())
		return SerialNumber(serialNumber: serial, key: nil)
	}

	override func validate(serialNumber: SerialNumber) -> Bool {
		guard serialNumber.key == nil else {
			return false
		}

		let serial = serialNumber.serialNumber

		return validator.validate(serialNumber: serial)
	}
}
