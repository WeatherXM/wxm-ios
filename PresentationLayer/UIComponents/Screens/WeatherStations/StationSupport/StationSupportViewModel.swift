//
//  StationSupportViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 22/9/25.
//

import Foundation
import DomainLayer
import Combine

@MainActor
class StationSupportViewModel: ObservableObject {
	@Published var mode: StationSupportView.Mode = .loading

	private let useCase: MeUseCaseApi
	private let stationName: String
	private var cancellables: Set<AnyCancellable> = []

	init(stationName: String, useCase: MeUseCaseApi) {
		self.stationName = stationName
		self.useCase = useCase
	}

	func refresh() {
		mode = .loading
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			let markdownString = "OK. Here's an analysis of your WeatherXM station, **Atomic Pineapple Heat**:\n\nThe station is **active** and located in Covas e Vila Nova de Oliveirinha, PT. The **Quality of Data (QoD) score is 100**, which is excellent! The weather data is being reported correctly.\n\nHowever, there's an important issue:\n\n*   **No location data:** The station is not reporting GPS location, and has been suspended from rewards.\n\nTo resolve this:\n\n1.  Ensure your **WG3000 Gateway** is placed on a sunny surface, facing south, and with no obstacles in front of it.\n2.  Follow the troubleshooting steps in the [No Location Data documentation](https://docs.weatherxm.com/rewards/rewards-troubleshooting#no-location-data).\n\nIf the issue persists, please submit a support ticket at [WeatherXM Support](https://help.weatherxm.com)."
			self.mode = .content(markdownString: markdownString)
		}
//		do {
//			try useCase.getDeviceSupport(deviceName: stationName).receive(on: DispatchQueue.main).sink { [weak self] response in
//				self?.isLoading = false
//
//				switch response.result {
//					case .success(let support):
//						self?.markdownString = support.outputs?.result
//						break
//					case .failure(let error):
//						break
//				}
//			}.store(in: &cancellables)
//		} catch {
//			print(error)
//		}
	}
}

extension StationSupportViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(stationName)
	}
}
