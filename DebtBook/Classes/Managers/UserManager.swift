//
//  UserManager.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 12/13/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserManager: NSObject {
    static let shared = UserManager()
    
    let userDefaults = UserDefaults.standard
    
    //check token in NSUserDefaults
    func isAnonymousLoggedIn() -> Bool {
        let isAnonymous = userDefaults.bool(forKey: "isAnonymous")
        
        if isAnonymous {
            return true
        }
        return false
    }
    
    func signInAsGuest(_ isAnonymous: Bool = true) {
        if isAnonymous {
            userDefaults.set(true, forKey: "isAnonymous")
        } else {
            userDefaults.set(false, forKey: "isAnonymous")
        }
    }
    
    func logOutAsGuest() {
        userDefaults.set(false, forKey: "isAnonymous")
    }
}
