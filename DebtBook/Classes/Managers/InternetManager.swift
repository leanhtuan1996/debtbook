//
//  InternetManager.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 12/13/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit
import Alamofire

enum NetworkStatus: String {
    case unknown = "unknown"
    case notReachable = "notReachable"
    case reachable = "reachable"
}

class InternetManager: NSObject {
    
    static let shared = InternetManager()
    
    var status = NetworkStatus.unknown
    
    let manager = NetworkReachabilityManager(host: "www.google.com")
    
    func listen() {
        //check network
        manager?.listener = { status in
            
            switch status {
            case .notReachable:
                self.status = .notReachable
            case .reachable(NetworkReachabilityManager.ConnectionType.ethernetOrWiFi):
                self.status = .reachable
            default:
                self.status = .unknown
            }
            
            print(self.status.rawValue)
            
        }
        manager?.startListening()
    }
    
}
