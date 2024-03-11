//
//  ExplorerStationsListViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 23/6/23.
//

import Combine
import DomainLayer
import CoreLocation
import Toolkit
import UIKit

class ExplorerStationsListViewModel: ObservableObject {

    @Published var isLoadingDeviceList: Bool = false
    @Published var isDeviceListFailVisible: Bool = false
    @Published var showLoginAlert: Bool = false
    @Published var devices = [DeviceDetails]()
    @Published var address: String?
    @Published private(set) var userDeviceFolowStates: [UserDeviceFollowState] = []
	@Published var showInfo: Bool = false
	private(set) var info: BottomSheetInfo?
    var deviceListFailObject: FailSuccessStateObject?
    var alertConfiguration: WXMAlertConfiguration?
	var activeStationsString: String? {
		let count = devices.filter { $0.isActive }.count
		guard count > 0 else {
			return nil
		}

		return count == 1 ? LocalizableString.activeStation(count).localized : LocalizableString.activeStations(count).localized
	}
	var stationsCountString: String {
		let count = devices.count

		return LocalizableString.presentStations(count).localized
	}
	var cellShareUrl: String {
		DisplayedLinks.shareCells.linkURL + cellIndex
	}

    let cellIndex: String
    private let useCase: ExplorerUseCase?
    private let cellCenter: CLLocationCoordinate2D
    private var cancellableSet: Set<AnyCancellable> = .init()

    init(useCase: ExplorerUseCase?, cellIndex: String, cellCenter: CLLocationCoordinate2D) {
        self.useCase = useCase
        self.cellIndex = cellIndex
        self.cellCenter = cellCenter
        fetchDeviceList()

        useCase?.userDevicesListChangedPublisher.sink { [weak self] _ in
            self?.refreshFollowStates()
        }.store(in: &cancellableSet)
    }

    func navigateToDeviceDetails(_ device: DeviceDetails) {
        guard let cellIndex = device.cellIndex,
              let deviceId = device.id else {
            return
        }

        Router.shared.navigateTo(.stationDetails(ViewModelsFactory.getStationDetailsViewModel(deviceId: deviceId, cellIndex: cellIndex, cellCenter: cellCenter)))
    }

    func signupButtonTapped() {
        showLoginAlert = false
        Router.shared.navigateTo(.register(ViewModelsFactory.getRegisterViewModel()))
    }
    
    func followButtonTapped(device: DeviceDetails) {
        guard let deviceId = device.id else {
            return
        }

        guard MainScreenViewModel.shared.isUserLoggedIn else {
            showLogin(device: device)
            return
        }

        let followState = userDeviceFolowStates.first(where: { $0.deviceId == deviceId})
        if followState?.relation == .followed {
            Logger.shared.trackEvent(.userAction, parameters: [.actionName: .explorerDevicesListFollow,
                                                               .contentType: .unfollow])

            performUnfollow(device: device)
        } else {
            Logger.shared.trackEvent(.userAction, parameters: [.actionName: .explorerDevicesListFollow,
                                                               .contentType: .follow])

            performFollow(device: device)
        }
    }

    func performFollow(device: DeviceDetails) {
        guard let deviceId = device.id else {
            return
        }

        let followAction = { [weak self] in
            guard let self else {
                return
            }
            LoaderView.shared.show()
            Task {
                guard let result = try await self.useCase?.followStation(deviceId: deviceId) else {
                    return
                }

                DispatchQueue.main.async {
                    LoaderView.shared.dismiss {
                        self.handleFollowResult(result)
                    }
                }
            }
        }

        if device.isActive == false {
            let title = LocalizableString.followAlertTitle.localized
            let description = LocalizableString.followAlertDescription(device.name).localized
            let okAction: AlertHelper.AlertObject.Action = (LocalizableString.confirm.localized, { _ in followAction() })
            let obj = AlertHelper.AlertObject(title: title,
                                              message: description,
                                              okAction: okAction)
            AlertHelper().showAlert(obj)

        } else {
            followAction()
        }
    }

    func performUnfollow(device: DeviceDetails) {
        guard let deviceId = device.id else {
            return
        }

        let okAction: AlertHelper.AlertObject.Action = (LocalizableString.confirm.localized, { _ in
            LoaderView.shared.show()
            Task { [weak self] in
                guard let self,
                      let result = try await useCase?.unfollowStation(deviceId: deviceId) else {
                    return
                }

                DispatchQueue.main.async {
                    LoaderView.shared.dismiss {
                        self.handleFollowResult(result)
                    }
                }
            }
        })

        let title = LocalizableString.unfollowAlertTitle.localized
        let description = LocalizableString.unfollowAlertDescription(device.name).localized
        let obj = AlertHelper.AlertObject(title: title,
                                          message: description,
                                          okAction: okAction)
        AlertHelper().showAlert(obj)
    }

