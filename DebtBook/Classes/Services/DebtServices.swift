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
import RealmSwift
import FirebaseAuth
import FirebaseFirestore

class DebtServices: NSObject {
    static let shared = DebtServices()
    
    let refDebtor = Firestore.firestore().collection("Debtor")
    
    let settings = Firestore.firestore()
    
    func getDebtors(isListen listen: Bool = true, _ completionHandler: @escaping (_ debtors: [DebtorObject]?, _ error: String?) -> Void ) {
        
        if UserManager.shared.isAnonymousLoggedIn() {
            //fetch all data in local database
        } else {
            
            guard let id = UserServices.shared.currentUser?.uid else {
                return completionHandler([], "User not found")
            }
            
            if listen {
                refDebtor.whereField("idUser", isEqualTo: id).addSnapshotListener({ (snapshot, error) in
                    if let error = error {
                        return completionHandler([], error.localizedDescription)
                    }
                    
                    guard let snapshot = snapshot else {
                        return completionHandler([], nil)
                    }
                    
                    if snapshot.documents.count == 0 {
                        return completionHandler([], nil)
                    }
                    
                    var debtors = [DebtorObject]()
                    
                    
                    //fetch data json to object of array and return array
                    snapshot.documents.forEach({ (document) in
                        if let debtor = DebtorObject().fromJSON(json: document.data()) {
                            debtors.append(debtor)
                        }
                    })
                    
                    return completionHandler(debtors, nil)
                })
            } else {
                refDebtor.whereField("idUser", isEqualTo: id).getDocuments(completion: { (snapshot, error) in
                    if let error = error {
                        return completionHandler([], error.localizedDescription)
                    }
                    
                    guard let snapshot = snapshot else {
                        return completionHandler([], "Data snapshot is missing!")
                    }
                    
                    if snapshot.documents.count == 0 {
                        return completionHandler([], "Data received are empty")
                    }
                    
                    var debtors = [DebtorObject]()
                    
                    //fetch data json to object of array and return array
                    snapshot.documents.forEach({ (document) in
                        if let debtor = DebtorObject().fromJSON(json: document.data()) {
                            debtors.append(debtor)
                        }
                    })
                    
                    return completionHandler(debtors, nil)
                })
            }
        }
    }
    
    func getDetailDebtor(with idDebtor: String, _ completion: @escaping(_ details: List<DetailDebtorObject>?, _ error: String?) -> Void) {
        refDebtor.document(idDebtor).collection("details").addSnapshotListener { (snapshot, error) in
            if let error = error {
                return completion(nil, error.localizedDescription)
            }
            
            let details = List<DetailDebtorObject>()
            
            guard let detailSnapshot = snapshot else {
                return completion(details, "Data snapshot is missing!")
            }
            
            let detailDocuments = detailSnapshot.documents
            
            if detailDocuments.count == 0 {
                return completion(details, nil)
            }
            
            detailDocuments.forEach({ (detailData) in
                if let detail = DetailDebtorObject().fromJSON(json: detailData.data()) {
                    details.append(detail)
                }
            })
            
            return completion(details, nil)
        }
    }
    
    func addDebtor(with debtor: DebtorObject, completionHandler: @escaping (_ error: String?) -> Void) {
        if UserManager.shared.isAnonymousLoggedIn() {
            
        } else {
            
            guard let idUser = Auth.auth().currentUser?.uid else {
                return completionHandler("Id of User was been missing")
            }
            
            let idDebtor = refDebtor.document().documentID
            debtor.id = idDebtor
            debtor.idUser = idUser
            
            guard let json = debtor.toJSON() else {
                return completionHandler("Convert to json has been failed!")
            }
            
            switch InternetManager.shared.status {
            case .notReachable, .unknown:
                refDebtor.document(idDebtor).setData(json, options: SetOptions.merge())
                return completionHandler(nil)
            default:
                refDebtor.document(idDebtor).setData(json, options: SetOptions.merge(), completion: { (error) in
                    return completionHandler(error?.localizedDescription)
                })
            }
        }
    }
    
