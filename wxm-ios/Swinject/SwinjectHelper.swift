//
//  SwinjectHelper.swift
//  wxm-ios
//
//  Created by Hristos Condrea on 6/5/22.
//

import DataLayer
import DomainLayer
import Foundation
import Swinject
import Toolkit

class SwinjectHelper: SwinjectInterface {
    static let shared = SwinjectHelper()

    private init() {}

    let swinjectContainer: Container = {
        // MARK: - We create a Container in order to register all of our DI.

        let container = Container()

		container.register(UserDevicesService.self) { _ in
			UserDevicesService()
		}
		.inObjectScope(.container)

		container.register(UserInfoService.self) { _ in
			UserInfoService()
		}
		.inObjectScope(.container)

        // MARK: - Settings

        container.register(SettingsRepository.self) { _ in
            SettingsRepositoryImpl()
        }

        container.register(SettingsUseCase.self) { resolver in
            SettingsUseCase(repository: resolver.resolve(SettingsRepository.self)!,
                            authRepository: resolver.resolve(AuthRepository.self)!,
                            keychainRepository: resolver.resolve(KeychainRepository.self)!,
                            networkRepository: resolver.resolve(NetworkRepository.self)!)
        }

        // MARK: - Network

        container.register(NetworkRepository.self) { _ in
            NetworkRepositoryImpl()
        }

        container.register(NetworkUseCase.self) { resolver in
            NetworkUseCase(repository: resolver.resolve(NetworkRepository.self)!)
        }

        // MARK: - Devices DI

        container.register(DevicesRepository.self) { _ in
            DevicesRepositoryImpl()
        }
        container.register(BluetoothDevicesRepository.self) { _ in
            BluetoothDevicesRepositoryImpl()
        }
        container.register(DevicesUseCase.self) { resolver in
            let devicesUseCase = DevicesUseCase(
                devicesRepository: resolver.resolve(DevicesRepository.self)!,
                bluetoothDevicesRepository: resolver.resolve(BluetoothDevicesRepository.self)!
            )

            return devicesUseCase
        }
        container.register(DeviceLocationRepository.self) { _ in
            DeviceLocationRepositoryImpl()
        }
        container.register(DeviceLocationUseCase.self) { resolver in
            DeviceLocationUseCase(deviceLocationRepository: resolver.resolve(DeviceLocationRepository.self)!)
        }

        // MARK: - Device info DI
        container.register(DeviceInfoRepository.self) { resolver in
            DeviceInfoRepositoryImpl(userDevicesService: resolver.resolve(UserDevicesService.self)!)
        }
        container.register(DeviceInfoUseCase.self) { resolver in
            DeviceInfoUseCase(repository: resolver.resolve(DeviceInfoRepository.self)!)
        }
        // MARK: - Cells DI

        container.register(ExplorerRepository.self) { _ in
            ExplorerRepositoryImpl()
        }

        container.register(ExplorerUseCase.self) { resolver in
            let explorerUserCase = ExplorerUseCase(explorerRepository: resolver.resolve(ExplorerRepository.self)!,
                                                   devicesRepository: resolver.resolve(DevicesRepository.self)!,
                                                   meRepository: resolver.resolve(MeRepository.self)!,
												   deviceLocationRepository: resolver.resolve(DeviceLocationRepository.self)!)
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

        container.register(FiltersService.self) { _ in
            FiltersService()
        }
        .inObjectScope(.container)

        container.register(FiltersRepository.self) { resolver in
            FiltersRepositoryImpl(filtersService: resolver.resolve(FiltersService.self)!)
        }

        container.register(MeUseCase.self) { resolver in
            MeUseCase(meRepository: resolver.resolve(MeRepository.self)!,
					  filtersRepository: resolver.resolve(FiltersRepository.self)!,
					  networkRepository: resolver.resolve(NetworkRepository.self)!)
        }

        container.register(RewardsTimelineUseCase.self) { resolver in
			RewardsTimelineUseCase(repository: resolver.resolve(DevicesRepository.self)!, meRepository: resolver.resolve(MeRepository.self)!)
        }

        container.register(HistoryUseCase.self) { resolver in
            HistoryUseCase(meRepository: resolver.resolve(MeRepository.self)!, userDefaultsRepository: resolver.resolve(UserDefaultsRepository.self)!)
        }

        // MARK: - Keychain DI

        container.register(KeychainRepository.self) { _ in
            KeychainRepositoryImpl()
        }
        container.register(KeychainUseCase.self) { resolver in
            KeychainUseCase(keychainRepository: resolver.resolve(KeychainRepository.self)!)
        }

        // MARK: - Main Use Case

        container.register(MainUseCase.self) { resolver in
			MainUseCase(userDefaultsRepository: resolver.resolve(UserDefaultsRepository.self)!,
						keychainRepository: resolver.resolve(KeychainRepository.self)!)
        }

        // MARK: - Device Details Use Case

        container.register(DeviceDetailsUseCase.self) { resolver in
            DeviceDetailsUseCase(meRepository: resolver.resolve(MeRepository.self)!,
                                 explorerRepository: resolver.resolve(ExplorerRepository.self)!,
                                 keychainRepository: resolver.resolve(KeychainRepository.self)!)
        }

        // MARK: - Rewards Use Case

        container.register(RewardsUseCase.self) { resolver in
            RewardsUseCase(meRepository: resolver.resolve(MeRepository.self)!,
                           devicesRepository: resolver.resolve(DevicesRepository.self)!,
                           keychainRepository: resolver.resolve(KeychainRepository.self)!)
        }

        // MARK: - Filters

        container.register(FiltersUseCase.self) { resolver in
            FiltersUseCase(repository: resolver.resolve(FiltersRepository.self)!)
        }

		// MARK: - Widget

		container.register(WidgetUseCase.self) { resolver in
			WidgetUseCase(meRepository: resolver.resolve(MeRepository.self)!,
						  keychainRepository: resolver.resolve(KeychainRepository.self)!)
		}

		// MARK: - Auth DI

		container.register(AuthRepository.self) { _ in
			AuthRepositoryImpl()
		}
		container.register(AuthUseCase.self) { resolver in
			AuthUseCase(authRepository: resolver.resolve(AuthRepository.self)!,
						meRepository: resolver.resolve(MeRepository.self)!,
						keychainRepository: resolver.resolve(KeychainRepository.self)!,
						userDefaultsRepository: resolver.resolve(UserDefaultsRepository.self)!,
						networkRepository: resolver.resolve(NetworkRepository.self)!)
		}

        // MARK: - Return the Container

        return container
    }()

    // MARK: - Implementing the protocol

    func getContainerForSwinject() -> Container {
        return swinjectContainer
    }
}
