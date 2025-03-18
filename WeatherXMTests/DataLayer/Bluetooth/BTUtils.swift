//
//  BTUtils.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 18/3/25.
//

@testable import DataLayer
import CoreBluetoothMock

func simulateNormal() async  throws{
	CBMCentralManagerMock.simulateInitialState(.poweredOn)
	CBMCentralManagerMock.simulatePeripherals([mockHelium, mockBTDevice])
	try await Task.sleep(for: .seconds(1))
}

func simulatePoweredOff() async throws {
	CBMCentralManagerMock.simulateInitialState(.poweredOff)
	try await Task.sleep(for: .seconds(1))
}

func simulateNoWXMDevice() async  throws{
	CBMCentralManagerMock.simulateInitialState(.poweredOn)
	CBMCentralManagerMock.simulatePeripherals([mockBTDevice])
	try await Task.sleep(for: .seconds(1))
}

func simulateNotConnectable() async  throws{
	CBMCentralManagerMock.simulateInitialState(.poweredOn)
	CBMCentralManagerMock.simulatePeripherals([mockNotConnectableHelium, mockBTDevice])
	try await Task.sleep(for: .seconds(1))
}
