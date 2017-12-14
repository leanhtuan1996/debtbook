//
//  DetailDebtorProtocol.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 12/14/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

protocol DetailDebtorDelegate {
    func addDetail(with detail: DetailDebtorObject) -> Void
    func deleteDetail(withId id: String, _ completed: @escaping(_ error: String?) -> Void) -> Void
}
