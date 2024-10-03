//
//  ChartLegendView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 23/9/24.
//

import SwiftUI

struct ChartLegendView: View {
	let items: [Item]

    var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
			ForEach(items) { item in
				HStack(spacing: CGFloat(.minimumSpacing)) {
					Color(colorEnum: item.color)
						.frame(width: 12.0, height: 2.0)

					Text(item.title)
						.font(.system(size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: .text))
				}
			}
		}
    }
}

extension ChartLegendView {
	struct Item: Identifiable, Hashable {
		var id: String {
			title
		}

		let color: ColorEnum
		let title: String
	}
}
#Preview {
	ChartLegendView(items: [.init(color: .chartPrimary, title: "Base"),
							.init(color: .betaRewardsFill, title: "Beta"),
							.init(color: .otherRewardFill, title: "Other")])
}
