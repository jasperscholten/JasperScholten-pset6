//
//  monumentInfo.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 06-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import Contacts

class MonumentInfo: NSObject, MKAnnotation {
    let objectName: String
    let objectLocation: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let addedByUser: String
    let key: String
    let ref: FIRDatabaseReference?
    
    init(objectName: String, objectLocation: String, discipline: String, coordinate: CLLocationCoordinate2D, addedByUser: String, key: String = "") {
        self.objectName = objectName
        self.objectLocation = objectLocation
        self.discipline = discipline
        self.coordinate = coordinate
        self.addedByUser = addedByUser
        self.key = key
        self.ref = nil
        
        super.init()
    }
    
    var title: String? {
        return objectName
    }
    
    var subtitle: String? {
        return objectLocation
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.objectName = snapshotValue["objectName"] as! String
        self.objectLocation = snapshotValue["objectLocation"] as! String
        self.discipline = snapshotValue["coordinate"] as! String
        self.addedByUser = snapshotValue["addedByUser"] as? String ?? ""
        self.ref = snapshot.ref
        self.coordinate = CLLocationCoordinate2DMake(0.00, 0.00)
    }
    
    func toAnyObject() -> Any {
        return [
            "objectName": objectName,
            "objectLocation": objectLocation,
            "coordinate": discipline,
            "addedByUser": addedByUser
        ]
    }
    
    // annotation callout info button opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): title]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
}
