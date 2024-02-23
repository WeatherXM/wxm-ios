//
//  RewardsTimelineView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 27/10/23.
//

import SwiftUI

struct StationRewardsTimelineView: View {
	let values: [Int]
	private let maxWidthFactor: CGFloat = 1.0 / 15.0

    var body: some View {
		let indices = values.indices
		GeometryReader { proxy in
			HStack(spacing: 0.0) {
				ForEach(indices, id: \.self) { index in
					let val = values[index]
					Capsule()
						.foregroundColor(Color(colorEnum: getHexagonColor(validationScore: Double(val) / 100.0)))
						.frame(maxWidth: proxy.size.width * maxWidthFactor)

					if indices.last != index {
						Spacer(minLength: CGFloat(.minimumSpacing))
					}
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
