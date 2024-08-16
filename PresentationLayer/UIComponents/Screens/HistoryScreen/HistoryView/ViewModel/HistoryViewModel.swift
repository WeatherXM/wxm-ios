//
//  HistoryViewModel.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 31/8/22.
//

import Combine
import DomainLayer
import Toolkit

class HistoryViewModel: ObservableObject {
    private let historyUseCase: HistoryUseCase

    @Published var loadingData: Bool = true
    @Published var currentHistoryData: WeatherChartModels?
    @Published var noAvailableData: Bool = false
    @Published var isFailed: Bool = false
    private(set) var failObj: FailSuccessStateObject?
    @Published private(set) var chartDelegate: ChartDelegate = ChartDelegate()
    private var cancellableSet: Set<AnyCancellable> = []
    private let chartsFactory = ChartsFactory()
    let device: DeviceDetails
    let currentDate: Date

    init(device: DeviceDetails, historyUseCase: HistoryUseCase, date: Date) {
        self.device = device
        self.historyUseCase = historyUseCase
        self.currentDate = date
    }

    func getNoDataDateFormat() -> String {
        return currentDate.getFormattedDate(format: .monthLiteralDayYear).capitalized
    }

    func refresh(force: Bool = true, showFullScreenLoader: Bool = false, completion: @escaping VoidCallback) {
        guard let deviceId = device.id else {
            completion()
            return
        }
        getHistoricalChartsData(deviceId: deviceId,
                                date: currentDate,
                                force: force,
                                showFullScreenLoader: showFullScreenLoader,
                                completion: completion)
    }
}

extension HistoryViewModel: HashableViewModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(device.id)
    }
}

private extension HistoryViewModel {
    func getHistoricalChartsData(deviceId: String?, date: Date, force: Bool, showFullScreenLoader: Bool, completion: VoidCallback? = nil) {
        guard let deviceId = deviceId else {
            completion?()
            return
        }

        /// Prevent from showing full screen loader in case of  pull to refresh
        loadingData = showFullScreenLoader
        isFailed = false
        do {
            try historyUseCase.getWeatherHourlyHistory(deviceId: deviceId,
                                                       date: date,
                                                       force: force).sink { [weak self] response in
                completion?()
                self?.loadingData = false
                
                if let error = response.error {
                    let info = error.uiInfo
                    let obj = info.defaultFailObject(type: .history) {
                        self?.isFailed = false
                        self?.getHistoricalChartsData(deviceId: deviceId, date: date, force: force, showFullScreenLoader: true)
                    }
                    self?.failObj = obj
                    self?.isFailed = true

                    return
                }

                self?.handleHistoryResponse(historicalData: response.value)
            }.store(in: &cancellableSet)
        } catch {}
    }

    func handleHistoryResponse(historicalData: [NetworkDeviceHistoryResponse]?) {
        guard let hourlyWeatherData: [CurrentWeather] = historicalData?.reduce(into: [], { accumulator, forecastResponse in
            if let hourlyData = forecastResponse.hourly {
                accumulator.append(contentsOf: hourlyData)
            }}),
			  let date = hourlyWeatherData.first?.timestamp?.timestampToDate()
        else {
            currentHistoryData = nil
            return
        }

        let timeZone = TimeZone(identifier: historicalData?.first?.tz ?? "") ?? .current
		let chartModels = chartsFactory.createHourlyCharts(timeZone: timeZone, startingDate: date.startOfDay(timeZone: timeZone), hourlyWeatherData: hourlyWeatherData)
        currentHistoryData = chartModels
        generateDelegate()
    }

    func generateDelegate() {
        guard let currentHistoryData else {
            return
        }
        let delegate = ChartDelegate()
		let values = currentHistoryData.dataModels.values

		let isToday = currentDate.isToday
		let count = values.first?.entries.count ?? 0
		var index: Int?
		if isToday { // If is today we should preselect the latest valid index
			for dataModel in values {
				guard let lastIndex = dataModel.entries.lastIndex(where: { !$0.y.isNaN }) else {
					continue
				}

				index = max(index ?? lastIndex, lastIndex)
				
				// If is already the min value set, there is no need to proceed the iteration
				if index == 0 {
					break
				}
			}
		} else { // Otherwise, we should preselect the first valid index
			for dataModel in values {
				guard let firstIndex = dataModel.entries.firstIndex(where: { !$0.y.isNaN }) else {
					continue
				}

				index = max(index ?? firstIndex, firstIndex)

				// If is already the max value set, there is no need to proceed the iteration
				if index == count - 1 {
					break
				}
			}
		}

        delegate.selectedIndex = index
        self.chartDelegate = delegate
    }
}
