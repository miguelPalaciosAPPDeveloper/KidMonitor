//
//  DialogOpcionesDispositivo.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 04/12/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class DialogOpcionesDispositivo:NSObject {
    fileprivate let RESTA = -1
    fileprivate var mIndice = 0
    
    init(indice:Int){
        super.init()
        mIndice = indice
    }
    
    func crearDialog(_ nombreDispositivo:String, viewController:ViewDeviceSaved)
    {
        let opcionesAlert = UIAlertController(title: nombreDispositivo, message: "Seleccione una opción", preferredStyle: .alert)
        let conectar = UIAlertAction(title: "Conectar con dispositivo", style: .default) { (action: UIAlertAction!) -> Void in
            self.conectarDialog(nombreDispositivo, viewController: viewController)
        }
        let editarNombre = UIAlertAction(title: "Editar nombre", style: .default) { (action: UIAlertAction!) -> Void in
            self.editarNombreDialog(viewController)
        }
        let borrarDispositivo = UIAlertAction(title: "Borrar dispositivo", style: .destructive) { (action:UIAlertAction!) -> Void in
            self.borrarDialog(viewController)
        }
        let cancelar = UIAlertAction(title: "Cerrar", style: .cancel) { (action:UIAlertAction!) -> Void in
            opcionesAlert.dismiss(animated: true, completion: nil)
        }
        opcionesAlert.addAction(conectar)
        opcionesAlert.addAction(editarNombre)
        opcionesAlert.addAction(borrarDispositivo)
        opcionesAlert.addAction(cancelar)
        
        DispatchQueue.main.async(execute: {viewController.present(opcionesAlert, animated: true, completion: nil)})
        
    }
    func conectarDialog(_ nombreDispositivo:String, viewController:ViewDeviceSaved){
        let conectarAlert = UIAlertController(title: "¿Desea conectarse con este dispositivo?", message: "", preferredStyle: .alert)
        let conectar = UIAlertAction(title: "Conectar", style: .default) { (action:UIAlertAction!) -> Void in
            let mUUID = AdminCoreData().consultarUUID(self.mIndice)
            DispatchQueue.main.async(execute: {viewController.conectarDispositivo(mUUID, nombreDispositivo: nombreDispositivo)})
            conectarAlert.dismiss(animated: true, completion: nil)
        }
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel) { (action:UIAlertAction!) -> Void in
            conectarAlert.dismiss(animated: true, completion: nil)
        }
        conectarAlert.addAction(conectar)
        conectarAlert.addAction(cancelar)
        
        DispatchQueue.main.async(execute: {viewController.present(conectarAlert, animated: true, completion: nil)})
    }
    
    func editarNombreDialog(_ viewController:ViewDeviceSaved){
        var textFieldNombre:UITextField?
        
        let editarNombreAlert = UIAlertController(title: "Escriba el nuevo nombre:", message: "", preferredStyle: .alert)
        let aceptar = UIAlertAction(title: "Aceptar", style: .default) { (action:UIAlertAction!) -> Void in
            if let texto = textFieldNombre!.text{
                if !texto.isEmpty{
                    if AdminCoreData().cambiarNombreDispositivo(texto, indice: self.mIndice){
                        DispatchQueue.main.async(execute: {
                            viewController.view.makeToast("Nombre cambiado", duration: 2, position: ToastPosition.center)
                            viewController.obtenerDatos(true)
                        })
                    }else{
                        viewController.view.makeToast("No se pudo cambiar el nombre", duration: 2, position: ToastPosition.center)
                    }
                }
            }
            editarNombreAlert.dismiss(animated: true, completion: nil)
        }
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel) { (action:UIAlertAction!) -> Void in
            editarNombreAlert.dismiss(animated: true, completion: nil)
        }
        editarNombreAlert.addAction(aceptar)
        editarNombreAlert.addAction(cancelar)
        editarNombreAlert.addTextField { (TextField) -> Void in
            TextField.placeholder = "Nombre"
            textFieldNombre = TextField
        }
        
        DispatchQueue.main.async(execute: {viewController.present(editarNombreAlert, animated: true, completion: nil)})
    }
    
    func borrarDialog(_ viewController:ViewDeviceSaved){
        let borrarAlert = UIAlertController(title: "¿Desea borrar este dispositivo?", message: "", preferredStyle: .alert)
        let aceptar = UIAlertAction(title: "Aceptar", style: .default) { (action:UIAlertAction!) -> Void in
            if AdminCoreData().borrarDispositivo(self.mIndice){
                ClaseNSUserDefault().guardarUserDefault(self.RESTA)
                DispatchQueue.main.async(execute: {viewController.obtenerDatos(true)})
            }
            borrarAlert.dismiss(animated: true, completion: nil)
        }
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel) { (action:UIAlertAction!) -> Void in
            borrarAlert.dismiss(animated: true, completion: nil)
        }
        borrarAlert.addAction(aceptar)
        borrarAlert.addAction(cancelar)
        
        DispatchQueue.main.async(execute: {viewController.present(borrarAlert, animated: true, completion: nil)})
    }
}
