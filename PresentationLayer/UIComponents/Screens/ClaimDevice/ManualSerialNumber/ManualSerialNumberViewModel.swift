//
//  ManualSerialNumberViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/5/24.
//

import Foundation

class ManualSerialNumberViewModel: ObservableObject {
	@Published var inputFields: [SerialNumberInputField]
	@Published var canProceed: Bool = false

	var image: AssetEnum? {
		.imageD1Claim
	}

	var gifFile: String? {
		nil
	}

	init(inputFields: [SerialNumberInputField] = [.init(type: .claimingKey, value: ""),
												  .init(type: .serialNumber, value: "")]) {
		self.inputFields = inputFields
	}

	func setValue(for type: SerialNumberInputType, value: String) {
		guard let index = inputFields.firstIndex(where: { $0.type == type }) else {
			return
		}

		inputFields[index].setValue(value: value)
		validateInputs()
	}
}

fileprivate extension ManualSerialNumberViewModel {
	func validateInputs() {
		canProceed = inputFields.reduce(true, { partialResult, field in
			switch field.type {
				case .claimingKey:
					return partialResult && !field.value.isEmpty
				case .serialNumber:
					return partialResult && !field.value.isEmpty
			}
		})

		print(canProceed)
		print(inputFields)
	}
}

class ManualSerialNumberM5ViewModel: ManualSerialNumberViewModel {
	override var image: AssetEnum? {
		nil
	}

	override var gifFile: String? {
		"image_m5_station_qr"
	}

	override init(inputFields: [SerialNumberInputField] = [.init(type: .serialNumber, value: "")]) {
		super.init(inputFields: inputFields)
	}
}
