//
//  StationSupportView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 22/9/25.
//

import SwiftUI
import MarkdownUI

struct StationSupportView: View {
	@StateObject var viewModel: StationSupportViewModel

	var body: some View {
		ZStack {
			Color(colorEnum: .top)
				.ignoresSafeArea()

			ScrollView {
				Group {
					switch viewModel.mode {
						case .content(let markdown):
							markDownView(markdownString: markdown)
								.transition(AnyTransition.opacity.animation(.easeIn))
						case .loading:
							loadingView
						case .error:
							EmptyView()
					}
				}
				.padding()
			}
		}
		.task {
			viewModel.refresh()
		}
	}
}

extension StationSupportView {
	enum Mode {
		case content(markdownString: String)
		case loading
		case error
	}
}

private extension StationSupportView {
	@ViewBuilder
	func markDownView(markdownString: String) -> some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			HStack {
				Text(LocalizableString.StationDetails.aiHealthCheck.localized)
					.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

			Markdown(markdownString)
				.markdownTextStyle {
					FontFamily(.system(.default))
					FontSize(CGFloat(.normalFontSize))
					ForegroundColor(Color(colorEnum: .text))
				}
		}
		.padding(.top, CGFloat(.defaultSidePadding))
	}

	@ViewBuilder
	var loadingView: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			SpinningLoaderView()
				.background {
					Circle().foregroundStyle(Color(colorEnum: .bg))
				}
				.wxmShadow()

			VStack(spacing: CGFloat(.largeSpacing)) {
				Text(LocalizableString.StationDetails.analyzingYourStation.localized)
					.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Text(LocalizableString.StationDetails.analyzingYourStationDescription.localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundStyle(Color(colorEnum: .text))
			}
			.multilineTextAlignment(.center)
		}
		.padding(.top, CGFloat(.defaultSidePadding))
	}
}

#Preview {
	StationSupportView(viewModel: ViewModelsFactory.getStationSupportViewModel(deviceName: ""))
}
