//
//  ClaseControl.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 06/12/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import AVFoundation

class ServiceControl:NSObject {
    fileprivate var mPromedio = 0
    fileprivate var mEstado = false
    fileprivate var mNotificacion = false
    func setEstado(_ estado:Bool){mEstado = estado}
    
    fileprivate var mConectado = false
    func setConectado(_ conectado:Bool){mConectado = conectado}
    
    fileprivate var mRSSI = 0
    func setRSSI(_ rssi:Int){mRSSI = rssi}
    
    fileprivate var mLimite = 0
    func setLimite(_ limite:Int){mLimite = limite}
    
    fileprivate var mAudio = AVAudioPlayer()
    
    func iniciarMonitoreo(){
        let sound =  URL(fileURLWithPath: "/Library/Ringtones/Opening.m4r")
        
        do{
            mAudio = try AVAudioPlayer(contentsOf: sound)
        }catch let error as NSError{
            print("Fetch failed: \(error.localizedDescription)")
        }
        ///quitar comentarios para dispositivo 2
        Thread.detachNewThreadSelector(#selector(ServiceControl.monitoreo), toTarget: self, with: nil)
    }
    
    func monitoreo(){
        while(mEstado && mConectado){
            let mConstante = 1e-8
            Thread.detachNewThreadSelector(#selector(ServiceControl.promedio), toTarget: self, with: nil)
            let mDistancia = sqrt((mConstante)/(pow(10.0, (Double(mPromedio)/10.0))))
            Thread.sleep(forTimeInterval: 0.100)
            print("distancia: \(mDistancia)")
            if Int(mDistancia) > mLimite{
                if !mNotificacion{
                    print("Limite")
                    lanzarNotificacionLimite()
                    mNotificacion = true
                }
                lanzarSonido()
            }else{
                mAudio.stop()
                mNotificacion = false
            }
        }
        print("salida")
    }
    
    func promedio(){
        let mMuestras = 20
        var sumatoria = 0
        for _ in 0 ..< mMuestras {
            sumatoria += mRSSI
            Thread.sleep(forTimeInterval: 0.150)
        }

        mPromedio = sumatoria/mMuestras
    }
    
    func lanzarNotificacionDesconexion(){
        if mEstado && !mConectado{
            lanzarSonido()
            let localNotification = UILocalNotification()
            localNotification.fireDate = Date(timeIntervalSinceNow: 1)
            localNotification.alertBody = "Dispositivo desconectado"
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.timeZone = TimeZone.current
            localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
            
            UIApplication.shared.scheduleLocalNotification(localNotification)
            print("notificacion")
        }else if(!mEstado && mConectado){
            print("desconexion correcta")
        }
    }
    
    func lanzarNotificacionLimite(){
        let localNotification = UILocalNotification()
        localNotification.fireDate = Date(timeIntervalSinceNow: 1)
        localNotification.alertBody = "Dispositivo fuera del limite"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.timeZone = TimeZone.current
        localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        
        UIApplication.shared.scheduleLocalNotification(localNotification)
        print("notificacion")
    }
    
    func lanzarSonido(){
        mAudio.play()
        Thread.detachNewThreadSelector(#selector(ServiceControl.vibracion), toTarget: self, with: nil)
        /*let sound =  NSURL(fileURLWithPath: "/Library/Ringtones/Opening.m4r")
        var soundID:SystemSoundID = 0
        AudioServicesCreateSystemSoundID(sound, &soundID)
        AudioServicesPlaySystemSound(soundID)
        print("sonido")*/
    }
    func vibracion(){
        while(mAudio.isPlaying){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            Thread.sleep(forTimeInterval: 3)
        }
        print("salida vibracion")
    }
    
    /*func monitorear(rssi:Int){
        let mConstante = 1e-7
        let mDistancia = sqrt((mConstante)/(pow(10.0, (Double(rssi)/10.0))))
        print("distancia: \(mDistancia)")
        if Int(mDistancia) > 1{
            if !mNotificacion{
                lanzarNotificacionLimite()
                mNotificacion = true
            }
            
            lanzarSonido()
        }else{
            mNotificacion = false
        }
    }*/
}
