//
//  AddDetailVC.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/17/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit

class AddDetailVC: UIViewController {

    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var txtDebit: UITextField!
    @IBOutlet weak var segSelectType: UISegmentedControl!
    
    var isAddDebit = true
    var idDebtor: Int?
    var loading = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewPopup.layer.cornerRadius = 5
        self.txtDebit.delegate = self
        segSelectType.addTarget(self, action: #selector(self.changeType), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showAnimate()
    }
    
    func showAnimate()
    {
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
    
    func removeAnimate()
    {
        self.view.backgroundColor = UIColor.clear.withAlphaComponent(0)
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (finished) in
            if finished
            {
                if let vc = self.parent as? DetailsDebtorVC {
                    vc.didMove(toParentViewController: self)
                }
                
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        }
    }
    
    func changeType() {
        switch self.segSelectType.selectedSegmentIndex {
        case 1:
            self.isAddDebit = false
        default:
            self.isAddDebit = true
        }
    }

  
    @IBAction func btnDoneClicked(_ sender: Any) {
        
        if !self.txtDebit.hasText {
            return
        }
        
        guard let debitString = self.txtDebit.text, let id = self.idDebtor else {
            return
        }
        
        guard var debit = debitString.toInt() else {
            return
        }
        
        self.loading.showLoadingDialog(self)
        if isAddDebit {
            if debit < 0 {
                debit = debit * (-1)
            }
        } else {
            if debit > 0 {
                debit *= -1
            }
        }
        
        if debit == 0 { self.showAlert("Nhập số khác 0", title: "Lỗi", buttons: nil); return}
        
        DebtServices.shared.addDetail(with: id, debts: debit) { (error) in
            if let error = error {
                self.showAlert(error, title: "Thêm thất bại", buttons: nil)
                return
            }
            self.removeAnimate()
        }
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        removeAnimate()
    }
}

extension AddDetailVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.2) { 
            self.viewPopup.transform = CGAffineTransform(translationX: self.viewPopup.layer.anchorPoint.x, y: self.viewPopup.layer.anchorPoint.x - 20)
        }
        return true
    }
}
