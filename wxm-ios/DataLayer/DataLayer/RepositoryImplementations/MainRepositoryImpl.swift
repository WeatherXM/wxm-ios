//
//  MainRepositoryImpl.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 29/10/24.
//

import Foundation
import DomainLayer
#if DEBUG
import Pulse
import PulseProxy
#endif

public struct MainRepositoryImpl: MainRepository {
	public init() {}
	
	public func initializeHttpMonitor() {
	#if DEBUG
		NetworkLogger.enableProxy()
	#endif
	}

}
