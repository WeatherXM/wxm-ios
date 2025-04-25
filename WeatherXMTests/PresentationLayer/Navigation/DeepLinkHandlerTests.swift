//
//  DeepLinkHandlerTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 25/4/25.
//

import Testing
import Foundation
@testable import WeatherXM

@MainActor
struct DeepLinkHandlerTests {

	let handler: DeepLinkHandler
	let networkUseCase: MockNetworkUseCase
	let explorerUseCase: MockExplorerUseCase
	let linkNavigator: MockLinkNavigation

	init() {
		linkNavigator = .init()
		networkUseCase = .init()
		explorerUseCase = .init()
		handler = DeepLinkHandler(useCase: networkUseCase,
								  explorerUseCase: explorerUseCase,
								  linkNavigator: linkNavigator)
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
		let handled = handler.handleUrl(url)
		#expect(handled == false)
	}
}
