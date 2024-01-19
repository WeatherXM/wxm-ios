//
//  FailSuccessStateObject.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/3/23.
//

import Foundation

struct FailSuccessStateObject {
    let type: SuccessFailEnum
    let title: String
    let subtitle: AttributedString?
    let cancelTitle: String?
    let retryTitle: String?
	var actionButtonsAtTheBottom: Bool = true
    let contactSupportAction: (() -> Void)?
    let cancelAction: (() -> Void)?
    let retryAction: (() -> Void)?
}

extension FailSuccessStateObject {
    static var mockSuccessObj: FailSuccessStateObject {
        FailSuccessStateObject(type: .changeFrequency,
                               title: "Station Updated!",
                               subtitle: "Your station is updated to the latest Firmware!",
                               cancelTitle: nil,
                               retryTitle: "View Station",
                               contactSupportAction: nil,
                               cancelAction: nil,
                               retryAction: nil)
    }

    static var mockErrorObj: FailSuccessStateObject {
        return FailSuccessStateObject(type: .changeFrequency,
                                      title: "Update Failed",
                                      subtitle: "Pairing failed, please try again! If the problem persists, please contact our support team at support.weatherxm.com \n \n Please make sure to mention that you’re facing an **Error 666** for faster resolution".attributedMarkdown,
                                      cancelTitle: "Cancel",
                                      retryTitle: "Retry Updating",
									  actionButtonsAtTheBottom: false,
                                      contactSupportAction: nil,
									  cancelAction: nil,
									  retryAction: {})
    }
}
