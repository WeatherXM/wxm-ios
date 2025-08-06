//
//  SwinjectHelper.swift
//  wxm-ios
//
//  Created by Hristos Condrea on 6/5/22.
//

@preconcurrency import DataLayer
@preconcurrency import DomainLayer
import Foundation
@preconcurrency import Swinject
import Toolkit

class SwinjectHelper: SwinjectInterface {
	nonisolated(unsafe) static let shared = SwinjectHelper()

    private init() {}

    let swinjectContainer: Container = {
        // MARK: - We create a Container in order to register all of our DI.

        let container = Container()

		container.register(UserInfoService.self) { _ in
			UserInfoService()
		}
		.inObjectScope(.container)

		container.register(UserDefaultsService.self) { _ in
			UserDefaultsService()
		}

		container.register(GeocoderProtocol.self) { _ in
			Geocoder()
		}

		container.register(UserDevicesService.self) { resolver in
			UserDevicesService(followStatesCacheManager: resolver.resolve(UserDefaultsService.self)!,
							   userDevicesCacheManager: resolver.resolve(UserDefaultsService.self)!)
		}
		.inObjectScope(.container)

		container.register(MainRepository.self) { _ in
			MainRepositoryImpl()
		}

        // MARK: - Settings

        container.register(SettingsRepository.self) { _ in
            SettingsRepositoryImpl()
        }

		container.register(SettingsUseCaseApi.self) { resolver in
            SettingsUseCase(repository: resolver.resolve(SettingsRepository.self)!)
        }

        // MARK: - Network

        container.register(NetworkRepository.self) { _ in
            NetworkRepositoryImpl()
        }

		container.register(NetworkUseCaseApi.self) { resolver in
            NetworkUseCase(repository: resolver.resolve(NetworkRepository.self)!)
        }

        // MARK: - Devices DI

        container.register(DevicesRepository.self) { _ in
            DevicesRepositoryImpl()
        }
        container.register(BluetoothDevicesRepository.self) { _ in
            BluetoothDevicesRepositoryImpl()
        }
		container.register(DevicesUseCaseApi.self) { resolver in
            let devicesUseCase = DevicesUseCase(
                devicesRepository: resolver.resolve(DevicesRepository.self)!,
                bluetoothDevicesRepository: resolver.resolve(BluetoothDevicesRepository.self)!
            )

            return devicesUseCase
        }
        container.register(DeviceLocationRepository.self) { _ in
            DeviceLocationRepositoryImpl()
        }
		container.register(DeviceLocationUseCaseApi.self) { resolver in
            DeviceLocationUseCase(deviceLocationRepository: resolver.resolve(DeviceLocationRepository.self)!)
        }

        // MARK: - Device info DI
        container.register(DeviceInfoRepository.self) { resolver in
            DeviceInfoRepositoryImpl(userDevicesService: resolver.resolve(UserDevicesService.self)!)
        }
		container.register(DeviceInfoUseCaseApi.self) { resolver in
            DeviceInfoUseCase(repository: resolver.resolve(DeviceInfoRepository.self)!)
        }
        // MARK: - Cells DI

        container.register(ExplorerRepository.self) { _ in
            ExplorerRepositoryImpl()
        }

		container.register(ExplorerUseCaseApi.self) { resolver in
            let explorerUserCase = ExplorerUseCase(explorerRepository: resolver.resolve(ExplorerRepository.self)!,
                                                   devicesRepository: resolver.resolve(DevicesRepository.self)!,
                                                   meRepository: resolver.resolve(MeRepository.self)!,
												   deviceLocationRepository: resolver.resolve(DeviceLocationRepository.self)!,
												   geocoder: resolver.resolve(GeocoderProtocol.self)!)
            return explorerUserCase
        }

        // MARK: - Me DI

        container.register(MeRepository.self) { resolver in
			MeRepositoryImpl(userDevicesService: resolver.resolve(UserDevicesService.self)!,
							 userInfoService: resolver.resolve(UserInfoService.self)!)
        }

        container.register(UserDefaultsRepository.self) { _ in
            UserDefaultsRepositoryImp()
        }

        container.register(FiltersService.self) { resolver in
			FiltersService(cacheManager: resolver.resolve(UserDefaultsService.self)!)
        }
        .inObjectScope(.container)

        container.register(FiltersRepository.self) { resolver in
            FiltersRepositoryImpl(filtersService: resolver.resolve(FiltersService.self)!)
        }

		container.register(MeUseCaseApi.self) { resolver in
            MeUseCase(meRepository: resolver.resolve(MeRepository.self)!,
					  filtersRepository: resolver.resolve(FiltersRepository.self)!,
					  networkRepository: resolver.resolve(NetworkRepository.self)!,
					  userDefaultsrRepository: resolver.resolve(UserDefaultsRepository.self)!)
        }

		container.register(RewardsTimelineUseCaseApi.self) { resolver in
			RewardsTimelineUseCase(repository: resolver.resolve(DevicesRepository.self)!, meRepository: resolver.resolve(MeRepository.self)!)
        }

		container.register(HistoryUseCaseApi.self) { resolver in
            HistoryUseCase(meRepository: resolver.resolve(MeRepository.self)!)
        }

        // MARK: - Keychain DI

        container.register(KeychainRepository.self) { _ in
            KeychainRepositoryImpl()
        }

        // MARK: - Main Use Case

		container.register(MainUseCaseApi.self) { resolver in
			MainUseCase(mainRepository: resolver.resolve(MainRepository.self)!,
						userDefaultsRepository: resolver.resolve(UserDefaultsRepository.self)!,
						keychainRepository: resolver.resolve(KeychainRepository.self)!,
						meRepository: resolver.resolve(MeRepository.self)!)
        }
		.inObjectScope(.container)

        // MARK: - Device Details Use Case

		container.register(DeviceDetailsUseCaseApi.self) { resolver in
            DeviceDetailsUseCase(meRepository: resolver.resolve(MeRepository.self)!,
                                 explorerRepository: resolver.resolve(ExplorerRepository.self)!,
                                 keychainRepository: resolver.resolve(KeychainRepository.self)!,
								 userDefaultsRepository: resolver.resolve(UserDefaultsRepository.self)!,
								 geocoder: resolver.resolve(GeocoderProtocol.self)!)
        }

        // MARK: - Rewards Use Case

		container.register(RewardsUseCaseApi.self) { resolver in
            RewardsUseCase(devicesRepository: resolver.resolve(DevicesRepository.self)!)
        }

        // MARK: - Filters

		container.register(FiltersUseCaseApi.self) { resolver in
            FiltersUseCase(repository: resolver.resolve(FiltersRepository.self)!)
        }

		// MARK: - Widget

		container.register(WidgetUseCaseApi.self) { resolver in
			WidgetUseCase(meRepository: resolver.resolve(MeRepository.self)!,
						  keychainRepository: resolver.resolve(KeychainRepository.self)!)
		}

		// MARK: - Auth DI

		container.register(LoginService.self) { resolver in
			LoginServiceImpl(authRepository: resolver.resolve(AuthRepository.self)!,
							 meRepository: resolver.resolve(MeRepository.self)!,
							 keychainRepository: resolver.resolve(KeychainRepository.self)!,
							 userDefaultsRepository: resolver.resolve(UserDefaultsRepository.self)!,
							 networkRepository: resolver.resolve(NetworkRepository.self)!)
		}.inObjectScope(.container)

		container.register(AuthRepository.self) { _ in
			AuthRepositoryImpl()
		}

		container.register(AuthUseCaseApi.self) { resolver in
			AuthUseCase(authRepository: resolver.resolve(AuthRepository.self)!,
						meRepository: resolver.resolve(MeRepository.self)!,
						keychainRepository: resolver.resolve(KeychainRepository.self)!,
						userDefaultsRepository: resolver.resolve(UserDefaultsRepository.self)!,
						networkRepository: resolver.resolve(NetworkRepository.self)!,
						loginService: resolver.resolve(LoginService.self)!)
		}

		// MARK: - Survey

		container.register(RemoteConfigRepository.self) { _ in
			RemoteConfigRepositoryImpl()
		}

		container.register(RemoteConfigUseCaseApi.self) { resolver in
			RemoteConfigUseCase(repository: resolver.resolve(RemoteConfigRepository.self)!)
		}

		// MARK: - Photos

		container.register(FileUploaderService.self) { _ in
			FileUploaderService()
		}
		.inObjectScope(.container)

		container.register(WXMLocationManager.LocationManagerProtocol.self) { _ in
			WXMLocationManager()
		}

		container.register(PhotosRepository.self) { resolver in
			PhotosRepositoryImpl(fileUploader: resolver.resolve(FileUploaderService.self)!,
								 locationManager: resolver.resolve(WXMLocationManager.LocationManagerProtocol.self)!)
		}

		container.register(PhotoGalleryUseCaseApi.self) { resolver in
			PhotoGalleryUseCase(photosRepository: resolver.resolve(PhotosRepository.self)!)
		}

		// MARK: - Station notifications
		
		container.register(StationNotificationsUseCaseApi.self) { resolver in
			StationNotificationsUseCase(userDefaultsRepository: resolver.resolve(UserDefaultsRepository.self)!)
		}

		// MARK: - Location Forecast

		container.register(LocationForecastsUseCaseApi.self) { resolver in
			LocationForecastsUseCase(explorerRepository: resolver.resolve(ExplorerRepository.self)!,
									 userDefaultsRepository: resolver.resolve(UserDefaultsRepository.self)!,
									 cacheManager: resolver.resolve(UserDefaultsService.self)!)
		}

        // MARK: - Return the Container

        return container
    }()

    // MARK: - Implementing the protocol

    func getContainerForSwinject() -> Container {
        return swinjectContainer
    }
}
