//
//  DeepLinkHandler.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 24/7/23.
//

import Foundation
import DomainLayer
import Combine
import UIKit
import Toolkit
import UserNotifications
import CoreLocation

private enum Announcement: String {
	case weatherxmPro = "weatherxm_pro"
}

@MainActor
class DeepLinkHandler {
	typealias QueryParamsCallBack = GenericCallback<[String: String]?>
	static let httpsScheme = "https"
	static let explorerHost = "explorer.weatherxm.com"
	static let explorerDevHost = "explorer-dev.weatherxm.com"
	static let stationsPath = "stations"
	static let cellsPath = "cells"
	static let tokenClaim = "token-claim"
	static let announcement = "announcement"

	let useCase: NetworkUseCaseApi
	let explorerUseCase: ExplorerUseCaseApi

	private let linkNavigator: LinkNavigation
	private let router: Router
    private var searchCancellable: AnyCancellable?

	init(useCase: NetworkUseCaseApi,
		 explorerUseCase: ExplorerUseCaseApi,
		 linkNavigator: LinkNavigation = LinkNavigationHelper(),
		 router: Router = .shared) {
        self.useCase = useCase
		self.explorerUseCase = explorerUseCase
		self.linkNavigator = linkNavigator
		self.router = router
    }

	@discardableResult
	/// Handles the passed url
	/// - Parameter url: The url to handle/navigete
	/// - Parameter queryParamsCallback: A callback to pass the url query params if handled successfully
	/// - Returns: True if is handled successfully
	func handleUrl(_ url: URL, queryParamsCallback: QueryParamsCallBack? = nil) -> Bool {
        print(url)

		var handled = false
		defer {
			if handled {
				queryParamsCallback?(url.queryItems)
			}
		}

		switch url.scheme {
			case Self.httpsScheme:
				handled = handleUniversalLink(url: url)
			case Bundle.main.urlScheme:
				handled = handleUrlScheme(url: url)
			case widgetScheme:
				handled = handleWidgetUrlScheme(url: url)
			default:
				handled = linkNavigator.openUrl(url)
		}

		return handled
    }

	func handleNotificationReceive(_ notification: UNNotificationResponse) -> Bool {
		guard let type = notification.toNotificationType else {
			return false
		}

		switch type {
			case .announcement(let urlString):
				if let url = URL(string: urlString) {
					router.showFullScreen(.safariView(url))
					return true
				}
			case .device(let deviceId):
				moveToStation(deviceId: deviceId, cellIndex: nil, cellCenter: nil)
				return true
		}

		return false
	}

    deinit {
        print("deInit \(Self.self)")
    }
}

private extension DeepLinkHandler {
	/// Handles the url scheme (not http)
	/// - Parameter url: The url to handle/navigete
	/// - Returns: True if is handled successfully
    func handleUrlScheme(url: URL) -> Bool {
        guard let path = url.host else {
			router.pop()
            return true
        }

        let value = url.lastPathComponent

        return handleNavigation(path: path, value: value)
    }

	/// Handles the widget url
	/// - Parameter url: The url to handle/navigete
	/// - Returns: True if is handled successfully
	func handleWidgetUrlScheme(url: URL) -> Bool {
		guard let host = url.host,
			  let widgetCase = WidgetUrlType(rawValue: host) else {
			return false
		}

		let pathComps = url.pathComponents
		switch widgetCase {
			case .station:
				if let deviceId = pathComps[safe: 1] {
					let route = Route.stationDetails(ViewModelsFactory.getStationDetailsViewModel(deviceId: deviceId,
																								  cellIndex: nil,
																								  cellCenter: nil))
					router.navigateTo(route)
					return true
				}

				return false
			case .loggedOut:
				let route = Route.signIn(ViewModelsFactory.getSignInViewModel())
				router.navigateTo(route)
				return true
			case .empty:
				return false
			case .error:
				return false
			case .selectStation:
				return false
		}
	}

	/// Handles the http url
	/// - Parameter url: The url to handle/navigete
	/// - Returns: True if is handled successfully
    func handleUniversalLink(url: URL) -> Bool {
        guard let host = url.host,
			  host == Self.explorerHost || host == Self.explorerDevHost,
              case let pathComps = url.pathComponents,
              pathComps.count == 3 else {
            return false
        }

        let path = pathComps[1]
        let value = pathComps[2]
        return handleNavigation(path: path, value: value)
    }

