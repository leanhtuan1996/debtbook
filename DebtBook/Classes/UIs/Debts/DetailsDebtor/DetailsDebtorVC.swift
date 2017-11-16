//
//  DetailsDebtorVC.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/15/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit

class DetailsDebtorVC: UIViewController {

    @IBOutlet weak var tblDetailDebtors: UITableView!
    @IBOutlet weak var lblTotalDebts: UILabel!
    
    var debtor: DebtorObject?
    var loading = UIActivityIndicatorView()
    var idDebtor: Int?
    var checkBorrow = 1
    var checkPayment = 0
    var refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresh.addTarget(self, action: #selector(refreshing), for: UIControlEvents.valueChanged)
        
        self.tblDetailDebtors.delegate = self
        self.tblDetailDebtors.dataSource = self
        self.tblDetailDebtors.estimatedRowHeight = 70
        self.tblDetailDebtors.register(UINib(nibName: "DetailsDebtorCell", bundle: nil), forCellReuseIdentifier: "DetailsDebtorCell")
        self.tblDetailDebtors.refreshControl = self.refresh
        
        self.loadDetailDebtor()
    }
    
    func loadDetailDebtor() {
        
        if !self.refresh.isRefreshing {
            self.loading.showLoadingDialog(self)
        }
        
        guard let id = self.idDebtor else {
            return
        }
        
        DebtServices.shared.getDebtor(with: id) { (debtor, error) in
            self.loading.stopAnimating()
            
            if self.refresh.isRefreshing {
                self.refresh.endRefreshing()
            }
            
            if let error = error {
                self.showAlert(error, title: "Oops", buttons: nil)
            } else {
                self.debtor = debtor
                self.navigationItem.title = self.debtor?.name ?? ""
                self.tblDetailDebtors.reloadData()
                
                var total = debtor?.firstDebit ?? 0
                
                if let details = debtor?.detail {
                    details.forEach({ (detail) in
                        total += detail.debt ?? 0
                    })
                }
                
                self.lblTotalDebts.text = "Tổng số tiền nợ: \(total.toString())"
                
                self.checkBorrow = 1
                self.checkPayment = 0
                
            }
        }
    }
    
    func refreshing() {
        self.refresh.beginRefreshing()
        self.loadDetailDebtor()
    }

}

extension DetailsDebtorVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsDebtorCell", for: indexPath) as? DetailsDebtorCell, let debtor = self.debtor, let detail = debtor.detail else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            if let firstDebt = self.debtor?.firstDebit, let dateBorrow = self.debtor?.dateCreated {
                cell.lblDebt.text = firstDebt.toString()
                cell.lblDateBorrow.text = dateBorrow.jsonDateToDate()
                cell.lblNumberOfTimesBorrowed.text = "Lần mượn đầu tiên"
            }
        } else {
            if let debt = detail[indexPath.row - 1].debt, debt <= 0 {
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\((debt * (-1)).toString())")
                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
                cell.lblDebt.attributedText = attributeString
                self.checkPayment += 1
                cell.lblNumberOfTimesBorrowed.text = "Lần trả thứ \(self.checkPayment)"
            } else {
                self.checkBorrow += 1
                cell.lblDebt.text = detail[indexPath.row - 1].debt?.toString() ?? "0"
                cell.lblNumberOfTimesBorrowed.text = "Lần mượn thứ \(self.checkBorrow)"
            }
            
            cell.lblDateBorrow.text = detail[indexPath.row - 1].borrowedDay?.jsonDateToDate() ?? "Không rõ"
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (debtor?.detail?.count ?? 0) + 1
    }
}
