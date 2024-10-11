//
//  PercentageGridLayoutView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 22/3/23.
//

import SwiftUI

struct PercentageGridLayoutView<Content: View>: View {
    var alignments: [Alignment] = [.leading, .leading]
    var firstColumnPercentage: CGFloat = 0.6
	var linesSpacing: CGFloat?

    let content: () -> Content
    @State private var size: CGSize = .zero

	var body: some View {
#if MAIN_APP
		LazyVGrid(columns: [GridItem(.fixed(size.width * firstColumnPercentage),
									 spacing: 0.0,
									 alignment: alignments[0]),
							GridItem(.flexible(),
									 spacing: 0.0,
									 alignment: alignments[1])],
				  spacing: linesSpacing) {
			content()
		}.sizeObserver(size: $size)
#else
		VStack {
			LazyVGrid(columns: [GridItem(.flexible(), spacing: 0.0, alignment: alignments[0]),
								GridItem(.flexible(), spacing: 0.0, alignment: alignments[1])]) {
				content()
			}
		}
#endif
	}
}

struct PercentageGridLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        PercentageGridLayoutView {
            Group {
                Text(verbatim: "Column 0")
                Text(verbatim: "Column 1")
            }
        }
    }
}
