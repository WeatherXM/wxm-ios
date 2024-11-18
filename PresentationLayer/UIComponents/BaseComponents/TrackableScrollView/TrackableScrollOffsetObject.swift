//
//  TrackableScrollOffsetObject.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 18/11/24.
//

import Combine
import SwiftUI
import Toolkit

class TrackableScrollOffsetObject: ObservableObject {
	@Published var contentOffset: CGFloat = 0.0 {
		didSet {
			updateDiffOffset()
		}
	}
	@Published private(set) var diffOffset: CGFloat = 0.0
	var contentSize: CGSize = .zero
	var scrollerSize: CGSize = .zero
	var willStartDraggingAction: VoidCallback?
	var hasReachedBottom: Bool {
		guard contentSize.height >= scrollerSize.height else {
			return false
		}

		return (contentSize.height - contentOffset) <= scrollerSize.height
	}

	private var initialOffset: CGFloat?

	func didStartDragging() {
		willStartDraggingAction?()
		initialOffset = contentOffset
	}

	private func updateDiffOffset() {
		guard let initialOffset else {
			return
		}

		diffOffset = contentOffset - initialOffset
	}
}
