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
	@Published var markdownString: String?

	private let useCase: MeUseCaseApi
	private let stationName: String
	private var cancellables: Set<AnyCancellable> = []

	init(stationName: String, useCase: MeUseCaseApi) {
		self.stationName = stationName
		self.useCase = useCase
	}

	func refresh() {
		do {
			try useCase.getDeviceSupport(deviceName: stationName).sink { response in
				switch response.result {
					case .success(let support):
						self.markdownString = support.outputs?.result
						break
					case .failure(let error):
						break
				}
			}.store(in: &cancellables)
		} catch {
			print(error)
		}
	}
}

extension StationSupportViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(stationName)
	}
}
