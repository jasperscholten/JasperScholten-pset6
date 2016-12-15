//
//  ParkingAdviceViewController.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 06-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//

// http://api.parkshark.nl/jsonapi.html

import UIKit
import CoreLocation
import Firebase

class ParkingAdviceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    // MARK: Constants and variables
    let ref = FIRDatabase.database().reference(withPath: "parkingLocations")
    let spinner = customActivityIndicator(text: "Advies laden")
    var parkingList = [[AnyObject]]()
    var locationManager: CLLocationManager!
    var latitude: String = ""
    var longitude: String = ""
    var user: User!
    
    // MARK: Outlets
    @IBOutlet weak var parkingAdviceTableView: UITableView!
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.spinner)
        
        self.determineMyCurrentLocation()
        
        user = User(uid: "FakeId", email: "location@parking.com")
        
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
        }
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
        
        self.latitude = String(format:"%f", userLocation.coordinate.latitude)
        self.longitude = String(format:"%f", userLocation.coordinate.longitude)
        
        manager.stopUpdatingLocation()
        
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
                    self.parkingAdviceTableView.reloadData()
                    self.spinner.hide()
                }
                
            }
            
            task.resume()
        }
    }
    
    
    // MARK: Populate tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = parkingAdviceTableView.dequeueReusableCell(withIdentifier: "adviceListCell", for: indexPath) as! AdviceListCell
        
        cell.parkingAdviceAddress.text = (self.parkingList[indexPath.row][3] as! String)
        let parkingRate = (self.parkingList[indexPath.row][1] as! Float)/3
        cell.parkingAdvicePrice.text = "€ \(String(format: "%.2f", parkingRate)) per uur"
        
        return cell
        
    }
    
    // MARK: Actions
    
    @IBAction func addToFavorites(_ sender: Any) {
        
        // Method to retrieve the indexpath of the cell that the user clicks on. http://stackoverflow.com/questions/39603922/getting-row-of-uitableview-cell-on-button-press-swift-3
        let switchPos = (sender as AnyObject).convert(CGPoint.zero, to: self.parkingAdviceTableView)
        let indexPath = self.parkingAdviceTableView.indexPathForRow(at: switchPos)
        
        let parkingAdress = self.parkingList[(indexPath?.row)!][3] as! String
        let meterID = self.parkingList[(indexPath?.row)!][0] as! String
        let lat = self.parkingList[(indexPath?.row)!][4] as! Double
        let lon = self.parkingList[(indexPath?.row)!][5] as! Double
        
        let parkingLocation = ParkingInfo(objectName: parkingAdress,
                                           objectLocation: meterID,
                                           discipline: "\(self.parkingList[(indexPath?.row)!][4]), \(self.parkingList[(indexPath?.row)!][5])",
                                           coordinate: CLLocationCoordinate2DMake(lat, lon),
                                           addedByUser: self.user.email )

        let parkingLocationRef = self.ref.child(meterID)
        parkingLocationRef.setValue(parkingLocation.toAnyObject())
        
        let alert = UIAlertController(title: "Toegevoegd aan favorieten", message: "Je hebt \(parkingAdress) toegevoegd aan je favoriete parkeerlocaties.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}