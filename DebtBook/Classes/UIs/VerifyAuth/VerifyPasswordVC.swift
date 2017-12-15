//
//  VerifyPasswordVC.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 12/14/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class VerifyPasswordVC: UIViewController {
    @IBOutlet weak var txtCurrentPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var viewDialog: UIView!
    @IBOutlet weak var stackViewAction: UIStackView!
    
    var delegateDebtor: DebtorDelegate?
    var delegateDetailDebtor: DetailDebtorDelegate?
    var loading = UIActivityIndicatorView()
    var id: String?
    
    init() {
        super.init(nibName: "VerifyPasswordVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewDialog.layer.cornerRadius = 5
        self.stackViewAction.layer.borderColor = UIColor.cyan.cgColor
        self.stackViewAction.layer.borderWidth = 1
        self.view.backgroundColor = UIColor.clear.withAlphaComponent(0.3)
        self.txtCurrentPassword.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.showAnimate()
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.view.alpha = 0
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (finish) in
            if finish {
                UIView.animate(withDuration: 0.05, animations: {
                    self.view.backgroundColor = UIColor.clear.withAlphaComponent(0.3)
                    self.view.transform = CGAffineTransform.identity
                })
            }
        }
    }
    
    func removeAnimate() {
        self.view.backgroundColor = UIColor.clear.withAlphaComponent(0)
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (finished) in
            if finished
            {
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        }
    }
    
    @IBAction func btnClosedClicked(_ sender: Any) {
        self.removeAnimate()
    }
    
    @IBAction func btnConfirmClicked(_ sender: Any) {
        if !self.txtCurrentPassword.hasText {
            self.txtCurrentPassword.errorMessage = "Vui lòng nhập mật khẩu"
            return
        }
        
        guard let currentPassword = self.txtCurrentPassword.text else {
            return
        }
        self.loading.showLoadingDialog(self)
        UserServices.shared.confirmPassword(with: currentPassword) { (isMatched) in
            self.loading.stopAnimating()
            if isMatched {
                
                guard let id = self.id else {
                    return
                }
                
                self.delegateDebtor?.deleteDebtor(withId: id, { (error) in
                    if let error = error {
                        self.showAlert(error, title: "Có lỗi xảy ra", buttons: nil)
                    } else {
                        self.removeAnimate()
                    }
                })
                
                self.delegateDetailDebtor?.deleteDetail(withId: id, { (error) in
                    if let error = error {
                        self.showAlert(error, title: "Có lỗi xảy ra", buttons: nil)
                    } else {
                        self.removeAnimate()
                    }
                })
                
            } else {
                self.txtCurrentPassword.errorMessage = "Mật khẩu không trùng khớp"
                return
            }
        }
    }
}
