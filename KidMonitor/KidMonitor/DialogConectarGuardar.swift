//
//  DialogConectarGuardar.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 01/12/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//

import Foundation
import UIKit

class DialogConectarGuardar:NSObject {
    fileprivate let mClaveIncorrecta = "Clave incorreta"
    fileprivate let SUMA = 1
    fileprivate var mClave = ""
    fileprivate var mUUID = ""
    fileprivate var adminCoreData:AdminCoreData?
    
    init(identificador:String){
        super.init()
        //mUUID = ClaseNSUserDefault().obtenerUUID(identificador)
        mUUID = identificador
        mClave = ClaseNSUserDefault().obtenerClave(identificador)

        print("Clave: \(mClave)")
        adminCoreData = AdminCoreData()
    }
    
    func crearDialog(_ nombreDispositivo:String, viewController:UIViewController)
    {
        var textFieldClave:UITextField?
        let mViewDeviceControl = "ViewDeviceControlB"
        
        let verificacionAlert = UIAlertController(title: "Para continuar ingresa la clave del dispositivo seleccionado", message: "", preferredStyle: .alert)
        
        let conectarGuardar = UIAlertAction(title: "Conectar/Guardar", style: .default) { (action: UIAlertAction!) -> Void in

            if let texto = textFieldClave!.text {
                if !texto.isEmpty {
                    if texto == self.mClave {
                        if self.adminCoreData!.verificarDispositivo(self.mUUID){
                            viewController.view.makeToast("El dispositivo ya existe, busque en dispositivos guardados", duration: 3, position: ToastPosition.center)
                        }else{
                            if self.adminCoreData!.crearNuevoDispositivo(self.mClave, nombre: nombreDispositivo, uuid: self.mUUID){
                                ClaseNSUserDefault().guardarUserDefault(self.SUMA)
                                let datos = [nombreDispositivo, self.mUUID]
                                DispatchQueue.main.async(execute: {viewController.performSegue(withIdentifier: mViewDeviceControl, sender:datos)})
                                verificacionAlert.dismiss(animated: true, completion: nil)
                            }else{
                                 viewController.view.makeToast("No se pudo guardar el dispositivo", duration: 2, position: ToastPosition.center)
                            }
                        }
                    }else {
                        viewController.view.makeToast(self.mClaveIncorrecta, duration: 2, position: ToastPosition.center)
                    }
                }else {
                    viewController.view.makeToast(self.mClaveIncorrecta, duration: 2, position: ToastPosition.center)
                }
                verificacionAlert.dismiss(animated: true, completion: nil)
            }
        }
        
        let conectar = UIAlertAction(title: "Conectar", style: .default) { (action: UIAlertAction!) -> Void in
             var datos = [String]()
            if let texto = textFieldClave!.text {
                if !texto.isEmpty {
                    if texto == self.mClave {
                        if self.adminCoreData!.verificarDispositivo(self.mUUID){
                            let nombreEncontrado = self.adminCoreData!.consultarNombrePorUUID(self.mUUID)
                            datos = [nombreEncontrado, self.mUUID]
                        }else{
                            datos = [nombreDispositivo, self.mUUID]
                        }
                        DispatchQueue.main.async(execute: {viewController.performSegue(withIdentifier: mViewDeviceControl, sender:datos)})
                        verificacionAlert.dismiss(animated: true, completion: nil)
                    }else {
                        viewController.view.makeToast(self.mClaveIncorrecta, duration: 2, position: ToastPosition.center)
                    }
                }else {
                    viewController.view.makeToast(self.mClaveIncorrecta, duration: 2, position: ToastPosition.center)
                }
                verificacionAlert.dismiss(animated: true, completion: nil)
            }
        }
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel) { (action:UIAlertAction!) -> Void in
            verificacionAlert.dismiss(animated: true, completion: nil)
        }
        
        verificacionAlert.addAction(conectarGuardar)
        verificacionAlert.addAction(conectar)
        verificacionAlert.addAction(cancelar)
        verificacionAlert.addTextField { (TextField) -> Void in
            TextField.placeholder = "Clave"
            TextField.isSecureTextEntry = true
            textFieldClave = TextField
        }
        DispatchQueue.main.async(execute: {viewController.present(verificacionAlert, animated: true, completion: nil)})
    }

}
