//
//  StationIfoView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/3/23.
//

import SwiftUI
import Toolkit

struct StationInfoView: View {
    let sections: [Section]
    var contactSupportTitle: String = LocalizableString.contactSupport.localized
	@Binding var showShare: Bool
	let shareText: String
    let shareAction: () -> Void
    let contactSupportAction: () -> Void

    var body: some View {
        VStack(spacing: CGFloat(.defaultSpacing)) {
            HStack {
                Text(LocalizableString.deviceInfoStationInformation.localized)
                    .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))

                Spacer()

                Button(action: shareAction) {
                    HStack(spacing: 0.0) {
                        Image(asset: .shareIcon)
                            .renderingMode(.template)
                            .foregroundColor(Color(colorEnum: .primary))

                        Text(LocalizableString.share.localized)
                            .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                            .foregroundColor(Color(colorEnum: .primary))
                    }
                }
                .buttonStyle(.plain)
				.wxmShareDialog(show: $showShare, text: shareText)

            }

			VStack(spacing: CGFloat(.largeSpacing)) {
				ForEach(sections) { section in
					VStack(spacing: CGFloat(.mediumSpacing)) {
						if let title = section.title {
							HStack {
								Text(title)
									.foregroundStyle(Color(colorEnum: .text))
									.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
								Spacer()
							}
						}
						let rows = section.rows
						ForEach(rows, id: \.tile) { row in
							rowView(for: row)
							if row != rows.last {
								WXMDivider()
							}
						}
					}
				}
			}

            Button(action: contactSupportAction) {
                Text(contactSupportTitle)
            }
            .buttonStyle(WXMButtonStyle())
        }
    }
}

extension StationInfoView {
    struct Row: Equatable {
        static func == (lhs: StationInfoView.Row, rhs: StationInfoView.Row) -> Bool {
            lhs.tile == rhs.tile &&
            lhs.subtitle == rhs.subtitle &&
            lhs.warning?.title == rhs.warning?.title &&
            lhs.buttonIcon == rhs.buttonIcon &&
            lhs.buttonTitle == rhs.buttonTitle
        }

        let tile: String
        let subtitle: String
        var warning: (title: String, appearAction: VoidCallback?)?
        let buttonIcon: AssetEnum?
        let buttonTitle: String?
		let buttonStyle: WXMButtonStyle
        var buttonAction: (() -> Void)?
    }

	struct Section: Identifiable {
		var id: String {
			"\(title ?? "")-\(rows)"
		}

		let title: String?
		let rows: [Row]
	}
}

private extension StationInfoView {
    @ViewBuilder
    func rowView(for row: Row) -> some View {
        VStack(spacing: CGFloat(.smallSpacing)) {
            HStack {
                VStack(alignment: .leading, spacing: 0.0) {
                    Text(row.tile)
                        .font(.system(size: CGFloat(.caption)))
                    Text(row.subtitle)
                        .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                }
                Spacer()
            }

            if let warning = row.warning {
                CardWarningView(message: warning.title, closeAction: nil) {
                    EmptyView()
                }
                .onAppear {
                    warning.appearAction?()
                }
            }

            if let icon = row.buttonIcon,
               let title = row.buttonTitle,
               let action = row.buttonAction {
                Button(action: action) {
                    HStack(spacing: CGFloat(.smallSpacing)) {
                        Image(asset: icon)
                            .renderingMode(.template)
                        Text(title)
                    }
                    .padding()
                }
				.buttonStyle(row.buttonStyle)
            }
        }
    }
}

struct StationInfoView_Previews: PreviewProvider {
    static var previews: some View {
		let rows = [StationInfoView.Row(tile: "title",
										subtitle: "subtile",
										warning: (LocalizableString.deviceInfoLowBatteryWarningMarkdown.localized, nil),
										buttonIcon: .updateFirmwareIcon,
										buttonTitle: "Update firmware",
										buttonStyle: .filled()) {},
					StationInfoView.Row(tile: "title1",
										subtitle: "subtile",
										buttonIcon: nil,
										buttonTitle: nil,
										buttonStyle: .filled()) {}]
		StationInfoView(sections: [.init(title: "Section title", rows: rows)],
						showShare: .constant(false),
						shareText: "",
                        shareAction: {},
                        contactSupportAction: {})
        .padding()
    }
}
