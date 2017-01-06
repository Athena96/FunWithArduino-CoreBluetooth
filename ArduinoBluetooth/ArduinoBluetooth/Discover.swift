//
//  Discover.swift
//  ArduinoBluetooth
//
//  Created by Jared Franzone on 1/6/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothDiscovery: NSObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager?
    private var arduinoPeripheral: CBPeripheral?
    
    var btService: BluetoothConnect? {
        didSet {
            if let service = self.btService {
                service.discoverServices()
            }
        }
    }
    
    override init() {
        super.init()
        
        let queue = DispatchQueue(label: "com.<YOURNAMEHERE>.ArduinoBluetooth", attributes: [])
        centralManager = CBCentralManager(delegate: self, queue: queue)
    }

    // MARK: - CBCentralManagerDelegate
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // make sure peripheral is valid
        if (peripheral.name == nil || peripheral.name == "") {
            return
        }
        
        // if not already connected... then connect
        if self.arduinoPeripheral == nil || self.arduinoPeripheral?.state == .disconnected {
            self.arduinoPeripheral = peripheral
            self.btService = nil
            central.connect(peripheral, options: nil)
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // if connected peripheral is the peripheral we just discovered
        if (peripheral == self.arduinoPeripheral) {
            self.btService = BluetoothConnect(withPeripheral: peripheral)
        }
        central.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // if it was our peripherial that disconnected, then reset variables
        if (peripheral == self.arduinoPeripheral) {
            resetDevices()
        }
        // start scanning again
        self.discoverDevices()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
            
        case .poweredOff:
            self.resetDevices()
            
        case .unauthorized:
            break
            
        case .unknown:
            break
            
        case .poweredOn:
            self.discoverDevices()
            
        case .resetting:
            self.resetDevices()
            
        case .unsupported:
            break
            
        }
    }
    
    // MARK: - Private
    private func discoverDevices() {
        if let central = centralManager {
            central.scanForPeripherals(withServices: [BTServicesUUID], options: nil)
        }
    }
    
    private  func resetDevices() {
        self.btService = nil
        self.arduinoPeripheral = nil
    }
    
}
