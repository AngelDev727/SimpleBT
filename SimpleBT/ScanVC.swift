//
//  ScanVC.swift
//  SimpleBT
//
//  Created by LiMing on 12/13/19.
//  Copyright © 2019 Jimmy. All rights reserved.
//

import UIKit
import CoreBluetooth

var blePeripheral : CBPeripheral?

class ScanVC: UIViewController, UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    @IBOutlet weak var tbvDeviceList: UITableView!
    
    var peripheral : CBPeripheral!
    var centralManager : CBCentralManager!
    var timer = Timer()
    var devices : [String] = []
    var RSSIs : [NSNumber] = []
    var UUID : [String] = []
    var peripheralList : [CBPeripheral] = []
    var sel = -1
    //let cellReuseIdentifier = "DeviceCell"
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
//        self.tbvDeviceList.register(DeviceCell.self, forCellReuseIdentifier: cellReuseIdentifier)
//        self.tbvDeviceList.delegate = self
//        self.tbvDeviceList.dataSource = self
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        disconnectFromDevice()
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Stop Scanning")
        centralManager?.stopScan()
    }
       
    func startScan()  {
        peripheralList = []
        print("New Scanning....")
        self.timer.invalidate()
        centralManager?.scanForPeripherals(withServices: nil, options:[CBCentralManagerScanOptionAllowDuplicatesKey:false])
        Timer.scheduledTimer(timeInterval: 17, target: self, selector: #selector(self.cancelScan), userInfo: nil, repeats: false)
    }
    
    @objc func cancelScan(){
        self.centralManager?.stopScan()
        print("Scan Stopped")
        print("Number of Peripherals Found : \(peripheralList.count)")
    }
    
    func disconnectFromDevice() {
        if blePeripheral != nil {
            centralManager?.cancelPeripheralConnection(blePeripheral!)
        }
    }
    
    func restoreCentralManager() {
        centralManager?.delegate = self
    }
    
    // Find bluetooth devices
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if (peripheral.name != nil) {
            blePeripheral = peripheral
            self.peripheralList.append(peripheral)
            self.devices.append(peripheral.name!)
            self.RSSIs.append(RSSI)
            peripheral.delegate = self
            self.tbvDeviceList.reloadData()
            sel = peripheralList.count-1
            if blePeripheral == nil {
                print("Found new peripheral devices with services")
                print("Peripheral name: \(String (describing: peripheral.name))")
                print("**********************************")
                print("Advertisement Data : \(advertisementData)")
            }
        }
    }

    func connectToDevice() {
        centralManager?.connect(blePeripheral!, options: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            print("Bluetooth Enabled")
            startScan()
        }else{
            print("Bluetooth not available.")
            let alertVC = UIAlertController(title: "Bluetooth is not enabled", message: "Make sure that your bluetooth is turned on", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceCell
    
        
        print("test10: ", self.RSSIs[indexPath.row].stringValue)
        print("test1: ", self.devices[indexPath.row])
        cell.lblDeviceName.text = self.devices[indexPath.row]
//        cell.lblRssi.text = self.RSSIs[indexPath.row].stringValue
        return cell
    }
}


