//
//  AddDetailVC.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/17/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit

enum DetailDebitType {
    case borrow
    case pay
}

class AddDetailVC: UIViewController {
    
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var txtDebit: UITextField!
    @IBOutlet weak var segSelectType: UISegmentedControl!
    
    var detailDebitType = DetailDebitType.borrow
    var loading = UIActivityIndicatorView()
    var delegate: DetailDebtorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewPopup.layer.cornerRadius = 5
        self.viewPopup.layer.masksToBounds = false
        segSelectType.addTarget(self, action: #selector(self.changeType), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showAnimate()
        self.txtDebit.becomeFirstResponder()
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
    
    func changeType() {
        switch self.segSelectType.selectedSegmentIndex {
        case 1:
            self.detailDebitType = .pay
        default:
            self.detailDebitType = .borrow
        }
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        
        if !self.txtDebit.hasText {
            return
        }
        
        guard let debitString = self.txtDebit.text, var debit = debitString.toInt() else {
            return
        }
        
        if debit == 0 { self.showAlert("Nhập số khác 0", title: "Lỗi", buttons: nil); return }
        
        switch self.detailDebitType {
        case .borrow:
            if debit < 0 {
                debit = debit * (-1)
            }
        case .pay:
            if debit > 0 {
                debit *= -1
            }
        }
        
        
        let detail = DetailDebtorObject()
        detail.dateCreated = Date().timeIntervalSince1970.toInt()
        detail.debt = debit
        
        self.delegate?.addDetail(with: detail)
        
        self.removeAnimate()
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        removeAnimate()
    }
}
