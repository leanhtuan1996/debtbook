//
//  SignUpVC.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 12/13/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class SignUpVC: UIViewController {

    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    
    @IBOutlet weak var btnSignUp: UIButton!
    
    @IBOutlet weak var viewSignIn: UIView!
    
    @IBOutlet weak var btnSignIn: UIButton!
    
    var loading = UIActivityIndicatorView()
    
    init() {
        super.init(nibName: "SignUpVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func btnSignInAsGuest(_ sender: Any) {
        loading.showLoadingDialog(self)
        UserServices.shared.signInWithAnonymous()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.showMainView()
        }
    }
    @IBAction func btnSignUpClicked(_ sender: Any) {
        guard let email = self.txtEmail.text, let password = self.txtPassword.text else {
            return
        }
        
        self.loading.showLoadingDialog(self)
        
        UserServices.shared.signUp(withEmail: email, andPassword: password) { (error) in
            if let error = error {
                self.showAlert(error, title: "Đăng ký thất bại", buttons: nil)
                return
            }
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.showMainView()
            }
            
        }
    }
    @IBAction func btnSignInClicked(_ sender: Any) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.showSignInView()
        }
    }
}
