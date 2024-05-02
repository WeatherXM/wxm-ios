//
//  ViewModelsFactory.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/23.
//

import Foundation
import DomainLayer
import CoreLocation
import Toolkit

protocol HashableViewModel: AnyObject, Hashable {}

extension HashableViewModel {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs === rhs
    }
}

enum ViewModelsFactory {
    static func getStationDetailsViewModel(deviceId: String, cellIndex: String?, cellCenter: CLLocationCoordinate2D?) -> StationDetailsViewModel {
        StationDetailsViewModel(deviceId: deviceId, cellIndex: cellIndex, cellCenter: cellCenter, swinjectHelper: SwinjectHelper.shared)
    }

    static func getCurrentWeatherObservationsViewModel(device: DeviceDetails?, delegate: StationDetailsViewModelDelegate) -> ObservationsViewModel {
        let vm = ObservationsViewModel(device: device)
        vm.containerDelegate = delegate
        return vm
    }

    static func getStationForecastViewModel(delegate: StationDetailsViewModelDelegate) -> StationForecastViewModel {
        let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCase.self)
        let vm = StationForecastViewModel(useCase: useCase)
        vm.containerDelegate = delegate
        return vm
    }

    static func getStationRewardsViewModel(deviceId: String, delegate: StationDetailsViewModelDelegate) -> StationRewardsViewModel {
        let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(RewardsUseCase.self)
        return StationRewardsViewModel(deviceId: deviceId, containerDelegate: delegate, useCase: useCase)
    }

	static func getTransactionDetailsViewModel(device: DeviceDetails, followState: UserDeviceFollowState?) -> RewardsTimelineViewModel {
        let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(RewardsTimelineUseCase.self)
        return RewardsTimelineViewModel(device: device, followState: followState, useCase: useCase!)
    }

    static func getHistoryContainerViewModel(device: DeviceDetails) -> HistoryContainerViewModel {
        let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(HistoryUseCase.self)
        return HistoryContainerViewModel(device: device, historyUseCase: useCase!)
    }

    static func getHistoryViewModel(device: DeviceDetails, date: Date) -> HistoryViewModel {
        let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(HistoryUseCase.self)
        return HistoryViewModel(device: device, historyUseCase: useCase!, date: date)
    }

    static func getMyWalletViewModel() -> MyWalletViewModel {
        let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCase.self)
        return MyWalletViewModel(useCase: useCase)
    }

    static func getAnalyticsViewModel() -> AnalyticsViewModel {
        let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(SettingsUseCase.self)
        return AnalyticsViewModel(useCase: useCase!)
    }

    static func getAlertsViewModel(device: DeviceDetails, mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> AlertsViewModel {
        let vm = AlertsViewModel(device: device, mainVM: mainVM, followState: followState)
        return vm
    }

    static func getNetworkStatsViewModel() -> NetworkStatsViewModel {
        let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(NetworkUseCase.self)
        return NetworkStatsViewModel(useCase: useCase)
    }

    static func getNetworkSearchViewModel() -> ExplorerSearchViewModel {
        let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(NetworkUseCase.self)
        return ExplorerSearchViewModel(useCase: useCase)
    }

    static func getExplorerStationsListViewModel(cellIndex: String, cellCenter: CLLocationCoordinate2D?) -> ExplorerStationsListViewModel {
        let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(ExplorerUseCase.self)
        let vm = ExplorerStationsListViewModel(useCase: useCase, cellIndex: cellIndex, cellCenter: cellCenter)
        return vm
    }

    static func getSettingsViewModel(userId: String) -> SettingsViewModel {
        let settingsUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(SettingsUseCase.self)
        return SettingsViewModel(userId: userId, settingsUseCase: settingsUseCase!)
    }

    static func getDeleteAccountViewModel(userId: String) -> DeleteAccountViewModel {
        let authUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(AuthUseCase.self)
        let meUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCase.self)
        let keychainUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(KeychainUseCase.self)
		let settingsUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(SettingsUseCase.self)
        return DeleteAccountViewModel(userId: userId, authUseCase: authUseCase!, meUseCase: meUseCase!, keychainUseCase: keychainUseCase!, settingsUseCase: settingsUseCase!)
    }

    static func getSignInViewModel() -> SignInViewModel {
        let authUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(AuthUseCase.self)
        let keyChainUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(KeychainUseCase.self)
        return SignInViewModel(authUseCase: authUseCase!, keychainUseCase: keyChainUseCase!)
    }

    static func getRegisterViewModel() -> RegisterViewModel {
        let authUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(AuthUseCase.self)
        return RegisterViewModel(authUseCase: authUseCase!)
    }

    static func getResetPasswordViewModel() -> ResetPasswordViewModel {
        let authUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(AuthUseCase.self)
        return ResetPasswordViewModel(authUseCase: authUseCase!)
    }

    static func getFilterViewModel() -> FilterViewModel {
        let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(FiltersUseCase.self)!
        return FilterViewModel(useCase: useCase)
    }

	static func getExplorerViewModel() -> ExplorerViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(ExplorerUseCase.self)!
		return ExplorerViewModel(explorerUseCase: useCase)
	}

	static func getProfileViewModel() -> ProfileViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCase.self)!
		return ProfileViewModel(meUseCase: useCase)
	}

	static func getClaimDeviceViewModel() -> ClaimDeviceViewModel {
		let devicesUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(DevicesUseCase.self)!
		let deviceLocationUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(DeviceLocationUseCase.self)!
		let meUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCase.self)!
		return ClaimDeviceViewModel(devicesUseCase: devicesUseCase, deviceLocationUseCase: deviceLocationUseCase, meUseCase: meUseCase)
	}

	static func getWeatherStationsHomeViewModel() -> WeatherStationsHomeViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCase.self)!
		return WeatherStationsHomeViewModel(meUseCase: useCase)
	}

	static func getRewardDetailsViewModel(device: DeviceDetails,
										  followState: UserDeviceFollowState?,
										  date: Date) -> RewardDetailsViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(RewardsTimelineUseCase.self)!
		return RewardDetailsViewModel(device: device, followState: followState, date: date, tokenUseCase: useCase)
	}

	static func getSelectLocationViewModel(device: DeviceDetails,
										   followState: UserDeviceFollowState?,
										   delegate: SelectStationLocationViewModelDelegate?) -> SelectStationLocationViewModel {
		let deviceLocationUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(DeviceLocationUseCase.self)!
		let meUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCase.self)!
		return SelectStationLocationViewModel(device: device, deviceLocationUseCase: deviceLocationUseCase, meUseCase: meUseCase, delegate: delegate)
	}

	static func getAppUpdateViewModel() -> AppUpdateViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MainUseCase.self)!
		return AppUpdateViewModel(useCase: useCase)
	}

	static func getRewardAnnotationsViewModel(device: DeviceDetails,
											  annotations: [RewardAnnotation],
											  followState: UserDeviceFollowState?,
											  refDate: Date) -> RewardAnnotationsViewModel {
		return RewardAnnotationsViewModel(device: device, annotations: annotations, followState: followState, refDate: refDate)
	}

	static func getRewardsBoostViewModel(boost: NetworkDeviceRewardDetailsResponse.BoostReward, device: DeviceDetails, date: Date?) -> RewardBoostsViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(RewardsTimelineUseCase.self)!
		return RewardBoostsViewModel(boost: boost, device: device, date: date, useCase: useCase)
	}

	static func getForecastDetailsViewModel(configuration: ForecastDetailsViewModel.Configuration) -> ForecastDetailsViewModel {
		ForecastDetailsViewModel(configuration: configuration)
	}

	static func getClaimStationSelectionViewModel() -> ClaimStationSelectionViewModel {
		ClaimStationSelectionViewModel()
	}

	static func getClaimStationContainerViewModel(type: ClaimStationType) -> ClaimDeviceContainerViewModel {
		ClaimDeviceContainerViewModel(type: type)
	}

	static func getClaimStationBeginViewModel(completion: @escaping VoidCallback) -> ClaimDeviceBeginViewModel {
		ClaimDeviceBeginViewModel(completion: completion)
	}

	static func getClaimStationM5BeginViewModel(completion: @escaping VoidCallback) -> ClaimDeviceM5BeginViewModel {
		ClaimDeviceM5BeginViewModel(completion: completion)
	}

	static func getClaimStationSNViewModel(completion: @escaping VoidCallback) -> ClaimDeviceSerialNumberViewModel {
		ClaimDeviceSerialNumberViewModel()
	}

	static func getClaimStationM5SNViewModel(completion: @escaping VoidCallback) -> ClaimDeviceSerialNumberM5ViewModel {
		ClaimDeviceSerialNumberM5ViewModel()
	}
}
