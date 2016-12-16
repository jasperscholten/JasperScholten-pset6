//
//  NavigationViewController.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 06-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//
//  This viewcontroller deals with the main menu. Signing out with Firebase is defined in this file, whereas the storyboard file deals with segues to other viewcontrollers.

import UIKit
import Firebase

class NavigationViewController: UIViewController {

    @IBAction func signOut(_ sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
        dismiss(animated: true, completion: nil)
    }
    
    
}

