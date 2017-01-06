//
//  ViewController.swift
//  ArduinoBluetooth
//
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedControlSlider: UISlider!
    
    private let arduinoServo = ArduinoServo()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.statusChanged(_:)), name: NSNotification.Name(rawValue: BTServiceChangedNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BTServiceChangedNotification), object: nil)
    }
    
    @IBAction func speedSliderDidChange(_ sender: UISlider) {
        speedLabel.text = sender.value.description
        arduinoServo.speed = UInt8(sender.value)
    }

    func statusChanged(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo as? [String: Bool] {
            DispatchQueue.main.async(execute: {
                // set color of slider based on connection
                if let isConnected: Bool = userInfo["isConnected"] {
                    self.speedControlSlider.minimumTrackTintColor = isConnected ? #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1) : #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                }
            });
        }
    }



}

