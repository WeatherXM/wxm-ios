//
//  HistoryViewModel.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 31/8/22.
//

import Combine
import DomainLayer

public final class HistoryViewModel: ObservableObject {
    private final let historyUseCase: HistoryUseCase
    private final let SEVEN_DAYS_OFFSET = 7

    @Published var loadingData: Bool = true
    let historyDates: [Date]
    @Published var currentDate: Date?
    @Published var currentHistoryData: HistoryChartModels?
    @Published var noAvailableData: Bool = false

    init(historyUseCase: HistoryUseCase) {
        self.historyUseCase = historyUseCase
        let dates = Array((0...SEVEN_DAYS_OFFSET).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: Date.now) }.reversed())
        self.historyDates = dates
    }

    func getNoDataDateFormat() -> String {
        if let historyDataDate = currentHistoryData?.markDate {
            return historyDataDate.getFormattedDate(format: .monthLiteralDayYear)
        } else {
            return ""
        }
    }

    func handleDateTap(deviceId: String, date: Date) {
        currentDate = date
        getHistoricalChartsData(deviceId: deviceId, date: date)
    }
}

private extension HistoryViewModel {
    func getHistoricalChartsData(deviceId: String?, date: Date) {
        guard let deviceId = deviceId else {
            return
        }

        loadingData = true
        historyUseCase.getWeatherHourlyHistory(deviceId: deviceId, date: date) { [weak self] result in
            guard let self else {
                return
            }

            self.loadingData = false
            switch result {
                case let .success(historicalModels):
                    self.currentHistoryData = historicalModels
                case let .failure(error):
                    print(error)
                    self.noAvailableData = true
            }
        }
    }
}
