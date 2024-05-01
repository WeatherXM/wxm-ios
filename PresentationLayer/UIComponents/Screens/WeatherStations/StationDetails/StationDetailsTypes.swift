//
//  StationDetailsTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/3/23.
//

import Foundation
import DomainLayer
import SwiftUI
import Toolkit

enum ViewState {
    case loading
    case fail
    case content
    case hidden
	case empty
}

struct StationAddressTitleView: View {
	
	let device: DeviceDetails
	let followState: UserDeviceFollowState?
    let subtitle: String?
	let issues: StationChipsView.IssuesChip?
    let showStateIcon: Bool
    let stateFAIcon: StateFontAwesome
    let isStateIconEnabled: Bool
    let tapStateIconAction: VoidCallback?
    let tapAddressAction: VoidCallback?
	let tapWarningAction: VoidCallback?
	let tapStatusAction: VoidCallback?

    var body: some View {
        VStack(spacing: CGFloat(.mediumSpacing)) {
            HStack {
                VStack(spacing: CGFloat(.minimumSpacing)) {
                    HStack {
						Text(device.displayName)
                            .font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
                            .foregroundColor(Color(colorEnum: .text))
                        Spacer()
                    }

                    if let subtitle {
                        HStack {
                            Text(subtitle)
                                .font(.system(size: CGFloat(.caption)))
                                .foregroundColor(Color(colorEnum: .darkGrey))
                            Spacer()
                        }

                    }
                }

                if showStateIcon {
                    Button {
                        tapStateIconAction?()
                    } label: {
                        Text(stateFAIcon.icon.rawValue)
                            .font(.fontAwesome(font: stateFAIcon.font, size: CGFloat(.mediumFontSize)))
                            .foregroundColor(Color(colorEnum: stateFAIcon.color))
                            .frame(width: 30.0, height: 30.0)
                    }
                    .buttonStyle(.plain)
                    .allowsHitTesting(isStateIconEnabled)
                }
            }

			StationChipsView(device: device,
							 issues: issues,
							 addressAction: tapAddressAction,
							 warningAction: tapWarningAction,
							 statusAction: tapStatusAction)
        }
    }
}

extension StationAddressTitleView {

    init(device: DeviceDetails,
		 followState: UserDeviceFollowState?,
		 issues: StationChipsView.IssuesChip?,
		 showSubtitle: Bool = true,
		 showStateIcon: Bool = true,
		 tapStateIconAction: VoidCallback? = nil,
		 tapAddressAction: VoidCallback? = nil,
		 tapWarningAction: VoidCallback? = nil,
		 tapStatusAction: VoidCallback? = nil) {
		self.device = device
		self.followState = followState
        let subtitle = device.friendlyName != nil ? device.name : nil
        self.subtitle = showSubtitle ? subtitle : nil
		self.issues = issues
        self.showStateIcon = showStateIcon
        self.stateFAIcon = followState?.state.FAIcon ?? UserDeviceFollowState.defaultFAIcon
        self.isStateIconEnabled = followState?.state.isActionable ?? true
        self.tapStateIconAction = tapStateIconAction
        self.tapAddressAction = tapAddressAction
		self.tapWarningAction = tapWarningAction
		self.tapStatusAction = tapStatusAction
    }
}
