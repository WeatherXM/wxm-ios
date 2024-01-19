//
//  ErrorView.swift
//  station-widgetExtension
//
//  Created by Pantelis Giazitsis on 5/10/23.
//

import SwiftUI
import DomainLayer
import WidgetKit

struct ErrorView: View {
	let errorInfo: NetworkErrorResponse.UIInfo

    var body: some View {
		VStack {
			Image(asset: .errorExclamationIcon)
			
			Text(errorInfo.title)
				.multilineTextAlignment(.center)
				.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
				.foregroundColor(Color(colorEnum: .text))
				.minimumScaleFactor(0.8)

			Text(errorInfo.description ?? "")
				.multilineTextAlignment(.center)
				.font(.system(size: CGFloat(.caption)))
				.foregroundColor(Color(colorEnum: .text))
				.minimumScaleFactor(0.8)
		}
		.background(Color(colorEnum: .errorTint))
    }
}

@available(iOSApplicationExtension 17.0, *)
struct ErrorView_Preview: PreviewProvider {
	static var previews: some View {
		ErrorView(errorInfo: .init(title: "Error Error Error Error ", description: "Error descripion"))
			.previewContext(WidgetPreviewContext(family: .systemLarge))
			.containerBackground(for: .widget) {
				Color(colorEnum: .errorTint)
			}
	}
}
