//
//  Extensions+UIViewController.swift
//  Pharmacy
//
//  Created by Lê Anh Tuấn on 9/18/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(_ message:String, title: String, buttons: [UIAlertAction]?) {
        let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let buttons = buttons {
            for button in buttons {
                alert.addAction(button)
            }
        } else {
            alert.addAction(.init(title: "Okay", style: .default, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    //dismiss keyboard
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
