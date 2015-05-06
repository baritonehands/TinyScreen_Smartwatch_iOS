//
//  DeviceViewController.swift
//  TinyScreen
//
//  Created by Brian Gregg on 5/1/15.
//  Copyright (c) 2015 Brian Gregg. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceViewController: UIViewController, CBPeripheralDelegate {
    
    static let txCharUUID = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
    static let rxCharUUID = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    weak var txChar: CBCharacteristic?
    weak var rxChar: CBCharacteristic?

    var detailItem: CBPeripheral? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: CBPeripheral = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        detailItem?.discoverServices(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Peripheral Delegate
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        for service in peripheral.services as! [CBService] {
            peripheral.discoverCharacteristics([DeviceViewController.txCharUUID, DeviceViewController.rxCharUUID], forService: service)
            println("\(service)")
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        for char in service.characteristics as! [CBCharacteristic] {
            if char.UUID == DeviceViewController.txCharUUID {
                txChar = char
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "'D'yyyy MM dd HH mm ss"
                var msg = dateFormatter.stringFromDate(NSDate())
                
                peripheral.writeValue(msg.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false), forCharacteristic: char, type: .WithoutResponse)
            }
            else if char.UUID == DeviceViewController.rxCharUUID {
                rxChar = char
                
                peripheral.setNotifyValue(true, forCharacteristic: char)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if let data = characteristic.value {
            println("\(data)")
        }
    }
}

