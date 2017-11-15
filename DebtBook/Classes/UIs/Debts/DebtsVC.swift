//
//  DebtsVC.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/15/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit

class DebtsVC: UIViewController {

    @IBOutlet weak var txtSearchDebtor: UISearchBar!
    @IBOutlet weak var tblDebtors: UITableView!
    @IBOutlet weak var lblTotals: UILabel!
    
    var debtors: [DebtorObject] = []
    var loading = UIActivityIndicatorView()
    
    var refreshCtrl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //refreshing for table view
        refreshCtrl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        
        tblDebtors.register(UINib(nibName: "DebtorCell", bundle: nil), forCellReuseIdentifier: "DebtorCell")
        tblDebtors.delegate = self
        tblDebtors.dataSource = self
        tblDebtors.refreshControl = refreshCtrl
        tblDebtors.estimatedRowHeight = 65
        
        
        //loading debtors
        loadDebtors()
    }
    
    func loadDebtors() {
        
        if !self.refreshCtrl.isRefreshing {
            self.loading.showLoadingDialog(self)
        }
        
        DebtServices.shared.getDebtors { (debtors, error) in
            self.loading.stopAnimating()
            
            if self.refreshCtrl.isRefreshing {
                self.refreshCtrl.endRefreshing()
            }
            
            if let err = error {
                self.showAlert(err, title: "Oops", buttons: nil)
            } else {
                if let debtors = debtors {
                    self.debtors = debtors
                    self.tblDebtors.reloadData()
                    
                    var totalDepts = 0
                    debtors.forEach({ (debtor) in
                        totalDepts += debtor.totalDebit ?? 0
                    })
                    
                    self.lblTotals.text = "Total debts: \(totalDepts.toString())"
                    
                } else {
                   self.showAlert("Debtors not found", title: "Oops", buttons: nil)
                }
            }
        }
    }
    
    func refresh() {
        self.refreshCtrl.beginRefreshing()
        self.loadDebtors()
    }
    
    
    @IBAction func btnAddDebtorClicked(_ sender: Any) {
    }
    @IBAction func btnEditDebtorClicked(_ sender: Any) {
    }
}

extension DebtsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DebtorCell", for: indexPath) as? DebtorCell else {
            return UITableViewCell()
        }
        
        cell.lblFullName.text = "\(self.debtors[indexPath.row].name ?? "Lê Anh Tuấn")"
        cell.lblDebit.text = "\(self.debtors[indexPath.row].totalDebit ?? 0) VNĐ"
        
        if let address = self.debtors[indexPath.row].address, let district = self.debtors[indexPath.row].district {
            cell.lblAddress.text = "\(address), \(district)"
        } else {
            cell.lblAddress.text = ""
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debtors.count
    }
}
