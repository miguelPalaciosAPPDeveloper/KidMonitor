//
//  ViewDeviceSaved.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 03/12/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewDeviceSaved: UITableViewController, CBCentralManagerDelegate  {
    var mAdminCoreData:AdminCoreData?
    var mUUID = ""
    var mNombreDispositivo = ""
    let nombre = 0
    let uuid = 1
    let mViewDeviceControl = "ViewDeviceControlD"
    var mCentralManager:CBCentralManager?
    var iniciarTimer:Thread?
    var mDialogIndicatorView:UIAlertView?

    override func viewDidLoad() {
        obtenerDatos(false)
    }
    
    func obtenerDatos(_ dialog:Bool){
        let mGuardados = ClaseNSUserDefault().getGuardados()
        if dialog{
            if mGuardados > 0{
                mAdminCoreData = AdminCoreData()
                self.tableView.reloadData()
            }else{
                navigationController?.popToRootViewController(animated: true)
            }
        }else{
            if mGuardados > 0{
                mAdminCoreData = AdminCoreData()
            }else{
                navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func conectarDispositivo(_ uuid:String, nombreDispositivo:String){
        mCentralManager = CBCentralManager(delegate: self, queue: nil)
        mUUID = uuid
        mNombreDispositivo = nombreDispositivo
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let device:CBPeripheral = peripheral{
            //let arrayUUID = String(describing: device.identifier).components(separatedBy: ">")
            let deviceUUID = String(describing: device.identifier)
            if deviceUUID == mUUID{
                iniciarTimer!.cancel()
                if iniciarTimer!.isCancelled{
                    mDialogIndicatorView!.dismiss(withClickedButtonIndex: 0, animated: true)
                }
                let datos = [mNombreDispositivo, mUUID]
                self.performSegue(withIdentifier: mViewDeviceControl, sender: datos)
                central.stopScan()
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state.rawValue == 5{
            central.scanForPeripherals(withServices: nil, options: nil)
            let titulo = "Conectando dispositivo. . . ."
            mDialogIndicatorView = DialogIndicatorView(viewController: self).crearDialog(titulo)
            mDialogIndicatorView!.show()
            iniciarTimer = Thread(target: self, selector: #selector(ViewDeviceSaved.timer), object: nil)
            iniciarTimer!.start()
        }
    }
    
    func timer(){
        Thread.sleep(forTimeInterval: 4)
        DispatchQueue.main.async(execute: {
            self.mCentralManager!.stopScan()
            self.mDialogIndicatorView!.dismiss(withClickedButtonIndex: 0, animated: true)
            self.view.makeToast("Dispositivo fuera del alcance", duration: 2, position: ToastPosition.center)
        })
        iniciarTimer!.cancel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mAdminCoreData!.getTamaño()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let nombre = mAdminCoreData!.consultarNombre(indexPath.row)
        cell.textLabel?.text = nombre
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nombre = mAdminCoreData!.consultarNombre(indexPath.row)
        DialogOpcionesDispositivo(indice: indexPath.row).crearDialog(nombre, viewController: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let datos = sender as! [String]
        
        let conectarDispositivo:ViewDeviceControl = segue.destination as! ViewDeviceControl
        conectarDispositivo.mNombreDispositivo = datos[nombre]
        conectarDispositivo.mUUID = datos[uuid]
    }
}
