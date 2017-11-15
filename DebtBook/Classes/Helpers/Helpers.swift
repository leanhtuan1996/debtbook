//
//  Helpers.swift
//  ELearning
//
//  Created by Lê Anh Tuấn on 9/29/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit

class Helpers: NSObject {
    static func validateEmail(_ candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    static func convertObjectToJson(_ object: Any) -> [String: Any]? {
        do {
            //Convert to Data
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            //Convert back to string. Usually only do this for debugging
            //if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
            //print(JSONString)
            //}
            
            return try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
        } catch {
            return nil
        }
    }
    
    static func emptyMessage(_ activityIndicatorView:UIActivityIndicatorView, tableView:UITableView) {
        
        //let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = UIColor.white
        //tableView.view.addSubview(activityIndicatorView)
        tableView.backgroundView = activityIndicatorView
        activityIndicatorView.frame = tableView.frame
        activityIndicatorView.center = tableView.center
        activityIndicatorView.backgroundColor = UIColor.clear.withAlphaComponent(0.3)
        activityIndicatorView.sizeToFit()
        activityIndicatorView.startAnimating()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    //Handled Error
    static func handleError(_ response: HTTPURLResponse?, error: NSError) -> String {
        
        guard let res = response else {
            return "Server not response"
        }
        
        if error.isNoInternetConnectionError() {
            print("Internet Connection Error")
            return "Internet Connection Error"
        } else if error.isRequestTimeOutError() {
            print("Request TimeOut")
            return "Request TimeOut"
        } else if res.isServerNotFound() {
            print("Server not found")
            return "Server not found"
        } else if res.isInternalError() {
            print("Internal Error")
            return "Internal Error"
        }
        return "Error Not Found"
    }
    
    static func getDucumentDirectory() -> URL {
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return path[0]
    }
}
