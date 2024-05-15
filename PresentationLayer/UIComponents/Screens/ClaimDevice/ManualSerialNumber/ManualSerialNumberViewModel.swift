//
//  ManualSerialNumberViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/5/24.
//

import Foundation

class ManualSerialNumberViewModel: ObservableObject {
	@Published var inputFields: [SerialNumberInputField]

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
