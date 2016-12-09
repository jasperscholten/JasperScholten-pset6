//
//  User.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 09-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//

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
