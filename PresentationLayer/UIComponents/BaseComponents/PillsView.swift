//
//  PillsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 30/4/25.
//

import SwiftUI
import Toolkit

struct PillsView<Item: Hashable, PillContent: View>: View {
	var items: [Item]
	var containerWidth: CGFloat
	var pillContent: (Item) -> PillContent

	private let pillsSpacing = CGFloat(.smallSpacing)

	@State private var sizes: [SizeWrapper]

	init(items: [Item], containerWidth: CGFloat, pillContent: @escaping (Item) -> PillContent) {
		self.items = items
		self.containerWidth = containerWidth
		self.pillContent = pillContent
		sizes = items.map { _ in SizeWrapper() }
	}

	var body: some View {
		generatePills(width: containerWidth)
	}
}

private extension PillsView {

	@ViewBuilder
	func generatePills(width: CGFloat) -> some View {
		let rows = getRows(containerWidth: width)
		VStack(alignment: .leading, spacing: pillsSpacing) {
			ForEach(rows, id: \.self) { row in
				HStack(spacing: pillsSpacing) {
					ForEach(row, id: \.self) { item in
						let index = items.firstIndex(of: item)

						pillContent(item)
							.fixedSize()
							.sizeObserver(size: $sizes[index!].size)
					}

					Spacer(minLength: 0.0)
				}
			}
		}
	}

	@ViewBuilder
	func pill(_ item: Item, size: Binding<CGSize>) -> some View {
		pillContent(item)
	}

	func getRows(containerWidth: CGFloat) -> [[Item]] {
		var rows: [[Item]] = [[]]
		var width = containerWidth

		items.forEach { item in
			let itemWidth = getWidth(of: item)
			width -= itemWidth

			let shouldChangeLine = width < 0
			if shouldChangeLine {
				rows.append([item])
				width = containerWidth - itemWidth
			} else {
				let lastIndex = rows.count - 1
				rows[lastIndex].append(item)
			}
		}

		return rows
	}

	func getWidth(of item: Item) -> CGFloat {
		let index = items.firstIndex(of: item)
		return sizes[index!].size.width
	}
}

struct PillsView_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { proxy in
			PillsView(items: ["Ninetendo",
							  "XBox",
							  "PlayStation 23456",
							  "PlayStation 3"],
					  containerWidth: proxy.size.width) { item in
				Text(item)
					.lineLimit(1)
					.WXMCardStyle(backgroundColor: Color(colorEnum: .bg))
			}
		}
		.padding()
	}
}

extension Alignment {
	static let myAlignment = Alignment(horizontal: .leading,
									   vertical: .top)
}
