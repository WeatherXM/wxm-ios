//
//  DeepLinkHandlerTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 25/4/25.
//

import Testing
import Foundation
import UserNotifications
@testable import WeatherXM

@MainActor
struct DeepLinkHandlerTests {

	let handler: DeepLinkHandler
	let networkUseCase: MockNetworkUseCase
	let explorerUseCase: MockExplorerUseCase
	let linkNavigator: MockLinkNavigation
	let router: MockRouter

	init() {
		router = .init()
		linkNavigator = .init()
		networkUseCase = .init()
		explorerUseCase = .init()
		handler = DeepLinkHandler(useCase: networkUseCase,
								  explorerUseCase: explorerUseCase,
								  linkNavigator: linkNavigator,
								  router: router)
	}

	@Test
	func handleUrlWithValidHttpsUrl() throws {
		let url = try #require(URL(string: "https://explorer.weatherxm.com/stations/123"))
		let handled = handler.handleUrl(url)
		#expect(handled == true)
	}

	@Test
	func handleUrlWithValidCustomScheme() throws {
		let url = try #require(URL(string: "weatherxm://stations/123"))
		let handled = handler.handleUrl(url)
		#expect(handled == true)
	}

	@Test
	func handleUrlWithUnsupportedScheme() throws {
		let url = try #require(URL(string: "ftp://explorer.weatherxm.com/stations/123"))
		#expect(linkNavigator.openedUrl == nil)
		let handled = handler.handleUrl(url)
		#expect(linkNavigator.openedUrl == url.absoluteString)
		#expect(handled == true)
	}

	@Test
	func handleUrlWithWidgetScheme() throws {
		let url = try #require(URL(string: "\(widgetScheme)://\(WidgetUrlType.station.rawValue)/123"))
		#expect(linkNavigator.openedUrl == nil)
		let handled = handler.handleUrl(url)
		#expect(linkNavigator.openedUrl == nil)
		#expect(handled == true)
	}

	@Test
	func handleUrlWithInvalidWidgetScheme() throws {
		let url = try #require(URL(string: "widget://stations/123"))
		#expect(linkNavigator.openedUrl == nil)
		let handled = handler.handleUrl(url)
		#expect(linkNavigator.openedUrl == url.absoluteString)
		#expect(handled)
	}

	@Test
	func handleUrlWithInvalidUrl() throws {
		let url = try #require(URL(string: "invalid://"))
		#expect(linkNavigator.openedUrl == nil)
		let handled = handler.handleUrl(url)
		#expect(linkNavigator.openedUrl == url.absoluteString)
		#expect(handled == true)
	}

	@Test
	func handleNotificationReceiveWithAnnouncement() throws {
		let userInfo: [AnyHashable: Any] = [
			"type": "announcement",
			"url": "https://example.com"
		]
		let notificationResponse = try getNotificationResponse(for: userInfo)
		let handled = handler.handleNotificationReceive(notificationResponse)
		#expect(handled == true)
		#expect(router.fullScreenRoute == .safariView(URL(string: "https://example.com")!))
	}

	@Test
	func handleNotificationReceiveWithDevice() throws {
		let userInfo: [AnyHashable: Any] = [
			"type": "station",
			"device_id": "123"
		]

		let notificationResponse = try getNotificationResponse(for: userInfo)
		let handled = handler.handleNotificationReceive(notificationResponse)
		#expect(handled == true)
		#expect(router.path.contains { $0 == .stationDetails(ViewModelsFactory.getStationDetailsViewModel(deviceId: "123", cellIndex: nil, cellCenter: nil)) })
	}
	
	@Test
	func testHandleNotificationReceive_withInvalidType() throws {
		let userInfo: [AnyHashable: Any] = [
			"type": "invalid"
		]
		
		let notificationResponse = try getNotificationResponse(for: userInfo)
		let handled = handler.handleNotificationReceive(notificationResponse)
		#expect(handled == false)
		#expect(router.fullScreenRoute == nil)
		#expect(router.path.isEmpty)
	}

	@Test
	func isProPromotionUrl() {
		var url = "weatherxm://announcement/weatherxm_pro"
		#expect(url.isProPromotionUrl)
		
		url = "weatherxm://announcement/weatherxm_pro_test"
		#expect(!url.isProPromotionUrl)

		url = "weatherxm://announce/weatherxm_pro"
		#expect(!url.isProPromotionUrl)

		url = "weatherxm://announcement/weatherxm_pro/test"
		#expect(!url.isProPromotionUrl)

		url = ""
		#expect(!url.isProPromotionUrl)

		url = "http://announcement/weatherxm_pro/test"
		#expect(!url.isProPromotionUrl)
	}
}

private extension DeepLinkHandlerTests {
	func getNotificationResponse(for userInfo: [AnyHashable: Any]) throws -> UNNotificationResponse {
		var notificationresponse = try #require(UNNotificationResponse(coder: KeyedArchiver(requiringSecureCoding: false)))
		let content = UNMutableNotificationContent()
		content.userInfo = userInfo
		let notification =  try #require(UNNotification(coder: KeyedArchiver(requiringSecureCoding: false)))
		notification.setValue(UNNotificationRequest(identifier: "test",
													content: content,
													trigger: nil),
							  forKey: "request")
		notificationresponse.setValue(notification, forKey: "notification")

		return notificationresponse
	}
}

private final class KeyedArchiver: NSKeyedArchiver {
	override func decodeObject(forKey _: String) -> Any { "" }
	override func decodeInt64(forKey key: String) -> Int64 { 0 }
}
