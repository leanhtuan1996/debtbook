//
//  SignInVC.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 12/13/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class SignInVC: UIViewController {
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var viewSignUp: UIView!
    @IBOutlet weak var btnSignUp: UIButton!
    
    var loading = UIActivityIndicatorView()
    
    init() {
        super.init(nibName: "SignInVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewSignUp.layer.cornerRadius = 5
        self.btnLogin.layer.cornerRadius = 5
        self.btnSignUp.layer.cornerRadius = 5
    }

    
    @IBAction func btnSignInAsGuestClicked(_ sender: Any) {
        UserServices.shared.signInWithAnonymous()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.showMainView()
        }
    }

    @IBAction func btnSignInClicked(_ sender: Any) {
        guard let email = self.txtEmail.text, let password = self.txtPassword.text else {
            return
        }
        
        self.loading.showLoadingDialog(self)
        
        UserServices.shared.signIn(withEmail: email, andPassword: password) { (error) in
            
            self.loading.stopAnimating()
            
            if let error = error {
                self.showAlert(error, title: "Đăng nhập thất bại", buttons: nil);
                return
            }
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.showMainView()
            }
        }
    }
    @IBAction func btnSignUpClicked(_ sender: Any) {
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.showSignUpView()
        }
    }
}
