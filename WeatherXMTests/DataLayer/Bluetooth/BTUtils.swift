//
//  BTUtils.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 18/3/25.
//

@testable import DataLayer
import CoreBluetoothMock

func simulateNormal() async  throws{
	CBMCentralManagerMock.simulatePowerOff()
//	CBMCentralManagerMock.simulatePeripherals([mockHelium, mockBTDevice])
	CBMCentralManagerMock.simulatePowerOn()
	try await Task.sleep(for: .seconds(1))
}

func simulatePoweredOff() async throws {
	CBMCentralManagerMock.simulatePowerOff()
	try await Task.sleep(for: .seconds(1))
}

func simulateNoWXMDevice() async  throws{
	CBMCentralManagerMock.simulatePowerOff()
//	CBMCentralManagerMock.simulatePeripherals([mockBTDevice])
	CBMCentralManagerMock.simulatePowerOn()
	try await Task.sleep(for: .seconds(1))
}

func simulateNotConnectable() async  throws{
	CBMCentralManagerMock.simulatePowerOff()
//	CBMCentralManagerMock.simulatePeripherals([mockNotConnectableHelium, mockBTDevice])
	CBMCentralManagerMock.simulatePowerOn()
	try await Task.sleep(for: .seconds(1))
}
