//
//  Extensions+String.swift
//  Pharmacy
//
//  Created by Lê Anh Tuấn on 9/18/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func jsonDateToDate() -> String {
        //convert JSON datetime to date`
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let dateFormatted = dateFormatter.date(from: self) {
            //convert date to "yyyy-MM-dd" format
            dateFormatter.dateFormat = "MM/dd/yyyy"
            return dateFormatter.string(from: dateFormatted)
        } else {
            return ""
        }
    }
    
    func toInt() -> Int? {
        
        if let int = Int(self) {
            return int
        }
        return nil
    }
    
    func toDouble() -> Double? {
        if let double = Double(self) {
            return double
        }
        return nil
    }
    
    func toTimeStamp(format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        guard let date = dateFormatter.date(from: self) else {
            return nil
        }
        
        return String(describing: date.timeIntervalSince1970)
    }
    
    func timestampToDate() -> String {
        let dateFormatter = DateFormatter()
        
        guard let timestamp = self.toDouble() else {
            return "N/A"
        }
        
        let date = Date(timeIntervalSince1970: timestamp)
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date)
    }
    
    func toTimeStamp() -> String {
        let date = Date()
        return String(date.timeIntervalSince1970)
    }
    
    func isDate() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        if let _ = dateFormatter.date(from: self) {
            return true
        }
        return false
    }
    
    func isInt() -> Bool {
        
        return Int(self) != nil
    }
}

