//
//  DebtorProtocol.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 12/14/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

protocol DebtorDelegate {
    func addDebtor(with debtor: DebtorObject, _ completed: @escaping (_ error: String?) -> Void) -> Void
    func editDebtor(with debtor: DebtorObject, _ completed: @escaping (_ error: String?) -> Void) -> Void
    func deleteDebtor(withId id: String, _ completed: @escaping (_ error: String?) -> Void) -> Void
}
