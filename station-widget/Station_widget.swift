//
//  Station_widget.swift
//  station-widget
//
//  Created by Pantelis Giazitsis on 26/9/23.
//

import WidgetKit
import SwiftUI
@preconcurrency import DomainLayer
import Toolkit

struct Provider: IntentTimelineProvider, @unchecked Sendable {
	private let useCase: WidgetUseCaseApi
	private let cancellableWrapper: CancellableWrapper = .init()
	private let refreshInterval: TimeInterval = 5.0 * 60.0 // 5 mins

	init() {
		let useCase = WidgetUseCase(meRepository: SwinjectHelper.shared.getContainerForSwinject().resolve(MeRepository.self)!,
									keychainRepository: SwinjectHelper.shared.getContainerForSwinject().resolve(KeychainRepository.self)!)
		self.useCase = useCase
		FirebaseManager.shared.launch()
		if let mixpanelToken: String = Bundle.main.getConfiguration(for: .mixpanelToken) {
			WXMAnalytics.shared.launch(with: [.firebase, .mixpanel(mixpanelToken)])
		}
	}

    func placeholder(in context: Context) -> StationTimelineEntry {
		let previewDevice: DeviceDetails = .widgetPreviewDevice
		let entry = StationTimelineEntry(date: .now,
										 displaySize: context.displaySize,
										 id: previewDevice.id,
										 devices: [previewDevice],
										 followState: .init(deviceId: previewDevice.id!, relation: .owned),
										 errorInfo: nil,
										 isLoggedIn: true)
		return entry
    }

	func getSnapshot(for configuration: StationWidgetConfigurationIntent, in context: Context, completion: @escaping (StationTimelineEntry) -> Void) {
		let previewDevice: DeviceDetails = .widgetPreviewDevice
		let entry = StationTimelineEntry(date: .now,
										 displaySize: context.displaySize,
										 id: previewDevice.id,
										 devices: [previewDevice],
										 followState: .init(deviceId: previewDevice.id!, relation: .owned),
										 errorInfo: nil,
										 isLoggedIn: true)
        completion(entry)
    }

	
	func getTimeline(for configuration: StationWidgetConfigurationIntent,
					 in context: Context,
					 completion: @escaping @Sendable (Timeline<StationTimelineEntry>) -> Void) {

		let nextUpdate = Date.now.advanced(by: refreshInterval)
		let displaySize = context.displaySize
		nonisolated(unsafe) let station = configuration.selectedStation
		Task { @MainActor in
			let entry = await getEntry(for: station, displaySize: displaySize)
			let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
			completion(timeline)
		}
    }

	nonisolated
	private func getEntry(for station: Station?, displaySize: CGSize) async -> StationTimelineEntry {
		let isUserLoggedIn = useCase.isUserLoggedIn
		guard let result = try? await useCase.getDevices(useCache: true) else {
			let entry = StationTimelineEntry(date: .now,
											 displaySize: displaySize,
											 id: station?.identifier,
											 devices: [],
											 followState: nil,
											 errorInfo: nil,
											 isLoggedIn: isUserLoggedIn)

			return entry
		}

		let followState: UserDeviceFollowState? = try? await useCase.getDeviceFollowState(deviceId: station?.identifier ?? "").get()

		switch result {
			case .success(let devices):
				let entry = StationTimelineEntry(date: .now,
												 displaySize: displaySize,
												 id: station?.identifier,
												 devices: devices,
												 followState: followState,
												 errorInfo: nil,
												 isLoggedIn: isUserLoggedIn)
				return entry
			case .failure:
				let devices: [DeviceDetails] = useCase.getCachedDevices() ?? []

				let entry = StationTimelineEntry(date: .now,
												 displaySize: displaySize,
												 id: station?.identifier,
												 devices: devices,
												 followState: followState,
												 errorInfo: nil,
												 isLoggedIn: isUserLoggedIn)

				return entry
		}
	}
}

struct Station_widgetEntryView: View {
    var entry: Provider.Entry
    var body: some View {
		StationWidgetView(entry: entry)
    }
}

struct Station_widget: Widget {
	let kind: String = "station_widget"

	var body: some WidgetConfiguration {
		IntentConfiguration(kind: kind,
							intent: StationWidgetConfigurationIntent.self,
							provider: Provider()) { entry in
			if #available(iOS 17.0, *) {
				Station_widgetEntryView(entry: entry)
			} else {
				Station_widgetEntryView(entry: entry)
			}
		}
							.configurationDisplayName(LocalizableString.Widget.widgetTitle.localized)
							.description(LocalizableString.Widget.widgetDescription.localized)
							.contentMarginsDisabled()
							.supportedFamilies([.systemSmall,
												.systemMedium,
												.systemLarge])
	}
}
