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
    var totalDebit = 0
    
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
        
        loadDebtors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func loadDebtors() {
        
        if !self.refreshCtrl.isRefreshing {
            self.loading.showLoadingDialog(self)
        }
        
        DebtServices.shared.getDebtors { (debtors, error) in
            
            if self.loading.isAnimating {
                self.loading.stopAnimating()
            }
            
            if self.refreshCtrl.isRefreshing {
                self.refreshCtrl.endRefreshing()
            }
            
            if let err = error {
                self.showAlert(err, title: "Oops", buttons: nil)
            } else {
                if let debtors = debtors {
                    self.debtors = debtors
                    self.debtorsFilter = debtors
                    
                    self.totalDebit = 0
                    debtors.forEach({ (debtor) in
                        self.totalDebit += debtor.totalDebit 
                    })
                    
                    self.lblTotals.text = "Tổng số tiền nợ: \(self.totalDebit.toString())"
                    
                    self.tblDebtors.reloadData()
                    
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
        vc.title = "Thêm người nợ"
        vc.delegate = self
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

extension DebtsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DebtorCell", for: indexPath) as? DebtorCell else {
            return UITableViewCell()
        }
        
        cell.lblFullName.text = "\(self.debtorsFilter[indexPath.row].name ?? "Lê Anh Tuấn")"
        cell.lblDebit.text = "\(self.debtorsFilter[indexPath.row].totalDebit) VNĐ"
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
        
        vc.debtor = self.debtorsFilter[indexPath.row]
        
        self.txtSearchDebtor.resignFirstResponder()
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        guard let id = self.debtorsFilter[indexPath.row].id else {
            return nil
        }
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Xoá") { (rowAction, indexPath) in
            
            let vc = VerifyPasswordVC()
            vc.view.frame = self.view.frame
            vc.view.tag = 99
            vc.delegateDebtor = self
            vc.id = id
            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
            self.didMove(toParentViewController: vc)
            
            /*
             
            
            self.loading.showLoadingDialog(self)
            DebtServices.shared.deleteDebtor(with: id, completionHandler: { (error) in
                self.loading.stopAnimating()
                if let error = error {
                    self.showAlert(error, title: "Xoá thất bại", buttons: nil)
                }                
            })
 
             */
        }
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Sửa") { (rowAction, indexPath) in
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddDebtorVC") as? AddDebtorVC {
                vc.title = "Sửa người nợ"
                vc.debtor = self.debtorsFilter[indexPath.row]
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return [deleteAction, editAction]
    }
}

extension DebtsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let deb =  self.debtors.filter({ (debtor) -> Bool in
            return debtor.name?.lowercased().range(of: searchText.lowercased()) != nil
        })
        
        self.debtorsFilter = searchText.isEmpty ? self.debtors : deb
        self.tblDebtors.reloadData()
    }
}

extension DebtsVC: DebtorDelegate {
    func addDebtor(with debtor: DebtorObject, _ completed: @escaping (_ error: String?) -> Void) -> Void {
        DebtServices.shared.addDebtor(with: debtor) { (error) in
            completed(error)
        }
    }
    
    func editDebtor(with debtor: DebtorObject, _ completed: @escaping (_ error: String?) -> Void) -> Void {
        DebtServices.shared.editDebtor(with: debtor) { (error) in
            completed(error)
        }
    }
    
    func deleteDebtor(withId id: String, _ completed: @escaping (String?) -> Void) {
        DebtServices.shared.deleteDebtor(with: id) { (error) in
            completed(error)
        }
    }
}