    func handleFollowResult(_ result: Result<EmptyEntity, NetworkErrorResponse>) {
        switch result {
            case .success:
                self.refreshFollowStates()
            case .failure(let error):
                let info = error.uiInfo
                DispatchQueue.main.async {
                    Toast.shared.show(text: info.description?.attributedMarkdown ?? "")
                }
        }
    }

    func getFollowState(for device: DeviceDetails) -> UserDeviceFollowState? {
        userDeviceFolowStates.first(where: { $0.deviceId == device.id })
    }

    func showLogin(device: DeviceDetails) {
        alertConfiguration = generateLoginAlertConfiguration(device: device)
        showLoginAlert = true
    }

	func handleCellCapacityInfoTap() {
		let info = BottomSheetInfo(title: LocalizableString.ExplorerList.cellCapacity.localized,
								   description: LocalizableString.ExplorerList.cellCapacityDescription.localized,
								   scrollable: true,
								   buttonTitle: LocalizableString.RewardDetails.readMore.localized) {
			guard let url = URL(string: DisplayedLinks.cellCapacity.linkURL) else {
				return
			}

			UIApplication.shared.open(url)
		}
		self.info = info
		showInfo = true
	}
}

private extension ExplorerStationsListViewModel {
    func fetchDeviceList() {
        isDeviceListFailVisible = false
        isLoadingDeviceList = true
        useCase?.getPublicDevicesOfHexIndex(hexIndex: cellIndex, hexCoordinates: cellCenter) { [weak self] result in
            guard let self else {
                return
            }

            DispatchQueue.main.async {
                switch result {
                    case let .success(devices):
                        self.devices = devices.sortedByCriteria(criterias: [ { $0.lastActiveAt.stringToDate() > $1.lastActiveAt.stringToDate() }, { $0.name > $1.name }])
                        self.address = devices.first?.address
                        self.refreshFollowStates()
                    case let .failure(error):
                        print(error)
                        self.updateDeviceListFailObj(error: error) {
                            self.isDeviceListFailVisible = false
                            self.fetchDeviceList()
                        }
                }
                self.isLoadingDeviceList = false
            }
        }
    }

    func generateLoginAlertConfiguration(device: DeviceDetails) -> WXMAlertConfiguration {
        let conf = WXMAlertConfiguration(title: LocalizableString.favoritesloginAlertTitle.localized,
                                         text: LocalizableString.favoritesloginAlertText(device.name).localized.attributedMarkdown ?? "",
                                         primaryButtons: [.init(title: LocalizableString.signIn.localized, action: { Router.shared.navigateTo(.signIn(ViewModelsFactory.getSignInViewModel())) })])
        return conf
    }
}

private extension ExplorerStationsListViewModel {
    func updateDeviceListFailObj(error: PublicHexError, retryAction: @escaping VoidCallback) {
        var description: String?
        switch error {
            case .infrastructure, .serialization:
                description = LocalizableString.emptyGenericDescription.localized
            case .networkRelated(let networkErrorResponse):
                description = networkErrorResponse?.uiInfo.description
        }

        let obj = FailSuccessStateObject(type: .explorerDeviceList,
                                         title: LocalizableString.emptyGenericTitle.localized,
                                         subtitle: description?.attributedMarkdown,
                                         cancelTitle: nil,
                                         retryTitle: LocalizableString.retry.localized,
                                         contactSupportAction: {
			HelperFunctions().openContactSupport(successFailureEnum: .explorerDeviceList,
												 email: nil,
												 serialNumber: nil,
												 trackSelectContentEvent: true)

        }, cancelAction: nil, retryAction: retryAction)

        deviceListFailObject = obj
        isDeviceListFailVisible = true
    }

    func refreshFollowStates() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.userDeviceFolowStates = await self.devices.asyncCompactMap { device in
                guard let deviceId = device.id else {
                    return nil
                }
                return try? await self.useCase?.getDeviceFollowState(deviceId: deviceId).get()
            }
        }
    }
}

extension ExplorerStationsListViewModel: HashableViewModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(cellIndex)
    }
}
