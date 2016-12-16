//
//  FavoritesViewController.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 06-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//
//  This viewcontroller shows a tableview of the favorite parkinglocations of the user currently logged in. These favorites are retrieved from Firebase.

import UIKit
import Firebase

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Constants and variables
    var locations: [ParkingInfo] = []
    let ref = FIRDatabase.database().reference(withPath: "parkingLocations")
    var user: User!
    
    // MARK: Outlets
    @IBOutlet weak var favoritesTableView: UITableView!
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Determine current user and save in variable user
        user = User(uid: "FakeId", email: "location@parking.com")
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
        }

        // Retrieve favorites data from Firebase.
        ref.observe(.value, with: { snapshot in
            var newLocations: [ParkingInfo] = []
            for item in snapshot.children {
                let parkingLocation = ParkingInfo(snapshot: item as! FIRDataSnapshot)
                if parkingLocation.addedByUser == self.user.email{
                    newLocations.append(parkingLocation)
                }
            }
            self.locations = newLocations
            self.favoritesTableView.reloadData()
        })
    }
    
    // MARK: Populate tableView with favorites.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = favoritesTableView.dequeueReusableCell(withIdentifier: "favoritesCell", for: indexPath) as! FavoritesCell
        let parkingLocation = self.locations[indexPath.row]
        
        cell.favoriteAdress.text = parkingLocation.objectAddress
        cell.favoriteName.text = "Favoriet van \(parkingLocation.addedByUser)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let parkingLocation = locations[indexPath.row]
            parkingLocation.ref?.removeValue()
        }
    }
}
