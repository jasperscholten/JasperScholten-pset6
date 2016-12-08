//
//  monumentInfo.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 06-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//

import Foundation
import MapKit

class MonumentInfo: NSObject, MKAnnotation {
    let objectName: String
    let objectLocation: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(objectName: String, objectLocation: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.objectName = objectName
        self.objectLocation = objectLocation
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var title: String? {
        return objectName
    }
    
    var subtitle: String? {
        return objectLocation
    }
}

/*abc_adres
  abc_objectnaam
  abc_lat
  abc_lon*/
