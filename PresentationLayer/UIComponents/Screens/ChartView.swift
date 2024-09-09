//
//  ChartView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/9/24.
//

import SwiftUI
import Charts
import Toolkit

struct ChartDataItem: Identifiable {
	var id: Date {
		xVal
	}

	let xVal: Date
	let yVal: Double
	let group: String
	var color: ColorEnum = .chartPrimary
	let displayValue: String
}

enum ChartMode {
	case line
	case area
}

struct ChartView: View {
	var mode: ChartMode = .line
	let data: [ChartDataItem]
	
    var body: some View {
		if #available(iOS 16.0, *) {
			ChartAreaView(mode: mode, data: data)
		} else {
			EmptyView()
		}
    }
}


@available(iOS 16.0, *)
private struct ChartAreaView: View {
	let mode: ChartMode
	let data: [ChartDataItem]
	@State private var showSelection: Bool = false
	@State private var selectedItems: [ChartDataItem]?
	@State private var indicatorOffet: CGSize = .zero
	@State private var popupDetailsOffset: CGSize = .zero
	@State private var popupDetailsSize: CGSize = .zero

	var body: some View {
		Chart(data) { item in
			switch mode {
				case .line:
					LineMark(x: .value("x_val", item.xVal), y: .value("value", item.yVal))
						.foregroundStyle(Color(colorEnum: item.color))
						.interpolationMethod(.monotone)
						.foregroundStyle(by: .value("group", item.group))

				case .area:
					AreaMark(x: .value("x_val", item.xVal), y: .value("value", item.yVal))
						.interpolationMethod(.monotone)
						.foregroundStyle(Color(colorEnum: item.color))
						.foregroundStyle(by: .value("group", item.group))
			}
		}
		.chartLegend(.hidden)
		.chartXAxis {
			AxisMarks(stroke: StrokeStyle(lineWidth: 0))
			
//			AxisMarks(values: .automatic(desiredCount: 8)) { value in
//				if let val = value.as(Date.self) {
//					AxisValueLabel {
//						VStack(spacing: CGFloat(.minimumSpacing)) {
//
//							Text("\(val.localizedDateString())")
//								.font(.system(size: CGFloat(.caption)))
//								.foregroundStyle(Color(colorEnum: .text))
//						}
//					}
//				} else {
//					AxisValueLabel(format: .dateTime)
//				}
//			}
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
		if let selectedItems,
		   !selectedItems.isEmpty,
		   showSelection {
			VStack(alignment: .trailing) {
				ChartOverlayDetailsView(title: selectedItems.first?.xVal.localizedDateString() ?? "",
										valueItems: selectedItems.map { ($0.group, $0.displayValue)})
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

										let (xVal, _) = chartProxy.value(at: location, as: (Date, Double).self) ?? (.now, 0)
										selectedItems = data.filter { $0.xVal.isSameDay(with: xVal) }
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
					Spacer()
					Text(item.value)
				}
				.font(.system(size: CGFloat(.caption)))
				.foregroundStyle(Color(colorEnum: .textInverse))
			}
		}
		.fixedSize()
		.padding(CGFloat(.smallSidePadding))
		.background(Color(colorEnum: .tooltip))
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
	ChartView(data: [.init(xVal: Date.now, yVal: 3.0, group: "Total", displayValue: 3.0.toWXMTokenPrecisionString),
					 .init(xVal: Date.now.advancedByDays(days: 1), yVal: 4.0, group: "Total", displayValue: 4.0.toWXMTokenPrecisionString),
					 .init(xVal: Date.now.advancedByDays(days: 2), yVal: 14.34234, group: "Total", displayValue: 14.34234.toWXMTokenPrecisionString),
					 .init(xVal: Date.now.advancedByDays(days: 3), yVal: 5.45252, group: "Total", displayValue: 5.45252.toWXMTokenPrecisionString),
					 .init(xVal: Date.now.advancedByDays(days: 4), yVal: 7.090, group: "Total", displayValue: 7.090.toWXMTokenPrecisionString),
					 .init(xVal: Date.now.advancedByDays(days: 5), yVal: 9.21092, group: "Total", displayValue: 9.21092.toWXMTokenPrecisionString),
					 .init(xVal: Date.now.advancedByDays(days: 6), yVal: 12.2132, group: "Total", displayValue: 12.2132.toWXMTokenPrecisionString)])
	.padding()
}

#Preview {
	ChartView(mode: .area, data: [.init(xVal: Date.now.advancedByDays(days: 0), yVal: 3.0, group: "", displayValue: 3.0.toWXMTokenPrecisionString),
								  .init(xVal: Date.now.advancedByDays(days: 1), yVal: 4.0, group: "", displayValue: 4.0.toWXMTokenPrecisionString),
								  .init(xVal: Date.now.advancedByDays(days: 2), yVal: 10.34234, group: "", displayValue: 14.34234.toWXMTokenPrecisionString),
								  .init(xVal: Date.now.advancedByDays(days: 3), yVal: 5.45252, group: "", displayValue: 5.45252.toWXMTokenPrecisionString),
								  .init(xVal: Date.now.advancedByDays(days: 4), yVal: 7.090, group: "", displayValue: 7.090.toWXMTokenPrecisionString),
								  .init(xVal: Date.now.advancedByDays(days: 5), yVal: 9.21092, group: "", displayValue: 9.21092.toWXMTokenPrecisionString),
								  .init(xVal: Date.now.advancedByDays(days: 6), yVal: 8.2132, group: "", displayValue: 12.2132.toWXMTokenPrecisionString)])
	.padding()
}
