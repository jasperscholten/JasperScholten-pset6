//
//  LoginViewController.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 06-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class LoginViewController: UIViewController {

    // MARK: Constants and variables
    var locationManager: CLLocationManager!
    //let login = "login"
    let ref = FIRDatabase.database().reference(withPath: "parkingLocations")
    
    // MARK: Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordField.isSecureTextEntry = true
        
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "LoginToParking", sender: nil)
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func loginDidTouch(_ sender: Any) {
        FIRAuth.auth()!.signIn(withEmail: emailField.text!,
                               password: passwordField.text!)
        emailField.text! = ""
        passwordField.text! = ""
    }
    
    @IBAction func signUpDidTouch(_ sender: Any) {
        
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
                                        
                                        let emailFieldAlert = alert.textFields![0]
                                        let passwordFieldAlert = alert.textFields![1]
                                        
                                        FIRAuth.auth()!.createUser(withEmail: emailFieldAlert.text!,
                                                                   password: passwordFieldAlert.text!) { user, error in
                                                                    if error == nil {
                                                                        FIRAuth.auth()!.signIn(withEmail: self.emailField.text!,
                                                                        password: self.passwordField.text!)
                                                                    }
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - State Restoration
    
    override func encodeRestorableState(with coder: NSCoder) {
        if let selectedEmail = emailField.text {
            coder.encode(selectedEmail, forKey: "selectedEmail")
        }
        
        if let selectedPassword = passwordField.text {
            coder.encode(selectedPassword, forKey: "selectedPassword")
        }
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        
        if let selectedEmail = coder.decodeObject(forKey: "selectedEmail") as? String {
            emailField.text = selectedEmail
        }
        
        if let selectedPassword = coder.decodeObject(forKey: "selectedPassword") as? String {
            passwordField.text = selectedPassword
        }
        
        super.decodeRestorableState(with: coder)
    }
    
}
