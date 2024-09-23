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
	var id: Int {
		xVal
	}

	let xVal: Int
	let yVal: Double
	let xAxisLabel: String
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

	private var strideBy: CGFloat {
		let count = data.count
		switch count {
			case _ where count < 10:
				return 1.0
			case _ where count < 20:
				return 2.0
			case _ where count <= 30:
				return 3.0
			default:
				return 5.0
		}
	}

	var body: some View {
		Chart(data, id: \.id) { item in
			switch mode {
				case .line:
					LineMark(x: .value("x_val", item.xVal), y: .value("value", item.yVal))
						.foregroundStyle(Color(colorEnum: item.color))
						.interpolationMethod(.linear)
						.foregroundStyle(by: .value("group", item.group))

				case .area:
					AreaMark(x: .value("x_val", item.xVal), y: .value("value", item.yVal))
						.interpolationMethod(.linear)
						.foregroundStyle(Color(colorEnum: item.color))
						.foregroundStyle(by: .value("group", item.group))
			}
		}
		.chartLegend(.hidden)
		.modify { view in
			if let min = data.min(by: { $0.xVal < $1.xVal })?.xVal,
				let max = data.max(by: { $0.xVal < $1.xVal })?.xVal {
				view.chartXScale(domain: min...max)
			} else{
				view
			}
		}
		.chartXScale(domain: data.first!.xVal...data.last!.xVal)
		.chartXAxis {
			AxisMarks(preset: .aligned, values: .stride(by: strideBy)) { value in
				if let val = value.as(Int.self),
				   let item = data.first(where: { $0.xVal == val }) {
					AxisValueLabel {
						VStack(spacing: CGFloat(.minimumSpacing)) {

							Text(item.xAxisLabel)
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
		if let selectedItems,
		   !selectedItems.isEmpty,
		   showSelection {
			VStack(alignment: .trailing) {
				ChartOverlayDetailsView(title: selectedItems.first?.xAxisLabel ?? "",
										valueItems: selectedItems.map { ($0.group, $0.displayValue) })
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

										let (xVal, _) = chartProxy.value(at: location, as: (Int, Double).self) ?? (-1, 0)
										selectedItems = data.filter { $0.xVal == xVal }
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
	ChartView(data: [.init(xVal: 0,
						   yVal: 3.0,
						   xAxisLabel: Date.now.getWeekDay(),
						   group: "Total",
						   displayValue: 3.0.toWXMTokenPrecisionString),
					 .init(xVal: 1,
						   yVal: 4.0,
						   xAxisLabel: Date.now.advancedByDays(days: 1).getWeekDay(),
						   group: "Total",
						   displayValue: 4.0.toWXMTokenPrecisionString),
					 .init(xVal: 2,
						   yVal: 14.34234,
						   xAxisLabel: Date.now.advancedByDays(days: 2).getWeekDay(),
						   group: "Total",
						   displayValue: 14.34234.toWXMTokenPrecisionString),
					 .init(xVal: 3,
						   yVal: 5.45252,
						   xAxisLabel: Date.now.advancedByDays(days: 3).getWeekDay(),
						   group: "Total",
						   displayValue: 5.45252.toWXMTokenPrecisionString),
					 .init(xVal: 4,
						   yVal: 7.090,
						   xAxisLabel: Date.now.advancedByDays(days: 4).getWeekDay(),
						   group: "Total",
						   displayValue: 7.090.toWXMTokenPrecisionString),
					 .init(xVal: 5,
						   yVal: 9.21092,
						   xAxisLabel: Date.now.advancedByDays(days: 5).getWeekDay(),
						   group: "Total",
						   displayValue: 9.21092.toWXMTokenPrecisionString),
					 .init(xVal: 6,
						   yVal: 12.2132,
						   xAxisLabel: Date.now.advancedByDays(days: 6).getWeekDay(),
						   group: "Total",
						   displayValue: 12.2132.toWXMTokenPrecisionString)])
	.padding()
}
