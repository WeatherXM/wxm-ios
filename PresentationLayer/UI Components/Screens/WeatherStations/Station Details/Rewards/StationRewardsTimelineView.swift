//
//  RewardsTimelineView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 27/10/23.
//

import SwiftUI

struct StationRewardsTimelineView: View {
	let values: [Int]

	var body: some View {
		let indices = values.indices
		HStack(spacing: 0.0) {
			ForEach(indices, id: \.self) { index in
				let val = values[index]
				GeometryReader { proxy in
					VStack {
						ZStack {
							Capsule()
								.foregroundColor(Color(colorEnum: .blueTint))

							VStack {
								Spacer(minLength: 0.0)
								Capsule()
									.foregroundColor(Color(colorEnum: getHexagonColor(validationScore: Double(val) / 100.0)))
									.frame(height: (Double(val) / 100.0) * proxy.size.height)
							}
						}
						.frame(width: proxy.size.width / 2.0)
					}
					.frame(width: proxy.size.width)
				}
			}
		}
	}
}

#Preview {
	let range = 0..<7
	let values = range.map { _ in Int.random(in: 0...100) }
    return StationRewardsTimelineView(values: values)
}
