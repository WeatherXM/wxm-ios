//
//  AppUpdateView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/12/23.
//

import SwiftUI
import MarkdownUI

struct AppUpdateView: View {
	@Binding var show: Bool
	@StateObject var viewModel: AppUpdateViewModel

    var body: some View {
		NavigationContainerView(showBackButton: false) {
			ContentView(show: $show, viewModel: viewModel)
		}
    }
}

private struct ContentView: View {
	@Binding var show: Bool
	@ObservedObject var viewModel: AppUpdateViewModel
	@EnvironmentObject var navigationObject: NavigationObject
	
	var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()

			VStack(spacing: CGFloat(.defaultSpacing)) {
				ScrollView {
					VStack(spacing: CGFloat(.defaultSpacing)) {
						HStack {
							Text(LocalizableString.AppUpdate.description.localized)
								.font(.system(size: CGFloat(.mediumFontSize)))

							Spacer()
						}

						HStack {
							Text(LocalizableString.AppUpdate.whatsNewTitle.localized)
								.font(.system(size: CGFloat(.titleFontSize), weight: .bold))

							Spacer()
						}

						HStack {
							Markdown(viewModel.whatsNewText ?? "-")
								.markdownTextStyle {
									FontSize(CGFloat(.mediumFontSize))
									FontFamily(.system(.default))
									ForegroundColor(Color(colorEnum: .text))
								}

							Spacer()
						}
					}
					.foregroundStyle(Color(colorEnum: .text))
				}
				.scrollIndicators(.hidden)

				Spacer(minLength: 0.0)

				VStack(spacing: CGFloat(.smallSpacing)) {
					Button {
						viewModel.handleUpdateButtonTap()
					} label: {
						Text(LocalizableString.AppUpdate.updateButtonTitle.localized)
					}
					.buttonStyle(WXMButtonStyle.filled())

					if !viewModel.forceUpdate {
						Button {
							viewModel.handleNoUpdateButtonTap()
							show = false
						} label: {
							Text(LocalizableString.AppUpdate.noUpdateButtonTitle.localized)
						}
						.buttonStyle(WXMButtonStyle.plain())
					}
				}
			}
			.WXMCardStyle()
			.padding(CGFloat(.defaultSidePadding))
		}
		.onAppear {
			navigationObject.title = LocalizableString.AppUpdate.title.localized
			navigationObject.navigationBarColor = Color(colorEnum: .bg)
			viewModel.viewAppeared()
		}
	}
}

#Preview {
	AppUpdateView(show: .constant(true),
				  viewModel: ViewModelsFactory.getAppUpdateViewModel())
}
