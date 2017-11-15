//
//  DebtsRouter.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/15/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit
import Alamofire

let baseUrl = "http://35.177.230.252:3000"

enum DebtsRouter: URLRequestConvertible {
    
    //Action
    case addDebt([String: Any])
    case editDebt([String: Any])
    case deleteDebt([String: Any])
    case getDebts()
    case getDebt([String: Any])
    case addDetailDebt([String: Any])
    case deleteDetailDebt([String: Any])
    
    //method
    var method: Alamofire.HTTPMethod {
        switch self {
        case .addDebt:
            return .post
        case .editDebt:
            return .post
        case .deleteDebt:
            return .post
        case .getDebts:
            return .get
        case .getDebt:
            return .get
        case .addDetailDebt:
            return .post
        case .deleteDetailDebt:
            return .post
        }
    }
    
    //path
    var path: String {
        switch self {
        case .addDebt:
            return "/add-debtor"
        case .editDebt:
            return "/update-debtor"
        case .deleteDebt:
            return "/delete-debtor"
        case .getDebts:
            return "/get-all-debtors"
        case .getDebt:
            return "/get-debtor"
        case .addDetailDebt:
            return "/add-detail"
        case .deleteDetailDebt:
            return "/delete-detail"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: baseUrl)!
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .addDebt(let parameters):
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
        case .editDebt(let parameters):
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
        case .deleteDebt(let parameters):
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
        case .getDebts():
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: [:])
        case .getDebt(let parameters):
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
        case .addDetailDebt(let parameters):
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
        case .deleteDetailDebt(let parameters):
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
        }
    }
}
