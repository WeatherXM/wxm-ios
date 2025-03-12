//
//  Aliases.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 12/3/25.
//

import Foundation
import CoreBluetoothMock

// Copy this file to your project to start using CoreBluetoothMock classes
// without having to refactor any of your code. You will just have to remove
// the imports to CoreBluetooth to fix conflicts and initiate the manager
// using CBCentralManagerFactory, instad of just creating a CBCentralManager.

// disabled for Xcode 12.5 beta
//typealias CBPeer                          = CBMPeer
//typealias CBAttribute                     = CBMAttribute
typealias CBCentralManagerFactory         = CBMCentralManagerFactory
typealias CBUUID                          = CBMUUID
typealias CBError                         = CBMError
typealias CBATTError                      = CBMATTError
typealias CBManagerState                  = CBMManagerState
typealias CBPeripheralState               = CBMPeripheralState
typealias CBCentralManager                = CBMCentralManager
typealias CBCentralManagerDelegate        = CBMCentralManagerDelegate
typealias CBPeripheral                    = CBMPeripheral
typealias CBPeripheralDelegate            = CBMPeripheralDelegate
typealias CBService                       = CBMService
typealias CBCharacteristic                = CBMCharacteristic
typealias CBCharacteristicWriteType       = CBMCharacteristicWriteType
typealias CBCharacteristicProperties      = CBMCharacteristicProperties
typealias CBDescriptor                    = CBMDescriptor
typealias CBConnectionEvent               = CBMConnectionEvent
typealias CBConnectionEventMatchingOption = CBMConnectionEventMatchingOption
@available(iOS 11.0, tvOS 11.0, watchOS 4.0, *)
typealias CBL2CAPPSM                      = CBML2CAPPSM
@available(iOS 11.0, tvOS 11.0, watchOS 4.0, *)
typealias CBL2CAPChannel                  = CBML2CAPChannel

let CBCentralManagerScanOptionAllowDuplicatesKey       = CBMCentralManagerScanOptionAllowDuplicatesKey
let CBCentralManagerOptionShowPowerAlertKey            = CBMCentralManagerOptionShowPowerAlertKey
let CBCentralManagerOptionRestoreIdentifierKey         = CBMCentralManagerOptionRestoreIdentifierKey
let CBCentralManagerScanOptionSolicitedServiceUUIDsKey = CBMCentralManagerScanOptionSolicitedServiceUUIDsKey
let CBConnectPeripheralOptionStartDelayKey             = CBMConnectPeripheralOptionStartDelayKey
#if !os(macOS)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
let CBConnectPeripheralOptionRequiresANCS              = CBMConnectPeripheralOptionRequiresANCS
#endif
let CBCentralManagerRestoredStatePeripheralsKey        = CBMCentralManagerRestoredStatePeripheralsKey
let CBCentralManagerRestoredStateScanServicesKey       = CBMCentralManagerRestoredStateScanServicesKey
let CBCentralManagerRestoredStateScanOptionsKey        = CBMCentralManagerRestoredStateScanOptionsKey

let CBAdvertisementDataLocalNameKey                    = CBMAdvertisementDataLocalNameKey
let CBAdvertisementDataServiceUUIDsKey                 = CBMAdvertisementDataServiceUUIDsKey
let CBAdvertisementDataIsConnectable                   = CBMAdvertisementDataIsConnectable
let CBAdvertisementDataTxPowerLevelKey                 = CBMAdvertisementDataTxPowerLevelKey
let CBAdvertisementDataServiceDataKey                  = CBMAdvertisementDataServiceDataKey
let CBAdvertisementDataManufacturerDataKey             = CBMAdvertisementDataManufacturerDataKey
let CBAdvertisementDataOverflowServiceUUIDsKey         = CBMAdvertisementDataOverflowServiceUUIDsKey
let CBAdvertisementDataSolicitedServiceUUIDsKey        = CBMAdvertisementDataSolicitedServiceUUIDsKey

let CBConnectPeripheralOptionNotifyOnConnectionKey     = CBMConnectPeripheralOptionNotifyOnConnectionKey
let CBConnectPeripheralOptionNotifyOnDisconnectionKey  = CBMConnectPeripheralOptionNotifyOnDisconnectionKey
let CBConnectPeripheralOptionNotifyOnNotificationKey   = CBMConnectPeripheralOptionNotifyOnNotificationKey
