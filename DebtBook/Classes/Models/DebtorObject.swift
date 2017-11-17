//
//  DebtorObject.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/15/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit
import Gloss

class DebtorObject: NSObject, Glossy {
    var id: Int
    var name: String?
    var phoneNumber: String?
    var address: String?
    var district: String?
    var detail: [DetailDebtorObject]?
    var firstDebit: Int?
    var totalDebit: Int?
    var dateCreated: String?
    
    override init() {
        self.id = 0
    }
    
    required init?(json: JSON) {
        
        /*
         ["district": Sisattanak, "name": Lam Quang Q, "phonenumber": 0963225057, "id": 3, "firstdebit": 2000000, "updated_at": 2017-11-15T15:54:44.000Z, "address": 30B, "created_at": 2017-11-15T15:46:12.000Z, "currentdebit": 4000000]
         */
        
        guard let id: Int = "id" <~~ json else {
            return nil
        }
        
        self.id = id
        self.name = "name" <~~ json
        self.phoneNumber = "phonenumber" <~~ json
        self.address = "address" <~~ json
        self.district = "district" <~~ json
        self.firstDebit = "firstdebit" <~~ json
        self.totalDebit = "currentdebit" <~~ json
        self.dateCreated = "created_at" <~~ json
        
                
        if let detailDebtor: [JSON] = "details" <~~ json {
            if let detailsDebtor = [DetailDebtorObject].from(jsonArray: detailDebtor) {
                self.detail = detailsDebtor
            }
        }
        
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "name" ~~> self.name,
            "phonenumber" ~~> self.phoneNumber,
            "address" ~~> self.address,
            "district" ~~> self.district,
            "firstdebit" ~~> self.firstDebit
            ])
    }
}
