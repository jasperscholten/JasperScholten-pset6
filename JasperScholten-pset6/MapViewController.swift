//
//  MapViewController.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 06-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//

// https://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial

import UIKit
import MapKit

class MapViewController: UIViewController {

    //MARK: Constants
    let regionRadius: CLLocationDistance = 1000
    
    // MARK: Outlets
    @IBOutlet weak var monumentMap: MKMapView!
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let initialLocation = CLLocation(latitude: 52.370216, longitude: 4.895168)
        centerMapOnLocation(location: initialLocation)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        monumentMap.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: Actions


}