    func editDebtor(with debtor:  DebtorObject, completionHandler: @escaping (_ error: String?) -> Void) {
        
        if UserManager.shared.isAnonymousLoggedIn() {
            
        } else {
            guard let id = debtor.id else {
                return completionHandler("Id of Debtor is missing!")
            }
            
            guard let json = debtor.toJSON() else {
                return completionHandler("Can not convert object to json!")
            }
            
            switch InternetManager.shared.status {
            case .notReachable, .unknown:
                refDebtor.document(id).updateData(json)
                return completionHandler(nil)
            default:
                refDebtor.document(id).updateData(json, completion: { (error) in
                    return completionHandler(error?.localizedDescription)
                })
            }
        }
    }
    
    func deleteDebtor(with id: String, completionHandler: @escaping (_ error: String?) -> Void) {
        if UserManager.shared.isAnonymousLoggedIn() {
            
        } else {
            refDebtor.document(id).delete(completion: { (error) in
                return completionHandler(error?.localizedDescription)
            })
        }
    }
    
    func addDetail(with debtor: DebtorObject, detail: DetailDebtorObject, completionHandler: @escaping (_ error: String?) -> Void) {
        if UserManager.shared.isAnonymousLoggedIn() {
            
        } else {
            
            guard let idDebtor = debtor.id else {
                return completionHandler("Debtor was been removed or not found")
            }
            
            let refDetail = refDebtor.document(idDebtor).collection("details")
            let idDetail = refDetail.document().documentID
            detail.id = idDetail
            
            let newTotalDebit = debtor.totalDebit + detail.debt
            
            guard let detailJson = detail.toJSON() else {
                return completionHandler("Can not convert object tot json")
            }
            
            switch InternetManager.shared.status {
            case .notReachable, .unknown:
                
                refDetail.document(idDetail).setData(detailJson, options: SetOptions.merge())
                refDebtor.document(idDebtor).setData(["totalDebit" : newTotalDebit], options: SetOptions.merge())
                return completionHandler(nil)
                
            default:
                
                let batch = Firestore.firestore().batch()
                
                batch.setData(detailJson, forDocument: refDetail.document(idDetail), options: SetOptions.merge())
                
                batch.setData(["totalDebit" : newTotalDebit], forDocument: refDebtor.document(idDebtor), options: SetOptions.merge())
                
                batch.commit(completion: { (error) in
                    return completionHandler(error?.localizedDescription)
                })
            }
            
        }
    }
    
    func deleteDetail(with debtor: DebtorObject, and detail: DetailDebtorObject, _ completionHandler: @escaping (_ error: String?) -> Void) {
        if UserManager.shared.isAnonymousLoggedIn() {
            
        } else {
            
            guard let idDebtor = debtor.id, let idDetail = detail.id else {
                return completionHandler("Debtor was been removed or not found")
            }
            
            let newTotalDebit = debtor.totalDebit - detail.debt
            
            switch InternetManager.shared.status {
            case .notReachable, .unknown:
                refDebtor.document(idDebtor).collection("details").document(idDetail).delete()
                refDebtor.document(idDebtor).setData(["totalDebit": newTotalDebit], options: SetOptions.merge())
                return completionHandler(nil)
            default:
                
                let batch = Firestore.firestore().batch()
                
                batch.deleteDocument(refDebtor.document(idDebtor).collection("details").document(idDetail))
                batch.setData(["totalDebit": newTotalDebit], forDocument: refDebtor.document(idDebtor), options: SetOptions.merge())
                
                batch.commit(completion: { (error) in
                    return completionHandler(error?.localizedDescription)
                })
            }
        }
    }
    
    func updateTotalDebit(with idDebtor: String, and totalDebit: Int) -> Void {
        if UserManager.shared.isAnonymousLoggedIn() {
            
        } else {
            refDebtor.document(idDebtor).updateData(["totalDebit": totalDebit])
        }
    }
    
    func syncData() {
        
    }
    
    
}
