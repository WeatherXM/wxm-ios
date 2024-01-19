//
//  AlertHelper+Follow.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 24/8/23.
//

import Foundation
import Toolkit

extension AlertHelper {

    static func showFollowInActiveStationAlert(deviceName: String, okAction: @escaping VoidCallback) {
        let title = LocalizableString.followAlertTitle.localized
        let description = LocalizableString.followAlertDescription(deviceName).localized
        let okAction: AlertHelper.AlertObject.Action = (LocalizableString.confirm.localized, { _ in okAction() })

        let obj = AlertHelper.AlertObject(title: title,
                                          message: description,
                                          okAction: okAction)
        AlertHelper().showAlert(obj)
    }

    static func showUnFollowStationAlert(deviceName: String, okAction: @escaping VoidCallback) {
        let title = LocalizableString.unfollowAlertTitle.localized
        let description = LocalizableString.unfollowAlertDescription(deviceName).localized
        let okAction: AlertHelper.AlertObject.Action = (LocalizableString.confirm.localized, { _ in okAction() })

        let obj = AlertHelper.AlertObject(title: title,
                                          message: description,
                                          okAction: okAction)
        AlertHelper().showAlert(obj)
    }
}
