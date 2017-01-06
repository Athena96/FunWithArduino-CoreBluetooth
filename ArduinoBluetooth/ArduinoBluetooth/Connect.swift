//
//  Connect.swift
//  ArduinoBluetooth
//
//  Created by Jared Franzone on 1/6/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import Foundation
import CoreBluetooth

let BTServicesUUID = CBUUID(string: "025A7775-49AA-42BD-BBDB-E2AE77782966")
let ServoSpeedCharUUID = CBUUID(string: "F38A2C23-BC54-40FC-BED0-60EDDA139F47")
let BTServiceChangedNotification = "BTServiceChangedNotification"

class BluetoothConnect: NSObject, CBPeripheralDelegate {
    private var arduinoPeripheral: CBPeripheral?
    
    private var servoSpeedCharacteristic: CBCharacteristic?
    
    init(withPeripheral peripheral: CBPeripheral) {
        super.init()
        self.arduinoPeripheral = peripheral
        self.arduinoPeripheral?.delegate = self
    }
    
    deinit {
        self.reset()
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if peripheral != self.arduinoPeripheral || error != nil {
            return
        }
        if let arduinoServices = peripheral.services, peripheral.services?.count != 0 {
            let uuidsForService: [CBUUID] = [ServoSpeedCharUUID]
            for service in arduinoServices {
                if service.uuid == BTServicesUUID {
                    peripheral.discoverCharacteristics(uuidsForService, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if peripheral != self.arduinoPeripheral || error != nil {
            return
        }
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == ServoSpeedCharUUID {
                    self.servoSpeedCharacteristic = characteristic
                    self.postBTStatusNotification(isConnected: true)
                }
            }
        }
    }
    
    // MARK: - Public
    func discoverServices() {
        self.arduinoPeripheral?.discoverServices([BTServicesUUID])
    }
    
    func writeSpeed(_ speed: UInt8) {
        if let speedCharacteristic = self.servoSpeedCharacteristic {
            let data = Data(bytes: [speed])
            self.arduinoPeripheral?.writeValue(data, for: speedCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    // MARK: - Helper
    private func reset() {
        if arduinoPeripheral != nil {
            arduinoPeripheral = nil
        }
        self.postBTStatusNotification(isConnected: false)
    }
    
    private func postBTStatusNotification(isConnected status: Bool) {
        let connectionDetails = ["isConnected": status]
        NotificationCenter.default.post(name: Notification.Name(rawValue: BTServiceChangedNotification), object: self, userInfo: connectionDetails)
    }
    
    
}
