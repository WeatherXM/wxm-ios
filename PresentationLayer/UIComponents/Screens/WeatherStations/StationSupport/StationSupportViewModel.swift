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

		refresh()
	}

	private func refresh() {
		mode = .loading
		do {
			try useCase.getDeviceSupport(deviceName: stationName)
				.receive(on: DispatchQueue.main)
				.sink { [weak self] response in
				switch response.result {
					case .success(let support):
						if let markdownString = support.outputs?.result {
							self?.mode = .content(markdownString: markdownString)
						} else {
							self?.mode = .error
						}
					case .failure(_):
						self?.mode = .error
				}
			}.store(in: &cancellables)
		} catch {
			print(error)
			mode = .error
		}
	}
}

extension StationSupportViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(stationName)
	}
}
