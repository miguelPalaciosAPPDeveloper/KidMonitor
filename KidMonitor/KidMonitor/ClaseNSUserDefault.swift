//
//  ClaseNSUserDefault.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 02/12/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//

import Foundation
class ClaseNSUserDefault:NSObject {
    fileprivate let mLlave = "datoGuardado"
    fileprivate let mClave = 4
    fileprivate let mUUID = 1
    fileprivate var mObjetoNsDefault = UserDefaults.standard
    fileprivate var mGuardados:Int = 0
    
    func getGuardados() -> Int{
        if mGuardados != 0{
            return mGuardados
        }else{return 0}
    }
    
    override init(){
        super.init()
        mGuardados = mObjetoNsDefault.integer(forKey: mLlave)
    }
    
    func obtenerClave(_ identificador:String) ->String{
        let separador = CharacterSet(charactersIn: ">,-")
        let clave = identificador.components(separatedBy: separador)
        
        return clave[self.mClave]
    }
    
    func obtenerUUID(_ identificador:String) ->String{
        let UUID = identificador.components(separatedBy: ">")
        
        return UUID[mUUID]
    }
    
    func guardarUserDefault(_ operacion:Int){
        mGuardados = mGuardados + operacion
        mObjetoNsDefault.set(mGuardados, forKey: mLlave)
        print("guardado: \(mGuardados)")
    }
}
