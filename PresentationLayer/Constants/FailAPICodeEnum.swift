//
//  FailAPICodeEnum.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 6/6/22.
//

import Foundation

enum FailAPICodeEnum: String {
    case invalidUsername = "InvalidUsername"
    case invalidPassword = "InvalidPassword"
    case invalidCredentials = "InvalidCredentials"
    case userAlreadyExists = "UserAlreadyExists"
    case invalidAccessToken = "InvalidAccessToken"
    case deviceNotFound = "DeviceNotFound"
    case invalidWalletAddress = "InvalidWalletAddress"
    case invalidFriendlyName = "InvalidFriendlyName"
    case invalidFromDate = "InvalidFromDate"
    case invalidToDate = "InvalidToDate"
    case invalidTimezone = "InvalidTimezone"
    case invalidClaimId = "InvalidClaimId"
    case invalidClaimLocation = "InvalidClaimLocation"
    case deviceAlreadyClaimed = "DeviceAlreadyClaimed"
    case deviceClaiming = "DeviceClaiming"
    case unauthorized = "Unauthorized"
    case userNotFound = "UserNotFound"
    case forbidden = "Forbidden"
    case validation = "Validation"
    case notFound = "NotFound"
	case walletAddressNotFound = "WalletAddressNotFound"
	case unsupportedApplicationVersion = "UnsupportedApplicationVersion"
	case tooManyRequests = "TooManyRequests"
}
