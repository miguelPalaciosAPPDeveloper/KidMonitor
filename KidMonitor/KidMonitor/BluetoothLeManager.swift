//
//  File.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 27/11/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class  BluetoothLeManager:NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    var devicesServices: CBService!
    var deviceCharacteristics: CBCharacteristic!
    
    fileprivate var TAG = ""
    fileprivate var mCentralManager:CBCentralManager?
    fileprivate var mServiceControl:ServiceControl?
    fileprivate var mDispositivo:CBPeripheral?
    
    fileprivate var mEstado = false
    func getEstado() -> Bool{return mEstado}
    func setEstado(_ estado:Bool){mEstado = estado}
    
    fileprivate var mConectado = false
    func getConectado() -> Bool{return mConectado}
    func setConectado(_ conectado:Bool){mConectado = conectado}
    
    fileprivate var mEstadoBluetooth = false
    func getEstadoBluetooth() -> Bool{return mEstadoBluetooth}
    func setEstadoBluetooth(_ estadoBluetooth:Bool){mEstadoBluetooth = estadoBluetooth}
    
    fileprivate var mDeviceControl:ViewDeviceControl?
    fileprivate var mRSSI = 0
    fileprivate var mUUID = ""
    
    fileprivate let uuid = 1
    fileprivate let mViewPrincipal = "ViewPrincipal"
    fileprivate let mViewDeviceControl = "ViewDeviceControl"
    fileprivate let centralQueue = DispatchQueue(label: "com.KidMonitor", attributes: [])
    
    
    init(tag:String){
        super.init()
        TAG = tag
        mServiceControl = ServiceControl()
    }
    
    func setLimite(_ limite:Int){
        mServiceControl!.setLimite(limite)
    }
    
    func iniciarCentralManager(){
        mCentralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func monitoreo(_ checked:Bool){
        if checked{
            ///quitar comentarios para dispositivo 2
            Thread.detachNewThreadSelector(#selector(BluetoothLeManager.tareaMonitoreo), toTarget: self, with: nil)
            mServiceControl!.setEstado(mEstado)
            mServiceControl!.iniciarMonitoreo()
        }
    }
    
    ///quitar comentarios para dispositivo 2
    func tareaMonitoreo(){
        while(mEstado && mConectado){
            self.mDispositivo!.readRSSI()
            Thread.sleep(forTimeInterval: 2)
        }
        if !mEstado{mServiceControl!.setEstado(mEstado)}
    }
    
    func setControlConexion(_ uuid:String, deviceControl:ViewDeviceControl){
        mDeviceControl = deviceControl
        mUUID = uuid
    }
    
    func conectarDispositivo(){
        if let centralManager = mCentralManager{
            if let dispositivo = mDispositivo{
                centralManager.connect(dispositivo, options: nil)
            }
        }
        
    }
    
    func desconectarDispositivo(){
        if let centralManager = mCentralManager{
            if let dispositivo = mDispositivo{
                centralManager.cancelPeripheralConnection(dispositivo)
            }
        }
    }

    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let device:CBPeripheral = peripheral{
            //let arrayUUID = String(describing: device.identifier).components(separatedBy: ">")
            //let deviceUUID = arrayUUID[uuid]
            let deviceUUID = String(describing: device.identifier)
            if deviceUUID == mUUID{
                mDispositivo = peripheral
                central.connect(mDispositivo!, options: nil)
            }
        }

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        central.stopScan()
        ///////
        if let peripheralDevice:CBPeripheral = peripheral{
            print("discoverServices")
            peripheralDevice.discoverServices(nil)
            mDispositivo!.delegate = self
        }
        /////
        
        
        mConectado = true
        mEstado = false
        mServiceControl!.setEstado(mEstado)
        mServiceControl!.setConectado(mConectado)
        DispatchQueue.main.async(execute: {
            self.mDeviceControl!.labelEstado.text = "Estado: Conectado"
            self.mDeviceControl!.buttonConexion.setTitle("Desconectar", for: UIControlState())})
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        mConectado = false
        mServiceControl!.setConectado(mConectado)
        mServiceControl!.lanzarNotificacionDesconexion()
        DispatchQueue.main.async(execute: {

            self.mDeviceControl!.labelEstado.text = "Estado: Desconectado"
            self.mDeviceControl!.buttonConexion.setTitle("Conectar", for: UIControlState())
            self.mDeviceControl!.mChecked = false
            self.mDeviceControl!.buttonMonitoreo.setTitle("INICIAR MONITOREO", for: UIControlState())})
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        mRSSI = RSSI as Int
        ///quitar comentarios para dispositivo 2
        mServiceControl!.setRSSI(mRSSI)
        
        //mServiceControl!.monitorear(mRSSI)
        print("rssi: \(mRSSI)")
    }
    //////////////
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("entrada")
        if let peripheral:CBPeripheral = peripheral{
            
            if let service:CBService = service{
                // check the uuid of each characteristic to find config and data characteristics
                for charateristic in service.characteristics! {
                    let thisCharacteristic = charateristic as CBCharacteristic
                    // Set notify for characteristics here.
                    peripheral.setNotifyValue(true, for: thisCharacteristic)
                    
                    deviceCharacteristics = thisCharacteristic
                }
                // Now that we are setup, return to main view.
            }
        }
    }
    
    // Get data values when they are updated
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Got some!")
        //mDispositivo!.readRSSI()
    }
    ////////////////////
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("service")
        if let peripheral:CBPeripheral = peripheral{
            // Iterate through the services of a particular peripheral.
            for service in peripheral.services! {
                let thisService = service as CBService
                // Let's see what characteristics this service has.
                if let thisService:CBService = thisService{
                    peripheral.discoverCharacteristics(nil, for: thisService)
                }
            }
        }
        
    }
    
    /////////////
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if TAG == mViewPrincipal{
            if let central:CBCentralManager = central{
                if central.state.rawValue == 5{
                    mEstadoBluetooth = true
                }else{ mEstadoBluetooth = false}
            }
        }else if TAG == mViewDeviceControl{
            if let central:CBCentralManager = central{
                if central.state.rawValue == 5{
                    central.scanForPeripherals(withServices: nil, options: nil)
                }
            }
        }
    }
    
}
