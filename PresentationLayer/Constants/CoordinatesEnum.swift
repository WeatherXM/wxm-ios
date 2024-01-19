//
//  CoordinatesEnum.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 3/6/22.
//

import CoreLocation
import Foundation
enum CoordinatesEnum {
    case claimDeviceMapBox

    var imageName: String {
        switch self {
            case .claimDeviceMapBox:
                return "red_pin"
        }
    }
}
