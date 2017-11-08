//
//  TransmitterManager.swift
//  RemoteVirtual
//
//  Created by Sorawit on 10/21/17.
//  Copyright © 2017 Sorawit. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

protocol TransmitterManagerDelegate {
    func didUpdateState(state: CBCentralManagerState)
    func didReceiveReady()
}

class TransmitterManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    var delegate: TransmitterManagerDelegate?
    var manager: CBCentralManager!
    var BT: CBPeripheral!
    var deviceCharacteristics: CBCharacteristic!
    var bluetoothName = "BT05"
    let bluetoothID = 0
    let bluetoothUUIDs = ["8AF49649-3708-13C4-8407-5E57CF5E6B8E"]
    let bluetoothUUID: String
    var running = false
    var input = ""
    
    
    override init() {
        bluetoothUUID = bluetoothUUIDs[bluetoothID]
        
        super.init()
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func receivedReadyMessage() {
        running = false
        delegate?.didReceiveReady()
    }
    
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.didUpdateState(state: CBCentralManagerState(rawValue: central.state.rawValue)!)
        
        if central.state == .poweredOn {
            
            self.manager.scanForPeripherals(withServices: nil, options: nil) //Scan device
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.identifier.uuidString)
        if peripheral.identifier.uuidString == bluetoothUUID {
            self.BT = peripheral
            self.BT.delegate = self
            manager.stopScan()
            manager.connect(self.BT, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func writeValue(dataRaw: [UInt8]) {
        //        let data = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        let data = Data(bytes: dataRaw)
        if let peripheralDevice = BT {
            if let deviceCharacteristics = deviceCharacteristics {
                peripheralDevice.writeValue(data, for: deviceCharacteristics, type: CBCharacteristicWriteType.withoutResponse)
            }
        }
    }
    
    func writeValue(dataRaw: String) {
        let data = (dataRaw as NSString).data(using: String.Encoding.utf8.rawValue)
        if let peripheralDevice = BT {
            if let deviceCharacteristics = deviceCharacteristics {
                peripheralDevice.writeValue(data!, for: deviceCharacteristics, type: CBCharacteristicWriteType.withoutResponse)
            }
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripherrals = peripheral.services as [CBService]!{
            for service in servicePeripherrals{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        // check the uuid of each characteristic to find config and data characteristics
        for charateristic in service.characteristics! {
            
            let thisCharacteristic = charateristic as CBCharacteristic
            // Set notify for characteristics here.
            peripheral.setNotifyValue(true, for: thisCharacteristic)
            deviceCharacteristics = thisCharacteristic
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        
    }
    
    
    
}

