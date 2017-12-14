//
//  DebtorObject.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/15/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit
import Gloss
import RealmSwift

class DebtorObject: Object, Encodable {
    @objc dynamic var id: String?
    @objc dynamic var name: String?
    @objc dynamic var phoneNumber: String?
    @objc dynamic var address: String?
    @objc dynamic var district: String?
    @objc dynamic var firstDebit: Int = 0
    @objc dynamic var totalDebit: Int = 0
    @objc dynamic var dateCreated: Int = 0
    @objc dynamic var dateUpdated: Int = 0
    @objc dynamic var idUser: String?
    
    var detail = List<DetailDebtorObject>()
    
    func fromJSON(json: JSON) -> DebtorObject? {
        
        let debtor: DebtorObject? = DebtorObject()
        
        guard let id: String = "id" <~~ json else {
            return nil
        }
        
        debtor?.id = id
        
        if let name: String = "name" <~~ json {
            debtor?.name = name
        }
        
        if let address: String = "address" <~~ json {
            debtor?.address = address
        }
        
        if let district: String = "district" <~~ json {
            debtor?.district = district
        }
        
        if let firstDebit: Int = "firstDebit" <~~ json {
            debtor?.firstDebit = firstDebit
        }
        
        if let totalDebit: Int = "totalDebit" <~~ json {
            debtor?.totalDebit = totalDebit
        }
        
        if let dateCreated: Int = "dateCreated" <~~ json {
            debtor?.dateCreated = dateCreated
        }
        
        if let dateUpdated: Int = "dateUpdated" <~~ json {
            debtor?.dateUpdated = dateUpdated
        }
        
        if let phoneNumber: String = "phoneNumber" <~~ json {
            debtor?.phoneNumber = phoneNumber
        }
        
        return debtor
    }
   
    
    func toJSON() -> JSON? {
        return jsonify([
        "id" ~~> self.id,
        "name" ~~> self.name,
        "address" ~~> self.address,
        "district" ~~> self.district,
        "totalDebit" ~~> self.totalDebit,
        "firstDebit" ~~> self.firstDebit,
        "phoneNumber" ~~> self.phoneNumber,
        "dateCreated" ~~> self.dateCreated,
        "dateUpdated" ~~> self.dateUpdated,
        "idUser" ~~> self.idUser
        ])
    }
}

