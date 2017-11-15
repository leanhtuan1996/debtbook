//
//  DebtServices.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/15/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit
import Gloss
import Alamofire

class DebtServices: NSObject {
    static let shared = DebtServices()
    
    /**
     
     [
     {
     "id": 1,
     "name": "Lam Quang Q",
     "phonenumber": "0963225057",
     "address": "30B",
     "district": "Sisattanak",
     "firstdebit": 2000000,
     "currentdebit": 2000000,
     "created_at": "2017-11-15T14:35:34.000Z",
     "updated_at": "2017-11-15T14:35:34.000Z"
     }
     ]
     */
    
    func getDebtors(_ completionHandler: @escaping (_ debtors: [DebtorObject]?, _ error: String?) -> Void ) {
        Alamofire.request(DebtsRouter.getDebts())
            .validate()
            .response { (dataRespone) in
                if let error = dataRespone.error {
                    return completionHandler(nil, Helpers.handleError(dataRespone.response, error: error as NSError))
                }
                
                guard let data = dataRespone.data else {
                    return completionHandler(nil, "Data respone not found")
                }
                
                guard let debtors = [DebtorObject].from(data: data) else {
                    return completionHandler(nil, "Convert data to object has been failed")
                }
                
                return completionHandler(debtors, nil)
        }
    }
    
    
    func getDebtor(with id: Int , completionHandler: @escaping (_ debtor: DebtorObject?, _ error: String?) -> Void ) {
        let parameter = [
            "debtorId" : id
        ]
        
        Alamofire.request(DebtsRouter.getDebt(parameter))
        .validate()
        .response { (dataRespone) in
            if let error = dataRespone.error {
                return completionHandler(nil, Helpers.handleError(dataRespone.response, error: error as NSError))
            }
            
            guard let data = dataRespone.data else {
                return completionHandler(nil, "Data respone not found")
            }
            
            guard let debtor = DebtorObject(data: data) else {
                return completionHandler(nil, "Convert data to object has been failed")
            }
            
            return completionHandler(debtor, nil)
        }
    }
    
    
    /**
     
     {
     "id": 1,
     "name": "Lam Quang Q",
     "phonenumber": "0963225057",
     "address": "30B",
     "district": "Sisattanak",
     "firstdebit": "2000000",
     "currentdebit": "2000000",
     "updated_at": "2017-11-15T14:35:34.765Z",
     "created_at": "2017-11-15T14:35:34.765Z"
     }
     
     */
    
    
    func addDebtor(with debtor: DebtorObject, completionHandler: @escaping (_ debtor: DebtorObject?, _ error: String?) -> Void) {
        guard let json = debtor.toJSON() else {
            return completionHandler(nil, "Convert object to json has been failed")
        }
        
        Alamofire.request(DebtsRouter.addDebt(json))
            .validate()
            .response { (dataRespone) in
                if let error = dataRespone.error {
                    return completionHandler(nil, Helpers.handleError(dataRespone.response, error: error as NSError))
                }
                
                guard let data = dataRespone.data else {
                    return completionHandler(nil, "Data respone not found")
                }
                
                guard let json = data.toDictionary() else {
                    return completionHandler(nil, "Convert data to json has been failed")
                }
                
                guard let debtor = DebtorObject(json: json) else {
                    return completionHandler(nil, "Convert json to object has been failed")
                }
                
                return completionHandler(debtor, nil)
        }
    }
    
    /**{
     "id": 1,
     "name": "Lam Quang",
     "phonenumber": "0123456789",
     "address": "30B duong so 3",
     "district": "Sisattanak",
     "firstdebit": "2000000",
     "currentdebit": 2000000,
     "created_at": "2017-11-15T14:35:34.000Z",
     "updated_at": "2017-11-15T14:58:07.868Z"
     }*/
    
    func editDebtor(with debtor:  DebtorObject, completionHandler: @escaping (_ debtor: DebtorObject?, _ error: String?) -> Void) {
        guard let json = debtor.toJSON() else {
            return completionHandler(nil, "Convert object to json has been failed")
        }
        
        Alamofire.request(DebtsRouter.addDebt(json))
            .validate()
            .response { (dataRespone) in
                if let error = dataRespone.error {
                    return completionHandler(nil, Helpers.handleError(dataRespone.response, error: error as NSError))
                }
                
                guard let data = dataRespone.data else {
                    return completionHandler(nil, "Data respone not found")
                }
                
                guard let json = data.toDictionary() else {
                    return completionHandler(nil, "Convert data to json has been failed")
                }
                
                guard let debtor = DebtorObject(json: json) else {
                    return completionHandler(nil, "Convert json to object has been failed")
                }
                
                return completionHandler(debtor, nil)
        }
        
    }
    
    func deleteDebtor(with id: Int, completionHandler: @escaping (_ error: String?) -> Void) {
        let parameter = [
            "id" : id
        ]
        
        Alamofire.request(DebtsRouter.deleteDebt(parameter))
            .validate()
            .response { (dataRespone) in
                if let error = dataRespone.error {
                    return completionHandler(Helpers.handleError(dataRespone.response, error: error as NSError))
                }
                
                guard let data = dataRespone.data else {
                    return completionHandler("Data respone not found")
                }
                
                print(data)
        }
    }
    
    /**
     {
     "id": 1,
     "debtor_id": "3",
     "amount": "1000000",
     "updated_at": "2017-11-15T15:46:26.702Z",
     "created_at": "2017-11-15T15:46:26.702Z"
     }*/
    
    func addDetail(with idUser: Int, debts: Int, completionHandler: @escaping (_ error: String?) -> Void) {
        let parameters: [String: Any] = [
            "debtorId" : idUser,
            "amount" : debts
        ]
        
        Alamofire.request(DebtsRouter.addDetailDebt(parameters))
        .validate()
        .response { (dataRespone) in
            if let error = dataRespone.error {
                return completionHandler(Helpers.handleError(dataRespone.response, error: error as NSError))
            }
            
            guard let data = dataRespone.data else {
                return completionHandler("Data respone not found")
            }
            
            guard let debtor = DebtorObject(data: data) else {
                return completionHandler("Convert data to object has been failed")
            }
            
            return completionHandler(nil)
        }
    }
    
    func deleteDetail(completionHandler: @escaping (_ error: String?) -> Void) {
        
    }
    
    
}
