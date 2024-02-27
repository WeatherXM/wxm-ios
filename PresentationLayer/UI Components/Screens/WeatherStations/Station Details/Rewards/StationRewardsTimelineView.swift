//
//  RewardsTimelineView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 27/10/23.
//

import SwiftUI

struct StationRewardsTimelineView: View {
	typealias Value = (text: String?, value: Int)
	let values: [Value]

	var body: some View {
		let indices = values.indices
		HStack(spacing: 0.0) {
			ForEach(indices, id: \.self) { index in
				let val = values[index]
				GeometryReader { proxy in
					VStack(spacing: CGFloat(.smallSpacing)) {
						GeometryReader { proxy in
							ZStack {
								Capsule()
									.foregroundColor(Color(colorEnum: .blueTint))

								VStack {
									Spacer(minLength: 0.0)
									Capsule()
										.foregroundColor(Color(colorEnum: getHexagonColor(validationScore: Double(val.value) / 100.0)))
										.frame(height: heightFor(value: val.value, containerSize: proxy.size))
								}
							}
						}
						.frame(width: proxy.size.width / 2.0)

						if let text = val.text {
							Text(text)
								.font(.system(size: CGFloat(.caption)))
								.foregroundColor(Color(colorEnum: .text))

						}
					}
					.frame(width: proxy.size.width)
				}
			}
		}
	}
}

private extension StationRewardsTimelineView {
	func heightFor(value: Int, containerSize: CGSize) -> Double {
		let offset = containerSize.height / 4.0
		let actualContainerHeight = containerSize.height - offset
		let height = (Double(value) / 100.0) * actualContainerHeight

		return height + offset
	}
}

#Preview {
	let range = 0..<7
	let values: [StationRewardsTimelineView.Value] = range.map { _ in ("Day", Int.random(in: 0...100)) }
    return StationRewardsTimelineView(values: values)
}
