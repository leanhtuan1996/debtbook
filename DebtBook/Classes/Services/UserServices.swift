//
//  UserServices.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 12/13/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//
import UIKit
import Firebase

class UserServices: NSObject {
    static let shared = UserServices()
    
    var currentUser: User?
    
    //ref User child
    static let refUser = Firestore.firestore().collection("Users")
        
    //sign up with email & password
    func signUp(withEmail email: String, andPassword password: String, completionHandler: @escaping(_ error: String?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                return completionHandler(error.localizedDescription)
            }
            
            self.currentUser = user
            
            return completionHandler(nil)
        }
    }
    
    func signIn(withEmail email: String, andPassword password: String, completionHandler: @escaping(_ error: String?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                return completionHandler(error.localizedDescription)
            }
            
            self.currentUser = user
            return completionHandler(nil)
        }
    }
    
    func signInWithAnonymous() {
        UserManager.shared.signInAsGuest(true)
    }
    
    func isLoggedIn() -> Bool {
        if let currentUser = Auth.auth().currentUser {
            self.currentUser = currentUser
            return true
        }
        return false
    }
    
    func signOut() {
        do
        {
            try Auth.auth().signOut()
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
    }
}
