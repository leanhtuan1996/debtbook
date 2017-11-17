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
        tblDebtors.estimatedRowHeight = 80
        
        self.navigationController?.navigationItem.leftBarButtonItem?.title = "Chỉnh sửa"
        
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
                    
                    self.lblTotals.text = "Tổng số tiền nợ: \(totalDepts.toString())"
                    
                } else {
                   self.showAlert("Người nợ không tìm thấy", title: "Oops", buttons: nil)
                }
            }
        }
    }
    
    func refresh() {
        self.refreshCtrl.beginRefreshing()
        self.loadDebtors()
    }
    
    
    @IBAction func btnAddDebtorClicked(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "AddDebtorVC") as? AddDebtorVC else {
            return
        }
        vc.isEditDebtor = false
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnEditDebtorClicked(_ sender: Any) {
        if self.tblDebtors.isEditing {
            self.tblDebtors.setEditing(false, animated: true)
            
        } else {
            self.tblDebtors.setEditing(true, animated: true)
        }
    }
}

extension DebtsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DebtorCell", for: indexPath) as? DebtorCell else {
            return UITableViewCell()
        }
        
        cell.lblFullName.text = "\(self.debtors[indexPath.row].name ?? "Lê Anh Tuấn")"
        cell.lblDebit.text = "\(self.debtors[indexPath.row].totalDebit ?? 0) VNĐ"
        cell.lblPhoneNumber.text = self.debtors[indexPath.row].phoneNumber ?? ""
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsDebtorVC") as? DetailsDebtorVC else {
            return
        }
        
        vc.idDebtor = self.debtors[indexPath.row].id
                
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Xoá") { (rowAction, indexPath) in
            self.loading.showLoadingDialog(self)
            DebtServices.shared.deleteDebtor(with: self.debtors[indexPath.row].id, completionHandler: { (error) in
                self.loading.stopAnimating()
                if let error = error {
                    self.showAlert(error, title: "Xoá thất bại", buttons: nil)
                }
            })
        }
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Sửa") { (rowAction, indexPath) in
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddDebtorVC") as? AddDebtorVC {
                vc.title = "Sửa người nợ"
                vc.isEditDebtor = true
                vc.idDebtor = self.debtors[indexPath.row].id
                vc.debtorEdit = self.debtors[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        return [deleteAction, editAction]
    }
}
