//
//  TabBarVisibilityHandler.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 30/11/23.
//

import Foundation
import SwiftUI
import Combine

class TabBarVisibilityHandler {

	let scrollOffsetObject: TrackableScrollOffsetObject
	@Published var isTabBarShowing: Bool = true
	private var cancellableSet: Set<AnyCancellable> = []

	init(scrollOffsetObject: TrackableScrollOffsetObject) {
		self.scrollOffsetObject = scrollOffsetObject
		observeContentOffset()
	}
}

private extension TabBarVisibilityHandler {
	func observeContentOffset() {
		scrollOffsetObject.$contentOffset.sink { [weak self] value in
			guard let self = self,
				  case let isTabBarShowing = self.isTabBarVisible(newContentOffset: value),
				  /// The following check is required to prevent unnecessary renders from SwiftUI.
				  /// For some reason this happens on every assignment regardless the value is the same 🤷‍♂️
				  self.isTabBarShowing != isTabBarShowing
			else {
				return
			}

			self.isTabBarShowing = isTabBarShowing
		}
		.store(in: &cancellableSet)
	}

	/// Calculates the condition to show or hide tab bar
	/// - Parameter newContentOffset: The new scrolling offset
	/// - Returns: If should show or hide tab bar
	func isTabBarVisible(newContentOffset: CGFloat) -> Bool {
		if scrollOffsetObject.hasReachedBottom(with: newContentOffset) {
			return false
		}

		if scrollOffsetObject.contentOffset < 40 {
			return true
		}

		let isScrollingUpwards = newContentOffset > scrollOffsetObject.contentOffset
		return !isScrollingUpwards
	}
}
