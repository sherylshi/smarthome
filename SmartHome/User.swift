//
//  Device.swift
//  SmartHome
//
//  Created by Jian Tian on 4/30/17.
//  Copyright © 2017 Jian Tian. All rights reserved.
//

import Foundation
import FirebaseAuth

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
