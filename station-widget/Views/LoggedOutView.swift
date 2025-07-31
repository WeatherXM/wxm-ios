//
//  LoggedOutView.swift
//  station-widgetExtension
//
//  Created by Pantelis Giazitsis on 2/10/23.
//

import SwiftUI
import WidgetKit

struct LoggedOutView: View {

	@Environment(\.widgetFamily) var family: WidgetFamily

	var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			
			VStack(spacing: CGFloat(.smallSpacing)) {
				Text(LocalizableString.Widget.loggedOutTitle.localized)
					.font(.system(size: titleFontSize(), weight: .bold))
					.multilineTextAlignment(.center)
				
				Text(LocalizableString.Widget.loggedOutDescription.localized)
					.font(.system(size: descriptionFontSize()))
					.multilineTextAlignment(.center)
					.fixedSize(horizontal: false, vertical: true)
			}
			
			Button {
				
			} label: {
				HStack {
					Spacer()
					Text(LocalizableString.login.localized)
					Spacer()
				}
				.padding(.vertical, CGFloat(.smallToMediumSpacing))
			}
			.buttonStyle(WXMButtonStyle.filled(fixedSize: true))
		}
		.padding(.horizontal, CGFloat(.smallSidePadding))
		.widgetBackground {
			Color(colorEnum: .bg)
		}
	}
}

private extension LoggedOutView {
	func titleFontSize() -> CGFloat {
		switch family {
			case .systemSmall:
				CGFloat(.mediumFontSize)
			case .systemMedium:
				CGFloat(.normalFontSize)
			case .systemLarge:
				CGFloat(.largeTitleFontSize)
			default:
				CGFloat(.mediumFontSize)
		}
	}

	func descriptionFontSize() -> CGFloat {
		switch family {
			case .systemSmall:
				CGFloat(.caption)
			case .systemMedium:
				CGFloat(.mediumFontSize)
			case .systemLarge:
				CGFloat(.largeFontSize)
			default:
				CGFloat(.mediumFontSize)
		}
	}
}

@available(iOSApplicationExtension 17.0, *)
struct LoggedOutView_Preview: PreviewProvider {
	static var previews: some View {
		Group {
			LoggedOutView()
				.previewContext(WidgetPreviewContext(family: .systemSmall))
			LoggedOutView()
				.previewContext(WidgetPreviewContext(family: .systemMedium))
			LoggedOutView()
				.previewContext(WidgetPreviewContext(family: .systemLarge))

		}
		.containerBackground(for: .widget) {
			Color.cyan
		}
	}
}
