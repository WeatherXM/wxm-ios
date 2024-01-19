//
//  HeliumDevice.swift
//  DomainLayer
//
//  Created by Manolis Katsifarakis on 1/10/22.
//

public struct HeliumDevice: Equatable {
    public var devEUI: String
    public var deviceKey: String

    public init(devEUI: String, deviceKey: String) {
        self.devEUI = devEUI
        self.deviceKey = deviceKey
    }
}
