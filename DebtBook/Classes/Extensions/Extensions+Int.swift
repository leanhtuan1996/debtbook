//
//  Extensions+Int.swift
//  Eventify
//
//  Created by Lê Anh Tuấn on 10/1/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit

extension Int {
    func toString() -> String {
        return String(self)
    }
    
    func toTimestampString() -> String {
        let dateFormatter = DateFormatter()
        
        let date = Date(timeIntervalSince1970: Double(self))
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date)
    }
}
