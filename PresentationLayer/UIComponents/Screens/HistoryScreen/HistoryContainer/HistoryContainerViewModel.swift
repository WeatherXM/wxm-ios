//
//  HistoryContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/9/23.
//

import Foundation
import Combine
import DomainLayer
import Toolkit

class HistoryContainerViewModel: ObservableObject {

    private let SEVEN_DAYS_OFFSET = 6
    let historyDates: DateRange
    let device: DeviceDetails

    @Published var currentDate: Date

	init(device: DeviceDetails) {
        self.device = device
        let epoch = device.claimedAt?.timestampToDate() ?? .now.advancedByDays(days: -SEVEN_DAYS_OFFSET)
        let offset = Date.now.days(from: epoch)
        self.historyDates = DateRange(epoch: epoch,
                                      values: 0...offset)
        self.currentDate = historyDates.last!
    }

    func handleDateTap(date: Date) {
        guard let deviceId = device.id else {
            return
        }
		WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .historyDay,
																	.itemId: .custom(deviceId),
																	.date: .custom(date.getFormattedDate(format: .onlyDate))])

        // Prevent unecessary UI refreshes
        guard currentDate != date else {
            return
        }

        currentDate = date
    }
}

extension HistoryContainerViewModel: HashableViewModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(device.id)
    }
}
