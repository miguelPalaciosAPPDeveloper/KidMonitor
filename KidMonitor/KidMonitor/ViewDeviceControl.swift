//
//  ViewDeviceControl.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 25/11/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewDeviceControl: UIViewController
{
    
    @IBOutlet weak var labelDispositivo: UILabel!
    @IBOutlet weak var labelEstado: UILabel!
    @IBOutlet weak var buttonConexion: UIButton!
    @IBOutlet weak var buttonMonitoreo: UIButton!
    @IBOutlet weak var switchLarga: UISwitch!
    @IBOutlet weak var switchCorta: UISwitch!
    
    let OCHO_METROS = 8
    let DOCE_METROS = 12
    let mViewDeviceControl = "ViewDeviceControl"
    var mBluetoothManager:BluetoothLeManager?
    var mChecked:Bool = false
    var mNombreDispositivo:String = ""
    var mUUID:String = ""
    var mLimite:Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        botonesPersonalizados()
        labelDispositivo.text = mNombreDispositivo
        mBluetoothManager = BluetoothLeManager(tag: mViewDeviceControl)
        mBluetoothManager!.iniciarCentralManager()
        mBluetoothManager!.setControlConexion(mUUID, deviceControl: self)
        //let notificationCenter = NSNotificationCenter.defaultCenter()
        //notificationCenter.addObserver(mBluetoothManager!, selector: "background", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        //notificationCenter.addObserver(mBluetoothManager!, selector: "foreground", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if mBluetoothManager!.getConectado(){
            mBluetoothManager!.desconectarDispositivo()
        }
    }
    
    func botonesPersonalizados()
    {
        let cornerR = CGFloat(10.0)
        let borderW = CGFloat(1.0)
        let borderColor = UIColor.lightGray.cgColor
        
        buttonConexion.layer.borderColor = borderColor
        buttonConexion.layer.borderWidth = borderW
        buttonConexion.layer.cornerRadius = cornerR
        
        buttonMonitoreo.layer.borderColor = borderColor
        buttonMonitoreo.layer.borderWidth = borderW
        buttonMonitoreo.layer.cornerRadius = cornerR
    }
    
    @IBAction func iniciarMonitoreoClic(_ sender: UIButton) {
        if switchLarga.isOn || switchCorta.isOn {
            if mBluetoothManager!.getConectado(){
                if !mChecked{
                    mBluetoothManager!.setEstado(true)
                    mChecked = true
                    buttonMonitoreo.setTitle("DETENER MONITOREO", for: UIControlState())
                    mBluetoothManager!.monitoreo(mChecked)
                    self.view.makeToast("RSSI Iniciado")
                }else{
                    mBluetoothManager!.setEstado(false)
                    mChecked = false
                    buttonMonitoreo.setTitle("INICIAR MONITOREO", for: UIControlState())
                }
            }else
            {
                self.view.makeToast("No hay conexión")
            }
        }else
        {
            self.view.makeToast("Elija una distancia")
        }

    }
    
    @IBAction func switchLargaDistancia(_ sender: UISwitch) {
        if switchLarga.isOn{
            switchCorta.isEnabled = true
            switchLarga.isEnabled = false
            switchCorta.setOn(false, animated: false)
            mBluetoothManager!.setLimite(DOCE_METROS)
        }
    }
    
    @IBAction func switchCortaDistancia(_ sender: UISwitch) {
        if switchCorta.isOn{
            switchCorta.isEnabled = false
            switchLarga.isEnabled = true
            switchLarga.setOn(false, animated: false)
            mBluetoothManager!.setLimite(OCHO_METROS)
        }
    }
    
    @IBAction func conexionClic(_ sender: UIButton) {
        if mBluetoothManager!.getConectado(){
            mBluetoothManager!.setEstado(false)
            mBluetoothManager!.desconectarDispositivo()
        }else{
            mBluetoothManager!.conectarDispositivo()
        }
    }
}
