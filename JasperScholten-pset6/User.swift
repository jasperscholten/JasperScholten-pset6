//
//  User.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 09-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//
//  When linking the app with Firebase, this struct can be used to structure a 'user'. This enables the app to distinguish different users in the Firebase database on the basis of their email and/or userid. In this app it is used to only show a user's own favorites.

import Foundation
import Firebase

struct User {
    
    let uid: String
    let email: String
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
