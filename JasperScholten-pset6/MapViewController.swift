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
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: Constants and variables
    let regionRadius: CLLocationDistance = 1000
    let defaults = UserDefaults.standard
    var parkingList = [[AnyObject]]()
    var locationManager: CLLocationManager!
    
    // MARK: Outlets
    @IBOutlet weak var monumentMap: MKMapView!
    
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        getJson()
        
        var initialLocation = CLLocation(latitude: 52.370216, longitude: 4.895168)
        
        if defaults.double(forKey: "latitude") != 0.0 {
            let latitude = defaults.double(forKey: "latitude")
            let longitude = defaults.double(forKey: "longitude")
            
            initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        }
        
        centerMapOnLocation(location: initialLocation)
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        monumentMap.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: Actions
    
    @IBAction func centerMap(_ sender: Any) {
        var latitude = defaults.double(forKey: "latitude")
        var longitude = defaults.double(forKey: "longitude")
        
        if latitude == 0.0 {
            latitude = 52.370216
            longitude = 4.895168
        }
        
        let defaultLocation = CLLocation(latitude: latitude, longitude: longitude)
        centerMapOnLocation(location: defaultLocation)
    }
    
    @IBAction func newDefaultCenter(_ sender: Any) {
        determineMyCurrentLocation()
        
        let alert = UIAlertController(title: "Centreer kaart", message: "Je hebt je huidige locatie ingesteld als nieuwe centrum van de kaart.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Determine user's location
    // http://swiftdeveloperblog.com/code-examples/determine-users-current-location-example-in-swift/
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let latitude: Double = userLocation.coordinate.latitude
        let longitude: Double = userLocation.coordinate.longitude
        
        manager.stopUpdatingLocation()
        
        let newCenter = CLLocation(latitude: latitude, longitude: longitude)
        centerMapOnLocation(location: newCenter)
        
        defaults.set(latitude, forKey: "latitude")
        defaults.set(longitude, forKey: "longitude")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    // MARK: Retrieve json
    
    func getJson() {
        //let url = URL(string: "http://api.parkshark.nl/psapi/api.jsp?day=5&hr=8&min=30&duration=3&lat=" + self.latitude + "&lon=" + self.longitude + "&methods=cash,pin")
        
        let url = URL(string: "http://api.parkshark.nl/psapi/api.jsp?day=5&hr=8&min=30&duration=1&lat=52.370216&lon=4.895168&methods=cash,pin")
        print(url!)
        
        if url == nil {
            print("Empty string")
        } else {
            
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
                
                DispatchQueue.main.async {
                    let array = json["results"]! as! [[AnyObject]]
                    self.parkingList = array
                    self.populateMap()
                }
                
            }
            
            task.resume()
        }
        
    }
    
    func populateMap() {
        
        for i in 0..<self.parkingList.count {
            
            let meterID = self.parkingList[i][0] as! String
            
            let url = URL(string: "http://api.parkshark.nl/psapi/api.jsp?action=get_meters&meternumbers=" + meterID)
            
            if url == nil {
                print("Empty string")
            } else {
                
                let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                    guard error == nil else {
                        print(error!)
                        return
                    }
                    guard let data = data else {
                        print("Data is empty")
                        return
                    }
                    
                    let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
                    
                    DispatchQueue.main.async {
                        let array = json["items"] as! [AnyObject]
                        let selection = array[0] as! [String: AnyObject]
                        
                        let lat = selection["lat"] as! Double
                        let lon = selection["lon"] as! Double
                        
                        
                        let monument = MonumentInfo(objectName: selection["adres"] as! String,
                                                    objectLocation: selection["stadsdeel"] as! String, discipline: selection["belnummer"] as! String, coordinate: CLLocationCoordinate2DMake(lat, lon), addedByUser: "info@parking.locations")
                        
                        self.monumentMap.addAnnotation(monument)
                    }
                    
                }
                
                task.resume()
            }
            
        }
        
    }

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MonumentInfo {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.isEnabled = true
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -7, y: 0)

                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! MonumentInfo
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}
