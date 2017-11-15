//
//  DetailDebtorObject.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/15/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit
import Gloss

class DetailDebtorObject: NSObject, Decodable {
    /*
     "id": 1,
     "debtor_id": 3,
     "amount": 1000000,
     "created_at": "2017-11-15T15:46:26.000Z",
     "updated_at": "2017-11-15T15:46:26.000Z"
     
     */
    var id: Int
    var id_debtor: Int?
    var debt: Int?
    var borrowedDay: String?
    
    override init() {
        self.id = 0
    }
    
    required init?(json: JSON) {
        guard let id: Int = "id" <~~ json, let idDebtor: Int = "debtor_id" <~~ json else {
            return nil
        }
        
        self.id = id
        self.id_debtor = idDebtor
        self.debt = "amount" <~~ json
        self.borrowedDay = "created_at" <~~ json
    }
}
