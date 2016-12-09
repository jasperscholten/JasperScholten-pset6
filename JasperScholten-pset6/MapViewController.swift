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

class MapViewController: UIViewController{

    //MARK: Constants and variables
    let regionRadius: CLLocationDistance = 1000
    var parkingList = [[AnyObject]]()
    var parkingLocations = [[AnyObject]]()
    
    // MARK: Outlets
    @IBOutlet weak var monumentMap: MKMapView!
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        getJson()
        
        let initialLocation = CLLocation(latitude: 52.370216, longitude: 4.895168)
        centerMapOnLocation(location: initialLocation)
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        monumentMap.setRegion(coordinateRegion, animated: true)
    }
    
    
    // MARK: Retrieve json
    
    func getJson() {
        //let url = URL(string: "http://api.parkshark.nl/psapi/api.jsp?day=5&hr=8&min=30&duration=3&lat=" + self.latitude + "&lon=" + self.longitude + "&methods=cash,pin")
        
        let url = URL(string: "http://api.parkshark.nl/psapi/api.jsp?day=5&hr=8&min=30&duration=1&lat=37.785834&lon=-122.406417&methods=cash,pin")
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
        //for i in 0...100 {
            
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
                        //print(selection["lat"]!)
                        //print(selection["lon"]!)
                        //print(selection["adres"]!)
                        //self.parkingLocations.append([selection["lat"]!, selection["lon"]!, selection["adres"]!])
                        
                        let lat = selection["lat"] as! Double
                        let lon = selection["lon"] as! Double
                        
                        
                        let monument = MonumentInfo(objectName: selection["adres"] as! String,
                                                    objectLocation: selection["stadsdeel"] as! String, discipline: selection["belnummer"] as! String, coordinate: CLLocationCoordinate2DMake(lat, lon), addedByUser: "hungry@person.food")
                        
                        self.monumentMap.addAnnotation(monument)
                    }
                    
                }
                
                task.resume()
            }
            
        }
        
    }
    
    
    // MARK: Actions


}

extension ViewController: MKMapViewDelegate {
    
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
                view.calloutOffset = CGPoint(x: -5, y: 5)
                
                // Not showing info button - why?
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            print("button tapped")
        }
    }
}
