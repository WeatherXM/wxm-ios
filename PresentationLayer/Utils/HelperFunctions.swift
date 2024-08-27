//
//  HelperFunctions.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 10/6/22.
//

import Foundation
import SwiftUI
import Toolkit

struct HelperFunctions {

    func openUrl(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
	
	/// Opens support url.
	/// Currently the parameters are not submitted. We keep this functionaliy from the old flow (with the email below) for the future
	/// - Parameters:
	///   - successFailureEnum: The failure type
	///   - email: User's email
	///   - serialNumber: The station's serial number, if exists
	///   - errorString: The error text for the support
	///   - addtionalInfo: Any additional info
	///   - trackSelectContentEvent: Track the event or not
	func openContactSupport(successFailureEnum: SuccessFailEnum,
							email: String?,
							serialNumber: String? = nil,
							errorString: String? = nil,
							addtionalInfo: String? = nil,
							trackSelectContentEvent: Bool = true) {
		guard let supportUrl: String = Bundle.main.getConfiguration(for: .supportUrl) else {
			return
		}

		if trackSelectContentEvent {
			WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .contactSupport,
																  .source: .errorSource])
		}

		openUrl(supportUrl)
	}

	private func openContactSupportEmail(successFailureEnum: SuccessFailEnum,
										 email: String?, serialNumber: String?,
										 errorString: String? = nil,
										 addtionalInfo: String? = nil,
										 trackSelectContentEvent: Bool = true) {
		if trackSelectContentEvent {
			WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .contactSupport,
																  .source: .errorSource])
		}
		
		Task {
			await sendMail(successFailureEnum: successFailureEnum, email: email, serialNumber: serialNumber, errorString: errorString, addtionalInfo: addtionalInfo)
		}
	}

    private func sendMail(successFailureEnum: SuccessFailEnum, email: String?, serialNumber: String?, errorString: String? = nil, addtionalInfo: String? = nil) async {
        let subject: String = successFailureEnum.description.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let firstBodyParameter: String
        if successFailureEnum == .register {
            firstBodyParameter = (Constants.noActivationEmailDesc + (email ?? "-")).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        } else {
            firstBodyParameter = (Constants.cannotClaimDeviceBodyUserAccount + (email ?? "-")).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        }

        var finalEmailString = "mailto:\(Constants.weatherXMSupportEmail)?subject=\(subject)&body=\(firstBodyParameter)"

        if let appVersion = Bundle.main.releaseVersionNumber {
            let appVersionParameter = ("\n" + (Constants.appVersion + appVersion)).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
            finalEmailString.append(appVersionParameter)
        }

        if let serialNumber {
            let serialNumberParameter = ("\n" + (Constants.cannotClaimDeviceBodyDeviceSN + serialNumber.replaceColonOcurrancies()))
				.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
            finalEmailString.append(serialNumberParameter)
        }

        let installationId = await FirebaseManager.shared.getInstallationId()
        let installationIdParameter = ("\n" + (Constants.installationId + installationId)).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        finalEmailString.append(installationIdParameter)

        let versionParameter = await ("\n" + (Constants.iOSVersion + (UIDevice.current.systemVersion))).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        finalEmailString.append(versionParameter)

        if let errorString {
            let errorParameter = ("\n" + (Constants.error + errorString)).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
            finalEmailString.append(errorParameter)
        }

        if let addtionalInfo {
            let info = ("\n\n" + addtionalInfo).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
            finalEmailString.append(info)
        }

		let leaveMessageNote = ("\n\n" + LocalizableString.mailLeaveMessageNote.localized + "\n" + "-------------------------").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
		finalEmailString.append(leaveMessageNote)

        if let url = URL(string: finalEmailString) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    }
}

private extension HelperFunctions {
    enum Constants {
        static let weatherXMSupportEmail = "support@weatherxm.com"
        static let iOSVersion = "iOS Version: "
        static let noActivationEmailDesc = "User account email: "
        static let cannotClaimDeviceBodyUserAccount = "User account email: "
        static let cannotClaimDeviceBodyDeviceSN = "Device S/N: "
        static let appVersion = "App Version: "
        static let installationId = "Installation ID: "
        static let error = "Error: "
    }
}
