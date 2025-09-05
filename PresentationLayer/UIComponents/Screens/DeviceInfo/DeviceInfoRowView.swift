//
//  DeviceInfoRowView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/3/23.
//

import SwiftUI
import NukeUI

struct DeviceInfoRowView: View {
    let row: Row

    var body: some View {
        VStack(spacing: CGFloat(.smallToMediumSpacing)) {
			VStack(spacing: CGFloat(.smallSpacing)) {
                HStack {
                    Text(row.title)
                        .foregroundColor(Color(colorEnum: .darkestBlue))
                        .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))

					Spacer()

					if let badge = row.badge {
						Text(badge.uppercased())
							.foregroundColor(Color(colorEnum: .wxmPrimary))
							.font(.system(size: CGFloat(.littleCaption), weight: .bold))
							.padding(.horizontal, CGFloat(.smallSidePadding))
							.padding(.vertical, CGFloat(.minimumPadding))
							.background {
								Capsule().fill(Color(colorEnum: .layer2))
							}
					}
                }

                HStack {
                    Text(row.description)
						.fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(colorEnum: .darkestBlue))
                        .font(.system(size: CGFloat(.normalFontSize)))
                        .tint(Color(colorEnum: .wxmPrimary))
						.if(row.isDescriptionCopyable) { view in
							view
								.textSelection(.enabled)
						}
                    Spacer()
                }
            }

            warningView

			VStack(spacing: CGFloat(.smallSpacing)) {
				if let url = row.imageUrl {
					LazyImage(url: url) { state in
						if let image = state.image {
							image
								.resizable()
								.aspectRatio(MapBoxConstants.snapshotSize.width / MapBoxConstants.snapshotSize.height,
											 contentMode: .fill)
								.frame(maxHeight: MapBoxConstants.snapshotSize.height)
								.clipped()
								.cornerRadius(CGFloat(.buttonCornerRadius))
						} else {
							ProgressView()
						}
					}
				}

				if let buttonInfo = row.buttonInfo {
					Button(action: row.buttonAction) {
						HStack(spacing: CGFloat(.smallSpacing)) {
							if let icon = buttonInfo.icon {
								Image(asset: icon)
									.renderingMode(.template)
							}
							Text(buttonInfo.title ?? "")
						}
					}
					.modify { button in
						if let warning = row.warning {
							button.buttonStyle(WXMButtonStyle(textColor: .darkestBlue, fillColor: warning.tintColor, strokeColor: warning.color))
						} else {
							button.buttonStyle(buttonInfo.buttonStyle)
						}
					}
				}

				if let customView = row.customView {
					customView
				}
			}
        }
    }
}

extension DeviceInfoRowView {
    struct Row: Equatable {
        static func == (lhs: DeviceInfoRowView.Row, rhs: DeviceInfoRowView.Row) -> Bool {
            lhs.title == rhs.title &&
			lhs.badge == rhs.badge &&
            lhs.description == rhs.description &&
			lhs.imageUrl == rhs.imageUrl &&
            lhs.buttonInfo == rhs.buttonInfo &&
            lhs.warning == rhs.warning
        }

        let title: String
		var badge: String?
        let description: AttributedString
		var isDescriptionCopyable: Bool = false
		let imageUrl: URL?
        let buttonInfo: DeviceInfoButtonInfo?
        var warning: Warning?
		var customView: AnyView?
        let buttonAction: () -> Void
    }
}

extension DeviceInfoRowView.Row {
    enum Warning: Equatable {
        case normal(String)
        case desructive(String)

        var color: ColorEnum {
            switch self {
                case .normal:
                    return .warning
                case .desructive:
                    return .error
            }
        }

        var tintColor: ColorEnum {
            switch self {
                case .normal:
                    return .warningTint
                case .desructive:
                    return .errorTint
            }
        }
    }
}

private extension DeviceInfoRowView {
    @ViewBuilder
    var warningView: some View {
        if let warning = row.warning {
            HStack(spacing: 0.0) {
                Image(asset: .warningIcon)
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: warning.color))

                Group {
                    switch warning {
                        case .normal(let text):
                            Text(text)
                        case .desructive(let text):
                            Text(text)
                    }
                }
                .foregroundColor(Color(colorEnum: .darkestBlue))
                .font(.system(size: CGFloat(.normalFontSize), weight: .bold))

                Spacer()
            }
        } else {
            EmptyView()
        }
    }
}

struct DeviceInfoRowView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceInfoRowView(row: DeviceInfoRowView.Row(title: "TItle",
													 badge: "New",
                                                     description: "This is a **desription**".attributedMarkdown!,
													 imageUrl: URL(string: "https://i0.wp.com/weatherxm.com/wp-content/uploads/2023/12/Home-header-image-1200-x-1200-px-5.png?w=1200&ssl=1"),
													 buttonInfo: .init(icon: nil, title: "Button title"),
                                                     warning: .desructive("This action is not reversible!")) {})
    }
}
