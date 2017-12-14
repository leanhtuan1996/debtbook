//
//  LaunchVC.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 12/13/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit

class LaunchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UserServices.shared.signOut()
        UserManager.shared.logOutAsGuest()

        //to checking for sign in, sign up and etc...
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if UserManager.shared.isAnonymousLoggedIn() {
            appDelegate.showMainView()
            return
        }        
        
        if UserServices.shared.isLoggedIn() {
            appDelegate.showMainView()
        } else {
            appDelegate.showSignInView()
        }
    }
}
