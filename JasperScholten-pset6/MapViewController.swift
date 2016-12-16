//
//  MapViewController.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 06-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//
//  Use of Mapkit primarily based on tutorial by Audrey Tam. [1]
//  Parkshark API used for data, returns parkinglocations in Amsterdam and their characteristics. [2]

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: Constants and variables
    var parkingList = [[AnyObject]]()
    var locationManager: CLLocationManager!
    let defaults = UserDefaults.standard
    let regionRadius: CLLocationDistance = 500
    let spinner = customActivityIndicator(text: "Locaties ophalen")
    var mapLatitude = ""
    var mapLongitude = ""
    var latitudeDelta = 0.0
    var longitudeDelta = 0.0
    
    // MARK: Outlets
    @IBOutlet weak var parkingMap: MKMapView!
    
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.spinner)
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
        parkingMap.setRegion(coordinateRegion, animated: true)
    }
    
    
    // MARK: Actions
    
    /// Center mapview on default location.
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
    
    /// Set current location as new default center of map.
    @IBAction func newDefaultCenter(_ sender: Any) {
        determineMyCurrentLocation()
        
        let alert = UIAlertController(title: "Centreer kaart", message: "Je hebt je huidige locatie ingesteld als nieuwe centrum van de kaart.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Determine user's current location [3]
    
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
        
        // Save current location for later use, such as centermap.
        defaults.set(latitude, forKey: "latitude")
        defaults.set(longitude, forKey: "longitude")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    
    // MARK: Retrieve json [4]
    func getJson() {
        let url = URL(string: "http://api.parkshark.nl/psapi/api.jsp?day=5&hr=8&min=30&duration=3&lat=" + mapLatitude + "&lon=" + mapLongitude + "&methods=cash,pin")
        
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
                let httpResponse = response as! HTTPURLResponse
                guard httpResponse.statusCode == 200 else {
                    print("Statuscode \(httpResponse.statusCode)")
                    return
                }
                
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
                
                // Save parkinglocation info in array, then populate map with this data.
                DispatchQueue.main.async {
                    let array = json["results"]! as! [[AnyObject]]
                    self.parkingList = array
                    self.populateMap()
                    self.spinner.hide()
                }
            }
            task.resume()
        }
    }
    
    
    // MARK: Populate mapview with annotations, based on locations from the retrieved JSON file.
    func populateMap() {
        
        // Remove annotations currently populating the map.
        let allAnnotations = self.parkingMap.annotations
        self.parkingMap.removeAnnotations(allAnnotations)
        
        var start = Int()
        var end = Int()
        var count = Int()
        
        // Vary number and way of placing annotations, based on the zoomlevel of the map.
        if latitudeDelta <= 0.01 {
            start = 0
            end = 50
            count = 1
        } else if 0.01 < latitudeDelta && latitudeDelta <= 0.02 {
            start = 0
            end = 150
            count = 1
        } else if 0.02 < latitudeDelta && latitudeDelta <= 0.05 {
            start = 0
            end = 400
            count = 6
        } else {
            start = 0
            end = self.parkingList.count
            count = 30
        }
        
        // Add a certain amount of annotations to the map, in a way described above. [5]
        for i in stride(from: start, to: end, by: count) {
            
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
                        
                        // Bundle relevant data specific to this parkingLocation.
                        let parkingLocation = ParkingInfo(objectAddress: selection["adres"] as! String,
                                                    objectLocation: selection["stadsdeel"] as! String, discipline: selection["belnummer"] as! String, coordinate: CLLocationCoordinate2DMake(lat, lon), addedByUser: "info@parking.locations")
                        
                        // Add annotation based on and containing the data bundled above.
                        self.parkingMap.addAnnotation(parkingLocation)
                    }
                }
                task.resume()
            }
        }
    }
}


// MARK: Deals with details of populating mapview with annotations.

extension MapViewController: MKMapViewDelegate {
    
    /// Create reusable annotations.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkingInfo {
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
    
    /// Add functionality to the detailbutton on annotation. When this button is tapped, Apple MAps open and shows the route to that location.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! ParkingInfo
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    /// Repopulate mapview with new set of annotations after user drags the map.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.spinner.show()
        mapLatitude = "\(mapView.centerCoordinate.latitude)"
        mapLongitude = "\(mapView.centerCoordinate.longitude)"
        
        // Determine zoomlevel.
        latitudeDelta = mapView.region.span.latitudeDelta
        longitudeDelta = mapView.region.span.longitudeDelta
        getJson()
    }

}

// MARK: References

/*
 1. https://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
 2. http://api.parkshark.nl/jsonapi.html
 3. http://swiftdeveloperblog.com/code-examples/determine-users-current-location-example-in-swift/
 4. http://stackoverflow.com/questions/38292793/http-requests-in-swift-3
 5. https://www.weheartswift.com/loops/
 */
