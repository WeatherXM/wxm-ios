//
//  ManualSerialNumberViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/5/24.
//

import Foundation

class ManualSerialNumberViewModel: ObservableObject {
	var image: AssetEnum? {
		.imageD1Claim
	}

	var gifFile: String? {
		nil
	}
}

class ManualSerialNumberM5ViewModel: ManualSerialNumberViewModel {
	override var image: AssetEnum? {
		nil
	}

	override var gifFile: String? {
		"image_m5_station_qr"
	}
}
