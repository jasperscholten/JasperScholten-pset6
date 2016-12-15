//
//  LoginViewController.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 06-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//
//  All Firebase executions (Firauth) based on Grocr tutorial. [1]

import UIKit
import CoreLocation
import Firebase

class LoginViewController: UIViewController {

    // MARK: Constants and variables
    var locationManager: CLLocationManager!
    let ref = FIRDatabase.database().reference(withPath: "parkingLocations")
    
    // MARK: Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure all buttons and inputfields keep visible when the keyboard appears. [2]
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Enable user to dismiss keyboard by tapping outside of it. [3]
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Ask user permission to use its current location.
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "LoginToParking", sender: nil)
                self.emailField.text! = ""
                self.passwordField.text! = ""
            }
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func loginDidTouch(_ sender: Any) {
        FIRAuth.auth()!.signIn(withEmail: emailField.text!,
                               password: passwordField.text!) { (user, error) in
                                if error != nil {
                                    let alert = UIAlertController(title: "Foute invoer", message: "Het emailadres of wachtwoord dat je hebt ingevoerd is incorrect.", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
        }
    }
    
    @IBAction func signUpDidTouch(_ sender: Any) {
        
        let alert = UIAlertController(title: "Registreren",
                                      message: "Maak een account aan voor parkeer. Op die manier kan je je favoriete parkeerlocaties onthouden, zodat je deze makkelijk terug kan vinden.",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "OK",
                                       style: .default) { action in
                                        
                                        let emailFieldAlert = alert.textFields![0]
                                        let passwordFieldAlert = alert.textFields![1]
                                        
                                        FIRAuth.auth()!.createUser(withEmail: emailFieldAlert.text!,
                                                                   password: passwordFieldAlert.text!) { user, error in
                                                                    if error == nil {
                                                                        // Automatically login after registering.
                                                                        FIRAuth.auth()!.signIn(withEmail: self.emailField.text!,
                                                                        password: self.passwordField.text!)
                                                                    } else {
                                                                        let alert = UIAlertController(title: "Foute invoer", message: "Het emailadres of wachtwoord dat je hebt ingevoerd bestaat al of voldoet niet aan de eisen.", preferredStyle: UIAlertControllerStyle.alert)
                                                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                                                        self.present(alert, animated: true, completion: nil)
                                                                    }
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Annuleren",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Emailadres"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Wachtwoord"
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Keyboard actions [2, 3]
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: State Restoration [4]
    
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

// MARK: References

/*
 1. https://www.raywenderlich.com/139322/firebase-tutorial-getting-started-2
 2. http://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
 3. http://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
 4. https://www.raywenderlich.com/117471/state-restoration-tutorial
 */
