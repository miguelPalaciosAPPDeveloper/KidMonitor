//
//  Dispositivos+CoreDataProperties.swift
//  KidMonitor
//
//  Created by Miguel Palacios on 03/12/15.
//  Copyright © 2015 Miguel Palacios. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Dispositivos {

    @NSManaged var clave: String?
    @NSManaged var nombre: String?
    @NSManaged var uuid: String?

}
