//
//  Common.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 27/3/23.
//

import Foundation

/// The icon color for each state
func activeStateColor(isActive: Bool) -> ColorEnum {
    isActive ? .stationChipOnlineStateText : .stationChipOfflineStateText
}

/// The tint color for for each state
func activeStateTintColor(isActive: Bool) -> ColorEnum {
    isActive ? .stationChipOnlineStateBg : .stationChipOfflineStateBg
}
