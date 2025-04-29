//
//  RouterTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 25/4/25.
//

import Testing
import Foundation
@testable import WeatherXM

@MainActor
struct RouterTests {
	let router: Router
	let url = URL(string: "https://example.com")!

	init() {
		router = .init()
	}

	@Test
	func navigate() {
		let route = Route.safariView(url)
		router.navigateTo(route)
		#expect(router.path.last == route)
		#expect(router.path.count == 1)

		let secondRoute = Route.safariView(URL(string: DisplayedLinks.announcements.linkURL)!)
		router.navigateTo(secondRoute)
		#expect(router.path.last == secondRoute)
		#expect(router.path.count == 2)

		router.navigateTo(secondRoute)
		#expect(router.path.last == secondRoute)
		#expect(router.path.count == 2)
	}

	@Test
	func pop() {
		let route = Route.safariView(url)
		router.navigateTo(route)
		#expect(router.path.last == route)
		#expect(router.path.count == 1)

		let secondRoute = Route.safariView(URL(string: DisplayedLinks.announcements.linkURL)!)
		router.navigateTo(secondRoute)
		#expect(router.path.last == secondRoute)
		#expect(router.path.count == 2)

		router.pop()
		#expect(router.path.last == route)
		#expect(router.path.count == 1)
	}

	  @Test
	  func popToRoot() {
		  let route = Route.safariView(url)
		  router.navigateTo(route)
		  #expect(router.path.last == route)
		  #expect(router.path.count == 1)

		  let secondRoute = Route.safariView(URL(string: DisplayedLinks.announcements.linkURL)!)
		  router.navigateTo(secondRoute)
		  #expect(router.path.last == secondRoute)
		  #expect(router.path.count == 2)

		  router.popToRoot()
		  #expect(router.path.isEmpty)
	  }

	  @Test
	  func testShowFullScreenRoute() {
		  let route = Route.safariView(url)
		  router.showFullScreen(route)
		  #expect(router.fullScreenRoute == route)
		  #expect(router.showFullScreen)
	  }


	  @Test
	  func testShowBottomSheetRoute() {
		  let route = Route.safariView(url)
		  router.showBottomSheet(route)
		  #expect(router.bottomSheetRoute == route)
		  #expect(router.showBottomSheet)
	  }
}
