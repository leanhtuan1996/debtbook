//
//  DetailDebtorObject.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/15/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit
import Gloss
import RealmSwift

class DetailDebtorObject: Object, Encodable {
    
    @objc dynamic var id: String?
    @objc dynamic var debt: Int = 0
    @objc dynamic var dateCreated: Int = 0
  
    func fromJSON(json: JSON) -> DetailDebtorObject? {
        
        let detail: DetailDebtorObject? = DetailDebtorObject()
        
        guard let id: String = "id" <~~ json else {
            return nil
        }
        
        detail?.id = id
        
        if let debt: Int = "debt" <~~ json {
            detail?.debt = debt
        }
        
        if let dateCreated: Int = "dateCreated" <~~ json {
            detail?.dateCreated = dateCreated
        }
        
        return detail
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "debt" ~~> self.debt,
            "dateCreated" ~~> self.dateCreated
            ])
    }
}
