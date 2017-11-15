//
//  Extensions+Data.swift
//  Pharmacy
//
//  Created by Lê Anh Tuấn on 9/18/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import Foundation
import UIKit

extension Data {
    func toDictionary() -> [String: Any]? {
        
        do {
            if let json = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] {
                return json
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil        
    }

}
