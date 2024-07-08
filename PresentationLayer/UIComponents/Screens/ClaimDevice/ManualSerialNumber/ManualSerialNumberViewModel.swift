//
//  ManualSerialNumberViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/5/24.
//

import Foundation
import UIKit
import Toolkit

class ManualSerialNumberViewModel: ObservableObject {
	@Published var inputFields: [SerialNumberInputField]
	@Published var canProceed: Bool = false
	fileprivate(set) var validator: SNValidator?
	private let completion: GenericCallback<[InputFieldResult]>

	var title: String {
		LocalizableString.ClaimDevice.enterGatewayDetailsTitle.localized
	}

	var subtitle: AttributedString? {
		LocalizableString.ClaimDevice.enterGatewayDetailsDescription.localized.attributedMarkdown ?? ""
	}

	var bullets: [ClaimDeviceBulletView.Bullet]? {
		nil
	}

	var caption: String? {
		nil
	}

	var image: AssetEnum? {
		.imageD1Claim
	}

	var gifFile: String? {
		nil
	}

	init(inputFields: [SerialNumberInputField] = [.init(type: .claimingKey, value: ""),
												  .init(type: .serialNumber(.d1), value: "")],
		 completion: @escaping GenericCallback<[InputFieldResult]>) {
		self.inputFields = inputFields
		self.completion = completion
		self.validator = SNValidator(type: .d1)
	}

	func setValue(for type: SerialNumberInputType, value: String) {
		guard let index = inputFields.firstIndex(where: { $0.type == type }) else {
			return
		}

		inputFields[index].setValue(value: value)
		validateInputs()
	}

	func shouldChangeText(for type: SerialNumberInputType,
						  textfield: UITextField,
						  range: NSRange,
						  text: String) -> Bool {
		switch type {
			case .claimingKey:
				if let range = Range(range, in: textfield.text ?? ""),
				   let newString = textfield.text?.replacingCharacters(in: range, with: text) {
					return validator?.validateStationKeyInput(key: newString) ?? false
				}
				return false
			case .serialNumber(let type):
				switch type {
					case .m5, .d1:
						if let validator {
							textfield.updateSerialNumberCharactersIn(nsRange: range, for: text, validator: validator)
						}
						return false
					case .pulse:
						if let range = Range(range, in: textfield.text ?? ""),
						   let newString = textfield.text?.replacingCharacters(in: range, with: text) {
							return validator?.validateSerialNumberInput(input: newString) ?? true
						}
						return false
				}
		}
	}

	func handleProceedButtonTap() {
		let results = inputFields.map { field in
			switch field.type {
				case .claimingKey:
					return InputFieldResult(type: field.type, value: field.value)
				case .serialNumber(_):
					let normalized = validator?.normalized(serialNumber: field.value) ?? field.value
					return InputFieldResult(type: field.type, value: normalized)
			}

		}
		completion(results)
	}
}

fileprivate extension ManualSerialNumberViewModel {
	func validateInputs() {
		guard let validator else {
			return
		}

		canProceed = inputFields.reduce(true, { partialResult, field in
			switch field.type {
				case .claimingKey:
					return partialResult && validator.validateStationKey(key: field.value)
				case .serialNumber:
					return partialResult && validator.validate(serialNumber: field.value)
			}
		})
	}
}

class ManualSerialNumberM5ViewModel: ManualSerialNumberViewModel {
	override var title: String {
		LocalizableString.ClaimDevice.enterGatewaySerialNumberTitle.localized
	}
	
	override var subtitle: AttributedString? {
		LocalizableString.ClaimDevice.enterGatewaySerialNumberDescription.localized.attributedMarkdown ?? ""
	}

	override var caption: String? {
		LocalizableString.ClaimDevice.enterGatewaySerialNumberCaption.localized
	}
	
	override var image: AssetEnum? {
		nil
	}

	override var gifFile: String? {
		"image_m5_station_qr"
	}

	override init(inputFields: [SerialNumberInputField] = [.init(type: .serialNumber(.m5), value: "")],
				  completion: @escaping GenericCallback<[InputFieldResult]>) {
		super.init(inputFields: inputFields, completion: completion)
		self.validator = SNValidator(type: .m5)
	}
}

class ManualSerialNumberPulseViewModel: ManualSerialNumberViewModel {
	override var title: String {
		LocalizableString.ClaimDevice.enterGatewaySerialNumberTitle.localized
	}

	override var subtitle: AttributedString? {
		LocalizableString.ClaimDevice.enterGatewayPulseSerialNumberDescription.localized.attributedMarkdown ?? ""
	}

	override var caption: String? {
		nil
	}

	override var image: AssetEnum? {
		.pulseBarcode
	}

	override var gifFile: String? {
		nil
	}

	override init(inputFields: [SerialNumberInputField] = [.init(type: .serialNumber(.pulse), value: "")],
				  completion: @escaping GenericCallback<[InputFieldResult]>) {
		super.init(inputFields: inputFields, completion: completion)
		self.validator = SNValidator(type: .pulse)
	}
}

class ClaimingKeyPulseViewModel: ManualSerialNumberViewModel {
	override var title: String {
		LocalizableString.ClaimDevice.enterGatewayClaimingKey.localized
	}

	override var subtitle: AttributedString? {
		nil
	}

	override var bullets: [ClaimDeviceBulletView.Bullet]? {
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.enterGatewayPulseClaimingKeyBulletOne.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.enterGatewayPulseClaimingKeyBulletTwo.localized.attributedMarkdown ?? "")]
	}

	override var caption: String? {
		nil
	}

	override var image: AssetEnum? {
		nil
	}

	override var gifFile: String? {
		"image_pulse_claiming_key"
	}

	override init(inputFields: [SerialNumberInputField] = [.init(type: .claimingKey, value: "")],
				  completion: @escaping GenericCallback<[InputFieldResult]>) {
		super.init(inputFields: inputFields, completion: completion)
	}
}

