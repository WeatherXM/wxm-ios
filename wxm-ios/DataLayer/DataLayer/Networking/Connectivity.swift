//
//  Connectivity.swift
//  DataLayer
//
//  Created by Hristos Condrea on 8/6/22.
//

import Alamofire
import Foundation

class Connectivity {
    class var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
