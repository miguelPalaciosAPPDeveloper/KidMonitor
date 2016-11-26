//
//  AdminCoreData.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 03/12/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AdminCoreData:NSObject {
    fileprivate let mDataBase = "Dispositivos"
    fileprivate let mLlaveNombre = "nombre"
    fileprivate let mLlaveUUID = "uuid"
    fileprivate var mVerificacion = false
    
    fileprivate var mDatosDeConsulta:Array<AnyObject> = []
    func getTamaño() ->Int{return mDatosDeConsulta.count}
    
    override init() {
        super.init()
        consultarDataBase()
    }
    
    func consultarDataBase(){
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext:NSManagedObjectContext = appDelegate.managedObjectContext
        let frequest = NSFetchRequest<NSFetchRequestResult>(entityName: mDataBase)
        
        do{
            mDatosDeConsulta = try managedObjectContext.fetch(frequest)
        }catch let error as NSError{
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    func consultarNombre(_ indice:Int) ->String{
        let dato:NSManagedObject = mDatosDeConsulta[indice] as! NSManagedObject
        let nombreConsulta = dato.value(forKey: mLlaveNombre) as! String
        
        return nombreConsulta
    }
    
    func consultarUUID(_ indice:Int) ->String{
        let dato:NSManagedObject = mDatosDeConsulta[indice] as! NSManagedObject
        let uuidConsulta = dato.value(forKey: mLlaveUUID) as! String
        
        return uuidConsulta
    }
    
    func consultarNombrePorUUID(_ uuid:String) ->String{
        var nombreEncontrado = ""
        for item in mDatosDeConsulta{
            let consulta = item as! NSManagedObject
            if let consultaUUID:String = consulta.value(forKey: mLlaveUUID) as? String{
                if consultaUUID == uuid{
                    if let consultaNombre:String = consulta.value(forKey: mLlaveNombre) as? String{
                        nombreEncontrado = consultaNombre
                        break
                    }
                }
            }
        }
        
        return nombreEncontrado
    }
    
    func verificarDispositivo(_ uuid:String) ->Bool{
        for item in mDatosDeConsulta{
            let consulta = item as! NSManagedObject
            if let consultaUUID:String = consulta.value(forKey: mLlaveUUID) as? String{
                if consultaUUID == uuid{
                    mVerificacion = true
                    break
                }else{mVerificacion = false}
            }
        }
        return mVerificacion
    }
    
    func crearNuevoDispositivo(_ clave:String, nombre:String, uuid:String) ->Bool{
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext:NSManagedObjectContext = appDelegate.managedObjectContext
        
        let nuevoDispositivo:Dispositivos = NSEntityDescription.insertNewObject(forEntityName: mDataBase, into: managedObjectContext) as! Dispositivos
        nuevoDispositivo.clave = clave
        nuevoDispositivo.nombre = nombre
        nuevoDispositivo.uuid = uuid
        
        do{
            try managedObjectContext.save()
            print("Dispositivo guardado")
            return true
        }catch let error as NSError{
            print("Fetch failed: \(error.localizedDescription)")
            return false
        }

    }
    
    func cambiarNombreDispositivo(_ nombre:String, indice:Int) ->Bool{
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext:NSManagedObjectContext = appDelegate.managedObjectContext
        let dispositivoExistente:NSManagedObject = mDatosDeConsulta[indice] as! NSManagedObject
        
        dispositivoExistente.setValue(nombre, forKeyPath: mLlaveNombre)
        
        do{
            try managedObjectContext.save()
            print("Nombre cambiado")
            return true
        }catch let error as NSError{
            print("Fetch failed: \(error.localizedDescription)")
            return false
        }

    }
    
    func borrarDispositivo(_ indice:Int) ->Bool{
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext:NSManagedObjectContext = appDelegate.managedObjectContext
        let dispositivoExistente:NSManagedObject = mDatosDeConsulta[indice] as! NSManagedObject
        
        managedObjectContext.delete(dispositivoExistente)
        if managedObjectContext.deletedObjects.contains(dispositivoExistente){
            print("borrado")
        }else{
            print("no se borro")
        }
        do{
            try managedObjectContext.save()
            return true
        }catch let error as NSError{
            print("Fetch failed: \(error.localizedDescription)")
            return false
        }
    }
}
