//
//  ViewPrincipal.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 23/11/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewPrincipal: UIViewController
{
    @IBOutlet weak var buttonBuscar: UIButton!
    @IBOutlet weak var buttonGuardado: UIButton!
    
    var bluetoothManager:BluetoothLeManager?
    
    let mViewPrincipal = "ViewPrincipal"
    let mViewDeviceScan = "ViewDeviceScan"
    let mViewDeviceSaved = "ViewDeviceSaved"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        botonesPersonalizados()
    }
    override func viewDidAppear(_ animated: Bool) {
        bluetoothManager = BluetoothLeManager(tag:mViewPrincipal)
    }
    
    func botonesPersonalizados()
    {
        let cornerR = CGFloat(20.0)
        let borderW = CGFloat(4.0)
        let borderColor = UIColor.lightGray.cgColor
        
        buttonBuscar.layer.borderColor = borderColor
        buttonBuscar.layer.borderWidth = borderW
        buttonBuscar.layer.cornerRadius = cornerR
        
        buttonGuardado.layer.borderColor = borderColor
        buttonGuardado.layer.borderWidth = borderW
        buttonGuardado.layer.cornerRadius = cornerR
    }

    @IBAction func buscarNuevosClic(_ sender: UIButton) {
        //if estadoBluetooth {
        if bluetoothManager!.getEstadoBluetooth() {
            self.performSegue(withIdentifier: mViewDeviceScan, sender: self)
        }else{
            bluetoothManager!.iniciarCentralManager()
        }
    }
    
    @IBAction func seleccionarGuardadoClic(_ sender: UIButton) {
        let mGuardados = ClaseNSUserDefault().getGuardados()
        if mGuardados > 0{
            if bluetoothManager!.getEstadoBluetooth() {
                self.performSegue(withIdentifier: mViewDeviceSaved, sender: self)
            }else{
                bluetoothManager!.iniciarCentralManager()
            }
        }else{
            self.view.makeToast("No hay dispositivos guardados")
        }
    }
    
}
