//
//  IntentHandler.swift
//  station-intent
//
//  Created by Pantelis Giazitsis on 2/10/23.
//

import Intents
import DomainLayer
import Combine
import Toolkit

class IntentHandler: INExtension, StationWidgetConfigurationIntentHandling {
	let useCase: WidgetUseCase
	var cancellables: Set<AnyCancellable> = []

	override init() {
		useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(WidgetUseCase.self)!
		super.init()
		FirebaseManager.shared.launch()
	}

	func provideSelectedStationOptionsCollection(for intent: StationWidgetConfigurationIntent) async throws -> INObjectCollection<Station> {
		guard useCase.isUserLoggedIn else {
			return INObjectCollection(items: [])
		}

		let result = try await useCase.getDevices()
		switch result {
			case .success(let devices):
				let stations = devices.map { Station(identifier: $0.id,
													 display: $0.friendlyName ?? $0.name,
													 subtitle: $0.address,
													 image: nil) }
				return INObjectCollection(items: stations)
			case .failure(let error):
				throw error
		}
	}

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
