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

@MainActor
enum ViewModelsFactory {
    static func getStationDetailsViewModel(deviceId: String, cellIndex: String?, cellCenter: CLLocationCoordinate2D?) -> StationDetailsViewModel {
        StationDetailsViewModel(deviceId: deviceId, cellIndex: cellIndex, cellCenter: cellCenter, swinjectHelper: SwinjectHelper.shared)
    }

    static func getStationOverviewViewModel(device: DeviceDetails?, delegate: StationDetailsViewModelDelegate) -> OverviewViewModel {
        let vm = OverviewViewModel(device: device)
        vm.containerDelegate = delegate
        return vm
    }

    static func getStationForecastViewModel(delegate: StationDetailsViewModelDelegate) -> StationForecastViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCaseApi.self)
        let vm = StationForecastViewModel(useCase: useCase)
        vm.containerDelegate = delegate
        return vm
    }

    static func getStationRewardsViewModel(deviceId: String, delegate: StationDetailsViewModelDelegate) -> StationRewardsViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(RewardsUseCaseApi.self)
        return StationRewardsViewModel(deviceId: deviceId, containerDelegate: delegate, useCase: useCase)
    }

	static func getTransactionDetailsViewModel(device: DeviceDetails, followState: UserDeviceFollowState?) -> RewardsTimelineViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(RewardsTimelineUseCaseApi.self)
        return RewardsTimelineViewModel(device: device, followState: followState, useCase: useCase!)
    }

    static func getHistoryContainerViewModel(device: DeviceDetails) -> HistoryContainerViewModel {
        return HistoryContainerViewModel(device: device)
    }

    static func getHistoryViewModel(device: DeviceDetails, date: Date) -> HistoryViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(HistoryUseCaseApi.self)
        return HistoryViewModel(device: device, historyUseCase: useCase!, date: date)
    }

    static func getMyWalletViewModel() -> MyWalletViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCaseApi.self)
        return MyWalletViewModel(useCase: useCase)
    }

    static func getAnalyticsViewModel() -> AnalyticsViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(SettingsUseCaseApi.self)
        return AnalyticsViewModel(useCase: useCase!)
    }

    static func getAlertsViewModel(device: DeviceDetails, mainVM: MainScreenViewModel, followState: UserDeviceFollowState?) -> AlertsViewModel {
        let vm = AlertsViewModel(device: device, mainVM: mainVM, followState: followState)
        return vm
    }

    static func getNetworkStatsViewModel() -> NetworkStatsViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(NetworkUseCaseApi.self)
        return NetworkStatsViewModel(useCase: useCase)
    }

    static func getNetworkSearchViewModel() -> ExplorerSearchViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(NetworkUseCaseApi.self)
        return ExplorerSearchViewModel(useCase: useCase)
    }

    static func getExplorerStationsListViewModel(cellIndex: String, cellCenter: CLLocationCoordinate2D?) -> ExplorerStationsListViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(ExplorerUseCaseApi.self)
        let vm = ExplorerStationsListViewModel(useCase: useCase, cellIndex: cellIndex, cellCenter: cellCenter)
        return vm
    }

    static func getSettingsViewModel(userId: String) -> SettingsViewModel {
		let settingsUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(SettingsUseCaseApi.self)
		let authUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(AuthUseCaseApi.self)
        return SettingsViewModel(userId: userId, settingsUseCase: settingsUseCase!, authUseCase: authUseCase!)
    }

    static func getDeleteAccountViewModel(userId: String) -> DeleteAccountViewModel {
		let authUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(AuthUseCaseApi.self)
		let meUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCaseApi.self)
        return DeleteAccountViewModel(userId: userId, authUseCase: authUseCase!, meUseCase: meUseCase!)
    }

    static func getSignInViewModel() -> SignInViewModel {
		let authUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(AuthUseCaseApi.self)
        return SignInViewModel(authUseCase: authUseCase!)
    }

    static func getRegisterViewModel() -> RegisterViewModel {
		let authUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(AuthUseCaseApi.self)
		let mainUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MainUseCaseApi.self)
		return RegisterViewModel(authUseCase: authUseCase!, mainUseCase: mainUseCase!)
    }

    static func getResetPasswordViewModel() -> ResetPasswordViewModel {
		let authUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(AuthUseCaseApi.self)
        return ResetPasswordViewModel(authUseCase: authUseCase!)
    }

    static func getFilterViewModel() -> FilterViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(FiltersUseCaseApi.self)!
        return FilterViewModel(useCase: useCase)
    }

	static func getExplorerViewModel() -> ExplorerViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(ExplorerUseCaseApi.self)!
		return ExplorerViewModel(explorerUseCase: useCase)
	}

	static func getProfileViewModel() -> ProfileViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCaseApi.self)!
		let remoteConfigUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(RemoteConfigUseCaseApi.self)!
		return ProfileViewModel(meUseCase: useCase, remoteConfigUseCase: remoteConfigUseCase)
	}

	static func getWeatherStationsHomeViewModel() -> WeatherStationsHomeViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCaseApi.self)!
		let remoteConfigUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(RemoteConfigUseCaseApi.self)!
		let photoGalleryUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(PhotoGalleryUseCaseApi.self)!
		return WeatherStationsHomeViewModel(meUseCase: useCase,
											remoteConfigUseCase: remoteConfigUseCase,
											photosGalleryUseCase: photoGalleryUseCase)
	}

	static func getRewardDetailsViewModel(device: DeviceDetails,
										  followState: UserDeviceFollowState?,
										  date: Date) -> RewardDetailsViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(RewardsTimelineUseCaseApi.self)!
		return RewardDetailsViewModel(device: device, followState: followState, date: date, tokenUseCase: useCase)
	}

	static func getSelectLocationViewModel(device: DeviceDetails,
										   followState: UserDeviceFollowState?,
										   delegate: SelectStationLocationViewModelDelegate?) -> SelectStationLocationViewModel {
		let deviceLocationUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(DeviceLocationUseCaseApi.self)!
		let meUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCaseApi.self)!
		return SelectStationLocationViewModel(device: device, deviceLocationUseCase: deviceLocationUseCase, meUseCase: meUseCase, delegate: delegate)
	}

	static func getAppUpdateViewModel() -> AppUpdateViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MainUseCaseApi.self)!
		return AppUpdateViewModel(useCase: useCase)
	}

	static func getRewardAnnotationsViewModel(device: DeviceDetails,
											  annotations: [RewardAnnotation],
											  followState: UserDeviceFollowState?,
											  refDate: Date) -> RewardAnnotationsViewModel {
		return RewardAnnotationsViewModel(device: device, annotations: annotations, followState: followState, refDate: refDate)
	}

	static func getRewardsBoostViewModel(boost: NetworkDeviceRewardDetailsResponse.BoostReward, device: DeviceDetails, date: Date?) -> RewardBoostsViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(RewardsTimelineUseCaseApi.self)!
		return RewardBoostsViewModel(boost: boost, device: device, date: date, useCase: useCase)
	}

	static func getForecastDetailsViewModel(configuration: ForecastDetailsViewModel.Configuration) -> ForecastDetailsViewModel {
		ForecastDetailsViewModel(configuration: configuration)
	}

	static func getClaimStationSelectionViewModel() -> ClaimStationSelectionViewModel {
		ClaimStationSelectionViewModel()
	}

	static func getClaimStationContainerViewModel(type: ClaimStationType) -> ClaimDeviceContainerViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCaseApi.self)!
		let devicesUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(DevicesUseCaseApi.self)!
		let deviceLocationUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(DeviceLocationUseCaseApi.self)!

		switch type {
			case .m5:
				return ClaimM5ContainerViewModel(useCase: useCase, devicesUseCase: devicesUseCase, deviceLocationUseCase: deviceLocationUseCase)
			case .d1:
				return ClaimD1ContainerViewModel(useCase: useCase, devicesUseCase: devicesUseCase, deviceLocationUseCase: deviceLocationUseCase)
			case .helium:
				return ClaimHeliumContainerViewModel(useCase: useCase, devicesUseCase: devicesUseCase, deviceLocationUseCase: deviceLocationUseCase)
			case .pulse:
				return ClaimPulseContainerViewModel(useCase: useCase, devicesUseCase: devicesUseCase, deviceLocationUseCase: deviceLocationUseCase)
		}
	}

	static func getClaimBeforeBeginViewModel(completion: @escaping VoidCallback) -> ClaimDeviceBeforeBeginViewModel {
		ClaimDeviceBeforeBeginViewModel(completion: completion)
	}

	static func getClaimHeliumBeforeBeginViewModel(completion: @escaping VoidCallback) -> ClaimDeviceHeliumBeforeBeginViewModel {
		ClaimDeviceHeliumBeforeBeginViewModel(completion: completion)
	}
	
	static func getClaimDevicePhotoViewModel(completion: @escaping VoidCallback) -> ClaimDevicePhotoIntroViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(PhotoGalleryUseCaseApi.self)!
		let viewModel = ClaimDevicePhotoIntroViewModel(deviceId: "", images: [], photoGalleryUseCase: useCase)
		viewModel.completion = completion
		return viewModel
	}

	static func getClaimStationBeginViewModel(completion: @escaping VoidCallback) -> ClaimDeviceBeginViewModel {
		ClaimDeviceBeginViewModel(completion: completion)
	}

	static func getClaimStationM5BeginViewModel(completion: @escaping VoidCallback) -> ClaimDeviceM5BeginViewModel {
		ClaimDeviceM5BeginViewModel(completion: completion)
	}

	static func getResetPulseViewModel(completion: @escaping VoidCallback) -> ResetDevicePulseViewModel {
		ResetDevicePulseViewModel(completion: completion)
	}

	static func getClaimStationSNViewModel(completion: @escaping GenericCallback<ClaimDeviceSerialNumberViewModel.SerialNumber?>) -> ClaimDeviceSerialNumberViewModel {
		ClaimDeviceSerialNumberViewModel(completion: completion)
	}

	static func getClaimStationM5SNViewModel(completion: @escaping GenericCallback<ClaimDeviceSerialNumberViewModel.SerialNumber?>) -> ClaimDeviceSerialNumberM5ViewModel {
		ClaimDeviceSerialNumberM5ViewModel(completion: completion)
	}

	static func getClaimStationPulseSNViewModel(completion: @escaping GenericCallback<ClaimDeviceSerialNumberViewModel.SerialNumber?>) -> ClaimDeviceSerialNumberPulseViewModel {
		ClaimDeviceSerialNumberPulseViewModel(completion: completion)
	}

	static func getManualSNViewModel(completion: @escaping GenericCallback<[InputFieldResult]>) -> ManualSerialNumberViewModel {
		ManualSerialNumberViewModel(completion: completion)
	}

	static func getManualSNM5ViewModel(completion: @escaping GenericCallback<[InputFieldResult]>) -> ManualSerialNumberM5ViewModel {
		ManualSerialNumberM5ViewModel(completion: completion)
	}

	static func getManualSNPulseViewModel(completion: @escaping GenericCallback<[InputFieldResult]>) -> ManualSerialNumberPulseViewModel {
		ManualSerialNumberPulseViewModel(completion: completion)
	}

	static func getClaimingKeyPulseViewModel(completion: @escaping GenericCallback<[InputFieldResult]>) -> ClaimingKeyPulseViewModel {
		ClaimingKeyPulseViewModel(completion: completion)
	}

	static func getLocationMapViewModel(initialCoordinate: CLLocationCoordinate2D? = nil) -> SelectLocationMapViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(DeviceLocationUseCaseApi.self)!
		return SelectLocationMapViewModel(useCase: useCase, initialCoordinate: initialCoordinate)
	}

	static func getClaimDeviceLocationViewModel(completion: @escaping GenericCallback<DeviceLocation>) -> ClaimDeviceLocationViewModel {
		ClaimDeviceLocationViewModel(completion: completion)
	}

	static func getResetDeviceViewModel(completion: @escaping VoidCallback) -> ResetDeviceViewModel {
		ResetDeviceViewModel(completion: completion)
	}

	static func getSelectDeviceViewModel(useCase: DevicesUseCaseApi = SwinjectHelper.shared.getContainerForSwinject().resolve(DevicesUseCaseApi.self)!,
										 completion: @escaping GenericCallback<(BTWXMDevice?, BluetoothHeliumError?)>) -> SelectDeviceViewModel {
		return SelectDeviceViewModel(useCase: useCase, completion: completion)
	}

	static func getClaimDeviceSetFrequncyViewModel(completion: @escaping GenericCallback<Frequency>) -> ClaimDeviceSetFrequencyViewModel {
		return ClaimDeviceSetFrequencyViewModel(completion: completion)
	}

	static func getChangeFrequencyViewModel(device: DeviceDetails, frequency: Frequency? = Frequency.allCases.first) -> ChangeFrequencyViewModel {
		let deviceInfoUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(DeviceInfoUseCaseApi.self)!
		let meUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCaseApi.self)!
		return ChangeFrequencyViewModel(device: device,
										useCase: deviceInfoUseCase,
										meUseCase: meUseCase,
										frequency: frequency)
	}

	static func getRewardAnalyticsViewModel(devices: [DeviceDetails]) -> RewardAnalyticsViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MeUseCaseApi.self)!
		return RewardAnalyticsViewModel(useCase: useCase, devices: devices)
	}

	static func getPhotoIntroViewModel(deviceId: String, images: [String]) -> PhotoIntroViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(PhotoGalleryUseCaseApi.self)!
		return PhotoIntroViewModel(deviceId: deviceId, images: images, photoGalleryUseCase: useCase)
	}

	static func getPhotoInstructionsViewModel(deviceId: String) -> PhotoInstructionsViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(PhotoGalleryUseCaseApi.self)!
		return PhotoInstructionsViewModel(deviceId: deviceId, images: [], photoGalleryUseCase: useCase)
	}

	static func getGalleryViewModel(deviceId: String, images: [String], isNewVerification: Bool) -> GalleryViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(PhotoGalleryUseCaseApi.self)!
		return GalleryViewModel(deviceId: deviceId,
								images: images,
								photoGalleryUseCase: useCase,
								isNewPhotoVerification: isNewVerification)
	}

	static func getPhotoVerificationStateViewModel(deviceId: String) -> PhotoVerificationStateViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(DeviceInfoUseCaseApi.self)!
		let photoGalleryUseCase = SwinjectHelper.shared.getContainerForSwinject().resolve(PhotoGalleryUseCaseApi.self)!
		return PhotoVerificationStateViewModel(deviceId: deviceId, deviceInfoUseCase: useCase, photoGalleryUseCase: photoGalleryUseCase)
	}

	static func getDeviceInfoViewModel(device: DeviceDetails, followState: UserDeviceFollowState?) -> DeviceInfoViewModel {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(DeviceInfoUseCaseApi.self)!
		return DeviceInfoViewModel(device: device, followState: followState, useCase: useCase)
	}

	static func getProPromotionalViewModel() -> ProPromotionalViewModel {
		return ProPromotionalViewModel()
	}
}
