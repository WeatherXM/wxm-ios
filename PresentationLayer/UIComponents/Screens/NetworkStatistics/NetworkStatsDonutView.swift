//
//  NetworkStatsDonutView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/5/25.
//

import SwiftUI

struct NetworkStatsDonutView: View {
	let claimed: Double
	let reserved: Double

    var body: some View {
		HStack(spacing: CGFloat(.minimumSpacing)) {
			VStack(alignment: .trailing) {
				Text(LocalizableString.NetStats.claimedAmount(claimed.toCompactDecimaFormat ?? "").localized.uppercased())
					.foregroundStyle(Color(colorEnum: .text))
					.font(.system(size: CGFloat(.caption)))
					.multilineTextAlignment(.trailing)
			}


			ProgressView(value: claimed, total: reserved)
				.progressViewStyle(DonutProgressStyle(lineWidth: 26.0,
													  color: Color(colorEnum: .chartPrimary),
													  progressColor: Color(colorEnum: .chartSecondary)))
				.frame(width: 140.0, height: 80.0)

			Text(LocalizableString.NetStats.reserved(reserved.toCompactDecimaFormat ?? "").localized.uppercased())
				.foregroundStyle(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.caption)))
				.multilineTextAlignment(.leading)
		}
    }
}

struct DonutProgressStyle: ProgressViewStyle {
	let lineWidth: CGFloat
	let color: Color
	let progressColor: Color
	private let angleThreshold: CGFloat = 180.0

	func makeBody(configuration: Configuration) -> some View {
		let angleProgress = getAngleProgress(configuration: configuration)
		ZStack {
			Arc(startAngle: .degrees(0.0 + angleProgress + angleThreshold),
				endAngle: .degrees(180.0 + angleThreshold),
				clockwise: false,
				lineWidth: lineWidth)
			.stroke(color, lineWidth: 26)

			Arc(startAngle: .degrees(angleThreshold),
				endAngle: .degrees(angleThreshold + angleProgress),
				clockwise: false,
				lineWidth: lineWidth)
			.stroke(progressColor, lineWidth: lineWidth)
		}
	}

	private func getAngleProgress(configuration: Configuration) -> CGFloat {
		let completed = configuration.fractionCompleted ?? 0.0
		let progress = 180.0 * completed
		return progress
	}
}

struct Arc: Shape {
	let startAngle: Angle
	let endAngle: Angle
	let clockwise: Bool
	let lineWidth: CGFloat

	func path(in rect: CGRect) -> Path {
		var path = Path()

		let adjustedRadius = (rect.width / 2) - (lineWidth / 2)

		path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY),
					radius: adjustedRadius,
					startAngle: startAngle,
					endAngle: endAngle,
					clockwise: clockwise)

		return path
	}
}

#Preview {
	NetworkStatsDonutView(claimed: 296, reserved: 1000)
		.padding()
}
