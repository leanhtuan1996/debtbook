//
//  AuthenticationProtocol.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 12/15/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

protocol AuthenticationProtocol {
    func deleteDebtor(with id: String, _ completed: (_ error: String?) -> Void) -> Void
}
