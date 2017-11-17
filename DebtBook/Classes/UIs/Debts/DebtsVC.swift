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
    var debtorsFilter: [DebtorObject] = []
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
        
        txtSearchDebtor.delegate = self
        
        self.navigationController?.navigationItem.leftBarButtonItem?.title = "Chỉnh sửa"
        
        let editButton = UIBarButtonItem(title: "Sửa", style: UIBarButtonItemStyle.done, target: self, action: #selector(editDebtorClicked))
        self.navigationItem.setLeftBarButton(editButton, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
                    self.debtorsFilter = debtors
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
        self.txtSearchDebtor.resignFirstResponder()
        navigationController?.pushViewController(vc, animated: true)
    }
    func editDebtorClicked() {
        self.txtSearchDebtor.resignFirstResponder()
        if self.tblDebtors.isEditing {
            self.tblDebtors.setEditing(false, animated: true)
            self.navigationItem.leftBarButtonItem?.title = "Sửa"
            
        } else {
            self.tblDebtors.setEditing(true, animated: true)
            self.navigationItem.leftBarButtonItem?.title = "Xong"
        }
    }
}

extension DebtsVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DebtorCell", for: indexPath) as? DebtorCell else {
            return UITableViewCell()
        }
        
        cell.lblFullName.text = "\(self.debtorsFilter[indexPath.row].name ?? "Lê Anh Tuấn")"
        cell.lblDebit.text = "\(self.debtorsFilter[indexPath.row].totalDebit ?? 0) VNĐ"
        cell.lblPhoneNumber.text = self.debtorsFilter[indexPath.row].phoneNumber ?? ""
        
        if let address = self.debtorsFilter[indexPath.row].address, let district = self.debtorsFilter[indexPath.row].district {
            cell.lblAddress.text = "\(address), \(district)"
        } else {
            cell.lblAddress.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debtorsFilter.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsDebtorVC") as? DetailsDebtorVC else {
            return
        }
        
        vc.idDebtor = self.debtorsFilter[indexPath.row].id
        self.txtSearchDebtor.resignFirstResponder()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Xoá") { (rowAction, indexPath) in
            self.loading.showLoadingDialog(self)
            DebtServices.shared.deleteDebtor(with: self.debtorsFilter[indexPath.row].id, completionHandler: { (error) in
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
                vc.idDebtor = self.debtorsFilter[indexPath.row].id
                vc.debtorEdit = self.debtorsFilter[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return [deleteAction, editAction]
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let deb =  self.debtors.filter({ (debtor) -> Bool in
            return debtor.name?.lowercased().range(of: searchText.lowercased()) != nil
        })
        
        self.debtorsFilter = searchText.isEmpty ? self.debtors : deb
        self.tblDebtors.reloadData()
    }
}
