//
//  ParkingInfo.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 06-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//
//  Basic structure for a parkinglocation is defined here in ParkingInfo, as well as some functions to deal with this data. A Parkinglocation is a specific parkingmeter in Amsterdam, as retrieved from the ParkShark API.

import Foundation
import MapKit
import Firebase
import Contacts

class ParkingInfo: NSObject, MKAnnotation {
    let objectAddress: String
    let objectLocation: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let addedByUser: String
    let key: String
    let ref: FIRDatabaseReference?
    
    init(objectAddress: String, objectLocation: String, discipline: String, coordinate: CLLocationCoordinate2D, addedByUser: String, key: String = "") {
        self.objectAddress = objectAddress
        self.objectLocation = objectLocation
        self.discipline = discipline
        self.coordinate = coordinate
        self.addedByUser = addedByUser
        self.key = key
        self.ref = nil
        
        super.init()
    }
    
    // Title and subtitle used to show info on annotationview.
    var title: String? {
        return objectAddress
    }
    var subtitle: String? {
        return objectLocation
    }
    
    // MARK: Enable showing data from Firebase in app.
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.objectAddress = snapshotValue["objectAddress"] as! String
        self.objectLocation = snapshotValue["objectLocation"] as! String
        self.discipline = snapshotValue["coordinate"] as! String
        self.addedByUser = snapshotValue["addedByUser"] as? String ?? ""
        self.ref = snapshot.ref
        self.coordinate = CLLocationCoordinate2DMake(0.00, 0.00)
    }
    
    func toAnyObject() -> Any {
        return [
            "objectAddress": objectAddress,
            "objectLocation": objectLocation,
            "coordinate": discipline,
            "addedByUser": addedByUser
        ]
    }
    
    // Function mapItem is used to find the route to a specific parkinglocation in Apple Maps, through clicking the annotation callout info button.
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): title]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
}
