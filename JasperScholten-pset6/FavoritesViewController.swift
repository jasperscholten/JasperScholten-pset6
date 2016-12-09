//
//  FavoritesViewController.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 06-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//

import UIKit
import Firebase

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Constants and variables
    var locations: [MonumentInfo] = []
    let ref = FIRDatabase.database().reference(withPath: "parkingLocations")
    
    // MARK: Outlets
    @IBOutlet weak var favoritesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref.observe(.value, with: { snapshot in
    
            var newLocations: [MonumentInfo] = []
            
            for item in snapshot.children {
                let parkingLocation = MonumentInfo(snapshot: item as! FIRDataSnapshot)
                newLocations.append(parkingLocation)
            }
            
            self.locations = newLocations
            self.favoritesTableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = favoritesTableView.dequeueReusableCell(withIdentifier: "favoritesCell", for: indexPath) as! FavoritesCell
        let parkingLocation = self.locations[indexPath.row]
        
        cell.favoriteName.text = parkingLocation.objectName
        cell.favoriteAdress.text = "Meternummer \(parkingLocation.objectLocation)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let parkingLocation = locations[indexPath.row]
            parkingLocation.ref?.removeValue()
        }
    }
    

}