	/// Handles path to navigate
	/// - Parameter path: The path to navigate
	/// - Parameter value: The value to pass to the navigation path
	/// - Parameter additionalInfo: Extra params to be handled
	/// - Returns: True if is handled successfully
	func handleNavigation(path: String, value: String) -> Bool {
		switch path {
			case Self.stationsPath:
				moveToStation(name: value)
				return true
			case Self.cellsPath:
				moveToCell(index: value)
				return true
			case Self.tokenClaim:
				router.pop()
				return true
			case Self.announcement:
				handleAnnouncement(value)
				return true
			default:
				return false
		}
    }

    func moveToStation(name: String) {
        let normalizedName = name.replacingOccurrences(of: "-", with: " ")
        guard normalizedName.count > 1 else { // To perform search the term's length should be greater than 1
            if let message = LocalizableString.Error.deepLinkInvalidUrl.localized.attributedMarkdown {
                Toast.shared.show(text: message)
            }
            return
        }

        do {
            searchCancellable = try useCase.search(term: normalizedName, exact: true, exclude: .places).sink { [weak self] response in
                if let error = response.error {
                    let info = error.uiInfo
                    if let message = info.description?.attributedMarkdown {
                        Toast.shared.show(text: message)
                    }

                    return
                }

                if let device = response.value?.devices?.first,
                   let deviceId = device.id {
					let cellIndex = device.cellIndex
                    let cellCenter = device.cellCenter?.toCLLocationCoordinate2D()
					self?.moveToStation(deviceId: deviceId, cellIndex: cellIndex, cellCenter: cellCenter)
                }
            }
        } catch {

        }
    }

	func moveToStation(deviceId: String,
					   cellIndex: String?,
					   cellCenter: CLLocationCoordinate2D?) {
		let route = Route.stationDetails(ViewModelsFactory.getStationDetailsViewModel(deviceId: deviceId,
																					  cellIndex: cellIndex,
																					  cellCenter: cellCenter))
		router.navigateTo(route)
	}

	func moveToCell(index: String) {
		Task { @MainActor in
			guard let cell = try? await explorerUseCase.getCell(cellIndex: index).get() else {
				Toast.shared.show(text: LocalizableString.ExplorerList.cellNotFoundMessage.localized.attributedMarkdown ?? "")
				return
			}

			let lon = cell.center.lon
			let lat = cell.center.lat
			let cellCenter = CLLocationCoordinate2D(latitude: lat, longitude: lon)

			let route = Route.explorerList(ViewModelsFactory.getExplorerStationsListViewModel(cellIndex: index, cellCenter: cellCenter))
			router.navigateTo(route)
		}
	}

	func handleAnnouncement(_ announcement: String) {
		guard let announcement = Announcement(rawValue: announcement) else {
			return
		}

		switch announcement {
			case .weatherxmPro:
				let viewModel = ViewModelsFactory.getProPromotionalViewModel()
				router.showBottomSheet(.proPromo(viewModel))
				break
		}
	}
}

extension String {
	@MainActor
	var isProPromotionUrl: Bool {
		guard let url = URL(string: self) else {
			return false
		}
		let isWeatherXMScheme = url.scheme == Bundle.main.urlScheme
		let isAnnouncement = url.host() == DeepLinkHandler.announcement
		let isProPromo = Announcement(rawValue: url.lastPathComponent) == .weatherxmPro

		return isWeatherXMScheme && isAnnouncement && isProPromo
	}
}

private enum NotificationType {
	case announcement(String)
	case device(String)
}

private extension UNNotificationResponse {
	static let typeKey = "type"
	static let announcementVal = "announcement"
	static let stationVal = "station"
	static let urlKey = "url"
	static let deviceIdKey = "device_id"

	var toNotificationType: NotificationType? {
		let userInfo = notification.request.content.userInfo
		guard let type = userInfo[Self.typeKey] as? String else {
			return nil
		}

		switch type {
			case Self.announcementVal:
				if let url = userInfo[Self.urlKey] as? String {
					return .announcement(url)
				}
				return nil
			case Self.stationVal:
				if let deviceId = userInfo[Self.deviceIdKey] as? String {
					return .device(deviceId)
				}

				return nil
			default:
				return nil
		}
	}
}
