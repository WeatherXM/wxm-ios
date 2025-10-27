//
//  MockRouter.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 25/4/25.
//
@testable import WeatherXM

class MockRouter: Router {
	override func showFullScreen(_ route: Route) {
		fullScreenRoute = route
		showFullScreen = true
	}

	override func showBottomSheet(_ route: Route, bgColor: ColorEnum = .bottomSheetBg) {
		bottomSheetRoute = route
		showBottomSheet = true
	}

	override func navigateTo(_ route: Route) {
		self.path.append(route)
	}

	override func popToRoot() {
		self.path = .init()
	}

	override func pop() {
		self.path.removeLast()
	}
}
