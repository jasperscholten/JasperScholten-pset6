//
//  MonumentListViewController.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 06-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//

// http://api.parkshark.nl/jsonapi.html

import UIKit
import CoreLocation

class MonumentListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    // MARK: Constants and variables
    var parkingList = [[AnyObject]]()
    var locationManager: CLLocationManager!
    var latitude: String = ""
    var longitude: String = ""
    
    // MARK: Outlets
    @IBOutlet weak var monumentListTableView: UITableView!
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.determineMyCurrentLocation()
    }
    
    
    // MARK: Determine user's location
    // http://swiftdeveloperblog.com/code-examples/determine-users-current-location-example-in-swift/
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        self.latitude = String(format:"%f", userLocation.coordinate.latitude)
        self.longitude = String(format:"%f", userLocation.coordinate.longitude)
        
        // Now repeatingly fetching data - best solution?
        self.getJson()
        
        print("user latitude = \(self.latitude)")
        print("user longitude = \(self.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    // MARK: Retrieve json
    
    func getJson() {
        let url = URL(string: "http://api.parkshark.nl/psapi/api.jsp?day=5&hr=8&min=30&duration=3&lat=" + self.latitude + "&lon=" + self.longitude + "&methods=cash,pin")
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
                    let array = json["advice"]! as! [[AnyObject]]
                    self.parkingList = array
                    
                    // http://stackoverflow.com/questions/27797930/swift-how-to-create-a-table-view-based-on-data-downloaded-asynchronously
                    self.monumentListTableView.reloadData()
                }
                
            }
            
            task.resume()
        }
    }
    
    
    // MARK: Populate tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(parkingList.count)
        return parkingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = monumentListTableView.dequeueReusableCell(withIdentifier: "monumentListCell", for: indexPath) as! MonumentListCell
        
        print(self.parkingList[indexPath.row][1])
        
        cell.monumentListName.text = (self.parkingList[indexPath.row][3] as! String)
        let parkingRate = (self.parkingList[indexPath.row][1] as! Float)/3
        cell.monumentListAdress.text = "€ \(String(format: "%.2f", parkingRate)) per uur"
        
        return cell
        
    }

}
