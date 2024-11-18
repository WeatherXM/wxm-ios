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
	let issues: StationChipsView.IssuesChip?
	let areChipsScrollable: Bool
    let showStateIcon: Bool
    let stateFAIcon: StateFontAwesome
    let isStateIconEnabled: Bool
    let tapStateIconAction: VoidCallback?
	let tapWarningAction: VoidCallback?

    var body: some View {
        VStack(spacing: CGFloat(.minimumSpacing)) {
            HStack {
                VStack(spacing: CGFloat(.minimumSpacing)) {
                    HStack {
						Text(device.displayName)
                            .font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
                            .foregroundColor(Color(colorEnum: .text))
                        Spacer()
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
							 isScrollable: areChipsScrollable,
							 warningAction: tapWarningAction)
        }
    }
}

extension StationAddressTitleView {

    init(device: DeviceDetails,
		 followState: UserDeviceFollowState?,
		 issues: StationChipsView.IssuesChip?,
		 areChipsScrollable: Bool = true,
		 showStateIcon: Bool = true,
		 tapStateIconAction: VoidCallback? = nil,
		 tapWarningAction: VoidCallback? = nil) {
		self.device = device
		self.followState = followState
		self.issues = issues
		self.areChipsScrollable = areChipsScrollable
        self.showStateIcon = showStateIcon
        self.stateFAIcon = followState?.state.FAIcon ?? UserDeviceFollowState.defaultFAIcon
        self.isStateIconEnabled = followState?.state.isActionable ?? true
        self.tapStateIconAction = tapStateIconAction
		self.tapWarningAction = tapWarningAction
    }
}
