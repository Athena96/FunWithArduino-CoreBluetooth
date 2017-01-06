//
//  ArduinoServo.swift
//  ArduinoBluetooth
//
//  Created by Jared Franzone on 1/6/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import Foundation

class ArduinoServo {
    private var discovery: BluetoothDiscovery
    private var lastSpeed: UInt8 = 255
    
    init() {
        discovery = BluetoothDiscovery()
    }
    
    var speed: UInt8 = 0 {
        didSet {
            if speed == lastSpeed || (speed < 90 || speed > 180) {
                speed = 90
                return
            }
            // Send speed to BLE Shield (if service exists and is connected)
            if let btService = discovery.btService {
                btService.writeSpeed(speed)
                self.lastSpeed = speed
            }
        }
    }
    
}
