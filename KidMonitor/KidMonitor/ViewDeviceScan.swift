//
//  ViewDeviceScan.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 23/11/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewDeviceScan: UITableViewController, CBCentralManagerDelegate
{
    var mCentralManager:CBCentralManager?
    var mDiccionarioDispositivos:Dictionary<String, CBPeripheral> = [:]
    var mArrayDispositivos = [CBPeripheral]()
    var mDialogIndicatorView:UIAlertView?
    var iniciarTimer:Thread?
    let mViewDeviceControl = "ViewDeviceControl"
    let nombre = 0
    let uuid = 1

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mDiccionarioDispositivos.removeAll(keepingCapacity: false);
        mArrayDispositivos.removeAll(keepingCapacity: false)
        mCentralManager = CBCentralManager(delegate: self, queue: nil)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewDeviceScan.actualizar), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
        
    }
    
    func actualizar() {
        mDiccionarioDispositivos.removeAll(keepingCapacity: false);
        mArrayDispositivos.removeAll(keepingCapacity: false)
        self.tableView.reloadData()
        mCentralManager = CBCentralManager(delegate: self, queue: nil)
        self.refreshControl?.endRefreshing()
    }
    
    func timer(){
        Thread.sleep(forTimeInterval: 10)
        DispatchQueue.main.async(execute: {
            self.mCentralManager!.stopScan()
            self.mDialogIndicatorView!.dismiss(withClickedButtonIndex: 0, animated: true)
        })
        iniciarTimer!.cancel()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name { //toma del dispositivo su UUID
            if mDiccionarioDispositivos[name] == nil{
                mDiccionarioDispositivos[name] = peripheral
                mArrayDispositivos.append(peripheral)
                self.tableView.reloadData()
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if let central:CBCentralManager = central {
            if central.state.rawValue == 5 {
                central.scanForPeripherals(withServices: nil, options: nil)
                let titulo = "Buscando dispositivos. . . ."
                mDialogIndicatorView = DialogIndicatorView(viewController: self).crearDialog(titulo)
                mDialogIndicatorView!.show()
                iniciarTimer = Thread(target: self, selector: #selector(ViewDeviceScan.timer), object: nil)
                iniciarTimer!.start()
                print("Buscando dispositivos")
            }else{
                print("Bluetooth apagado o no inicializado")
            }
            /*if central.state == CBCentralManagerState.poweredOn {
                central.scanForPeripherals(withServices: nil, options: nil)
                let titulo = "Buscando dispositivos. . . ."
                mDialogIndicatorView = DialogIndicatorView(viewController: self).crearDialog(titulo)
                mDialogIndicatorView!.show()
                iniciarTimer = Thread(target: self, selector: #selector(ViewDeviceScan.timer), object: nil)
                iniciarTimer!.start()
                print("Buscando dispositivos")
            }else{
                print("Bluetooth apagado o no inicializado")
            }*/
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return mArrayDispositivos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = mArrayDispositivos[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identificador = String(describing: self.mArrayDispositivos[indexPath.row].identifier)
        let nombreDispositivo = self.mArrayDispositivos[indexPath.row].name

        print("indetificador: \(identificador)")
        DialogConectarGuardar(identificador: identificador).crearDialog(nombreDispositivo!, viewController: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let datos = sender as! [String]
        mCentralManager!.stopScan()
        self.refreshControl?.endRefreshing()
        self.refreshControl = nil
        let conectarDispositivo:ViewDeviceControl = segue.destination as! ViewDeviceControl
        conectarDispositivo.mNombreDispositivo = datos[nombre]
        conectarDispositivo.mUUID = datos[uuid]
    }

}
