//
//  ChartView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/9/24.
//

import SwiftUI
import Charts

struct ChartDataItem: Identifiable {
	var id: Int {
		xVal
	}

	let xVal: Int
	let yVal: Double
	let group: String
}

struct ChartView: View {
	let data: [ChartDataItem]

    var body: some View {
		if #available(iOS 16.0, *) {
			ChartAreaView(data: data)
		} else {
			EmptyView()
		}
    }
}


@available(iOS 16.0, *)
private struct ChartAreaView: View {

	let data: [ChartDataItem]
	@State private var showSelection: Bool = false
	@State private var selectedItem: ChartDataItem?
	@State private var indicatorOffet: CGSize = .zero
	@State private var popupDetailsOffset: CGSize = .zero
	@State private var popupDetailsSize: CGSize = .zero

	var body: some View {
		Chart(data) { item in
			LineMark(x: .value("x_val", item.xVal), y: .value("value", item.yVal))
				.foregroundStyle(Color(colorEnum: .chartPrimary))
				.interpolationMethod(.monotone)
		}
		.chartLegend(.hidden)
		.chartXAxis {
			AxisMarks(stroke: StrokeStyle(lineWidth: 0))
			
			AxisMarks(values: .automatic) { value in
				if let val = value.as(String.self) {
					AxisValueLabel {
						VStack(spacing: CGFloat(.minimumSpacing)) {

							Text("\(val)")
								.font(.system(size: CGFloat(.caption)))
								.foregroundStyle(Color(colorEnum: .text))
						}
					}
				}
			}
		}
		.chartYAxis {
			AxisMarks { value in
				AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
					.foregroundStyle(Color(colorEnum: value.index == 0 ? .text : .midGrey))
			}

			AxisMarks(values: .automatic) { value in
				if let val = value.as(Int.self) {
					AxisValueLabel {
						Text("\(val)")
							.font(.system(size: CGFloat(.caption)))
							.foregroundStyle(Color(colorEnum: .text))
					}
				}
			}
		}
		.chartOverlay { chartProxy in
			GeometryReader { proxy in
				selector(chartProxy: chartProxy)
				popUpDetails
				interactionArea(proxy: proxy,
								chartProxy: chartProxy)
			}
		}
	}
}

@available(iOS 16.0, *)
private extension ChartAreaView {
	@ViewBuilder
	func selector(chartProxy: ChartProxy) -> some View {
		DottedLineView()
			.foregroundColor(Color(colorEnum: .darkGrey))
			.frame(width: 1.0, height: chartProxy.plotAreaSize.height)
			.offset(indicatorOffet)
			.opacity(showSelection ? 1.0 : 0.0)
			.animation(.easeIn(duration: 0.1), value: showSelection)
	}

	@ViewBuilder
	var popUpDetails: some View {
		if let selectedItem, showSelection {
			VStack(alignment: .trailing) {
				ChartOverlayDetailsView(title: selectedItem.group,
										valueItems: [("Total", "\(selectedItem.yVal)")])
					.sizeObserver(size: $popupDetailsSize)


				Spacer()
			}
			.offset(popupDetailsOffset)
		}
	}

	@ViewBuilder
	func interactionArea(proxy: GeometryProxy, chartProxy: ChartProxy) -> some View {
		Rectangle().fill(.clear).contentShape(Rectangle())
									.gesture(DragGesture().onChanged { value in
										showSelection = true

										let origin = proxy[chartProxy.plotAreaFrame].origin
										let location = CGPoint(
											x: value.location.x - origin.x,
											y: value.location.y - origin.y
										)

										let offsetX = location.x.clamped(to: 0.0...chartProxy.plotAreaSize.width)
										indicatorOffet = CGSize(width: offsetX, height: 0.0)

										let popUpOffsetMin = 0.0
										let popUpOffsetMax = chartProxy.plotAreaSize.width - popupDetailsSize.width
										popupDetailsOffset = CGSize(width: offsetX.clamped(to: popUpOffsetMin...popUpOffsetMax),
																	height: 0.0)

										let (xVal, _) = chartProxy.value(at: location, as: (Int, Double).self) ?? (0, 0)
										selectedItem = data.first(where: { $0.xVal == xVal })
									}.onEnded { _ in
										showSelection = false
									})
	}
}

private struct ChartOverlayDetailsView: View {
	typealias ValueItem = (title: String, value: String)
	let title: String
	let valueItems: [ValueItem]


	var body: some View {
		VStack(spacing: CGFloat(.minimumSpacing)) {
			Text(title)
				.font(.system(size: CGFloat(.caption)))
				.foregroundStyle(Color(colorEnum: .textInverse))

			Color(colorEnum: .textInverse).frame(height: 1)

			ForEach(valueItems, id: \.title) { item in
				HStack {
					Text(item.title)
					Text(item.value)
				}
				.font(.system(size: CGFloat(.caption)))
				.foregroundStyle(Color(colorEnum: .textInverse))
			}
		}
		.fixedSize()
		.padding(CGFloat(.smallSidePadding))
		.background(Color.black.opacity(0.9))
	}
}

struct DottedLine: Shape {

	func path(in rect: CGRect) -> Path {
		var path = Path()
		path.move(to: CGPoint(x: 0, y: 0))
		path.addLine(to: CGPoint(x: rect.width, y: rect.height))
		return path
	}
}

struct DottedLineView: View {
	var body: some View {
		DottedLine()
			.stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
	}
}

#Preview {
	ChartView(data: [.init(xVal: 0, yVal: 3.0, group: "Mon"),
					 .init(xVal: 1, yVal: 4.0, group: "Tue"),
					 .init(xVal: 2, yVal: 14.34234, group: "Wed"),
					 .init(xVal: 3, yVal: 5.45252, group: "Thu"),
					 .init(xVal: 4, yVal: 7.090, group: "Fri"),
					 .init(xVal: 5, yVal: 9.21092, group: "Sat"),
					 .init(xVal: 6, yVal: 12.2132, group: "Sun")])
	.padding()
}
