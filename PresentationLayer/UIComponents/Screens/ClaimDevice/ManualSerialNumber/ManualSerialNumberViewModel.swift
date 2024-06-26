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
	private let completion: GenericCallback<[SerialNumberInputField]>

	var title: String {
		LocalizableString.ClaimDevice.enterGatewayDetailsTitle.localized
	}

	var subtitle: AttributedString {
		LocalizableString.ClaimDevice.enterGatewayDetailsDescription.localized.attributedMarkdown ?? ""
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
		 completion: @escaping GenericCallback<[SerialNumberInputField]>) {
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
			case .serialNumber:
				if let validator {
					textfield.updateSerialNumberCharactersIn(nsRange: range, for: text, validator: validator)
				}
				return false
		}
	}

	func handleProceedButtonTap() {
		completion(inputFields)
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
	
	override var subtitle: AttributedString {
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
				  completion: @escaping GenericCallback<[SerialNumberInputField]>) {
		super.init(inputFields: inputFields, completion: completion)
		self.validator = SNValidator(type: .m5)
	}
}
