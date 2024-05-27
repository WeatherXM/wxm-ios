//
//  UIDevice+.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 3/11/22.
//

import Foundation
import UIKit

public extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String {
#if os(iOS)
            switch identifier {
                case "iPod5,1": return "iPod-touch-(5th generation)"
                case "iPod7,1": return "iPod-touch-(6th generation)"
                case "iPod9,1": return "iPod-touch-(7th generation)"
                case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone-4"
                case "iPhone4,1": return "iPhone-4s"
                case "iPhone5,1", "iPhone5,2": return "iPhone-5"
                case "iPhone5,3", "iPhone5,4": return "iPhone-5c"
                case "iPhone6,1", "iPhone6,2": return "iPhone-5s"
                case "iPhone7,2": return "iPhone-6"
                case "iPhone7,1": return "iPhone-6-Plus"
                case "iPhone8,1": return "iPhone-6s"
                case "iPhone8,2": return "iPhone-6s-Plus"
                case "iPhone9,1", "iPhone9,3": return "iPhone-7"
                case "iPhone9,2", "iPhone9,4": return "iPhone-7-Plus"
                case "iPhone10,1", "iPhone10,4": return "iPhone-8"
                case "iPhone10,2", "iPhone10,5": return "iPhone-8-Plus"
                case "iPhone10,3", "iPhone10,6": return "iPhone-X"
                case "iPhone11,2": return "iPhone XS"
                case "iPhone11,4", "iPhone11,6": return "iPhone-XS-Max"
                case "iPhone11,8": return "iPhone-XR"
                case "iPhone12,1": return "iPhone-11"
                case "iPhone12,3": return "iPhone-11-Pro"
                case "iPhone12,5": return "iPhone-11-Pro-Max"
                case "iPhone13,1": return "iPhone-12-mini"
                case "iPhone13,2": return "iPhone-12"
                case "iPhone13,3": return "iPhone-12-Pro"
                case "iPhone13,4": return "iPhone-12-Pro-Max"
                case "iPhone14,4": return "iPhone-13-mini"
                case "iPhone14,5": return "iPhone-13"
                case "iPhone14,2": return "iPhone-13-Pro"
                case "iPhone14,3": return "iPhone-13-Pro-Max"
                case "iPhone14,7": return "iPhone-14"
                case "iPhone14,8": return "iPhone-14-Plus"
                case "iPhone15,2": return "iPhone-14-Pro"
                case "iPhone15,3": return "iPhone-14-Pro-Max"
                case "iPhone8,4": return "iPhone-SE"
                case "iPhone12,8": return "iPhone-SE-(2nd-generation)"
                case "iPhone14,6": return "iPhone-SE-(3rd-generation)"
                case "i386", "x86_64", "arm64": return "Simulator-\(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
                default: return identifier
            }
#else
            return "Not-an-iphone"
#endif
        }

        return mapToDevice(identifier: identifier)
    }()

	var isIPad: Bool {
		UIDevice.current.userInterfaceIdiom == .pad
	}
}

public var isPreview: Bool {
	return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

public var disableAnalytics: Bool {
	let isDisabled = UserDefaults.standard.bool(forKey: WXMAnalyticsDisabled)
	return isPreview || isDisabled
}
