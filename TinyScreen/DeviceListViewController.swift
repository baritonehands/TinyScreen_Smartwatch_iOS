//
//  DeviceListViewController.swift
//  TinyScreen
//
//  Created by Brian Gregg on 5/1/15.
//  Copyright (c) 2015 Brian Gregg. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceListViewController: UITableViewController, CBCentralManagerDelegate {

    static let uartServiceUUID = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    
    var detailViewController: DeviceViewController? = nil
    var devices = [CBPeripheral]()
    lazy var centralManager: CBCentralManager = CBCentralManager(delegate: self, queue: nil)
    var scanEnabled = false

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(title: "Scan", style: .Done, target: self, action: "startScan:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DeviceViewController
        }
        self.navigationItem.rightBarButtonItem?.enabled = centralManager.state == .PoweredOn
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startScan(sender: AnyObject) {
        centralManager.scanForPeripheralsWithServices([DeviceListViewController.uartServiceUUID], options: nil)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let device = devices[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DeviceViewController
                controller.detailItem = device
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                device.delegate = controller
                centralManager.stopScan()
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let device = devices[indexPath.row]
        cell.textLabel!.text = device.name ?? "Unknown"
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        centralManager.stopScan()
        
        var device = devices[indexPath.row]
        centralManager.connectPeripheral(device, options: nil)
    }
    
    // MARK: - Central Manager

    func centralManagerDidUpdateState(central: CBCentralManager!) {
        self.navigationItem.rightBarButtonItem?.enabled = central.state == .PoweredOn
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        devices.append(peripheral)
        tableView.reloadData()
        //println("\(advertisementData)")
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        performSegueWithIdentifier("showDetail", sender: self)
    }
}

