//
//  DetailsDebtorVC.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/15/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit
import RealmSwift

class DetailsDebtorVC: UIViewController {
    
    @IBOutlet weak var tblDetailDebtors: UITableView!
    @IBOutlet weak var lblTotalDebts: UILabel!
    
    var debtor: DebtorObject?
    var loading = UIActivityIndicatorView()
    var checkBorrow = 1
    var checkPayment = 0
    var refresh = UIRefreshControl()
    let notification = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresh.addTarget(self, action: #selector(refreshing), for: UIControlEvents.valueChanged)
        
        self.tblDetailDebtors.delegate = self
        self.tblDetailDebtors.dataSource = self
        self.tblDetailDebtors.estimatedRowHeight = 70
        self.tblDetailDebtors.register(UINib(nibName: "DetailsDebtorCell", bundle: nil), forCellReuseIdentifier: "DetailsDebtorCell")
        self.tblDetailDebtors.refreshControl = self.refresh       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let addDetailItem = UIBarButtonItem(title: "Thêm mới", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.showDetailDialog))
        self.navigationItem.setRightBarButton(addDetailItem, animated: true)
        self.loadDetailDebtor()
    }
    
    func loadDetailDebtor() {
        
        if !self.refresh.isRefreshing {
            self.loading.showLoadingDialog(self)
        }
        
        guard let id = self.debtor?.id else {
            return
        }
        
        DebtServices.shared.getDetailDebtor(with: id) { (details, error) in
            if self.loading.isAnimating {
                self.loading.stopAnimating()
            }
            
            if self.refresh.isRefreshing {
                self.refresh.endRefreshing()
            }
            
            if let error = error {
                self.showAlert(error, title: "Whoops", buttons: nil)
                return
            }
            
            self.debtor?.detail = details ?? List<DetailDebtorObject>()
            
            var totalDebit = self.debtor?.firstDebit ?? 0
            
            self.debtor?.detail.forEach({ (detail) in
                totalDebit += detail.debt
            })
            
            DispatchQueue.main.async {
                self.tblDetailDebtors.reloadData()
                self.lblTotalDebts.text = "Tổng số tiền nợ: \(totalDebit)"
            }            
            
            self.checkBorrow = 1
            self.checkPayment = 0
        }
    }
    
    func refreshing() {
        self.refresh.beginRefreshing()
        self.loadDetailDebtor()
    }
    
    @IBAction func btnShowSettingsClicked(_ sender: Any) {
        
        guard let debtor = self.debtor else {
            return
        }
        
        let btnPayAllDebt = UIAlertAction(title: "Thanh toán toàn bộ số nợ", style: UIAlertActionStyle.default) { (action) in
            if debtor.totalDebit == 0 {
                return
            }
            
            let detail = DetailDebtorObject()
            detail.dateCreated = Date().timeIntervalSince1970.toInt()
            
            if debtor.totalDebit > 0 {
                detail.debt = debtor.totalDebit * (-1)
            }
            
            self.addDetail(with: detail)
        }
        
        let btnCancel = UIAlertAction(title: "Huỷ bỏ", style: UIAlertActionStyle.destructive, handler: nil)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(btnPayAllDebt)
        alert.addAction(btnCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDetailDialog() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "AddDetailVC") as? AddDetailVC else {
            return
        }
        
        vc.delegate = self
        self.addChildViewController(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        self.didMove(toParentViewController: self)
    }
}

extension DetailsDebtorVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsDebtorCell", for: indexPath) as? DetailsDebtorCell, let debtor = self.debtor else {
            return UITableViewCell()
        }
        
        let detail = Array(debtor.detail)
        
        if indexPath.row == 0 {
            if let firstDebt = self.debtor?.firstDebit, let dateBorrow = self.debtor?.dateCreated {
                cell.lblDebt.text = firstDebt.toString()
                cell.lblDateBorrow.text = dateBorrow.toTimestampString()
                cell.lblNumberOfTimesBorrowed.text = "Lần mượn đầu tiên"
            }
        } else {
            let debt = detail[indexPath.row - 1].debt
            if debt <= 0 {
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\((debt * (-1)).toString())")
                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
                cell.lblDebt.attributedText = attributeString
                self.checkPayment += 1
                cell.lblNumberOfTimesBorrowed.text = "Lần trả thứ \(self.checkPayment)"
            } else {
                self.checkBorrow += 1
                cell.lblDebt.text = detail[indexPath.row - 1].debt.toString()
                cell.lblNumberOfTimesBorrowed.text = "Lần mượn thứ \(self.checkBorrow)"
            }
            
            cell.lblDateBorrow.text = detail[indexPath.row - 1].dateCreated.toTimestampString()
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.debtor?.detail.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let debtor = self.debtor else {
            return
        }
        
        let btnPayThisDebt = UIAlertAction(title: "Thanh toán khoãng nợ này", style: UIAlertActionStyle.default) { (action) in
            
            var debit = 0
            
            if indexPath.row == 0 {
                debit = debtor.firstDebit
            } else {
                debit = debtor.detail[indexPath.row - 1].debt
            }
            
            if debit == 0 { return }
            
            debit *= (-1)
            
            self.loading.showLoadingDialog(self)
            
            let detail = DetailDebtorObject()
            detail.debt = debit
            detail.dateCreated = Date().timeIntervalSince1970.toInt()
            
            self.addDetail(with: detail)
            
            /*
            DebtServices.shared.addDetail(withid: id, detail: detail, completionHandler: { (error) in
                self.loading.stopAnimating()
                if let error = error {
                    self.showAlert(error, title: "Thanh toán thất bại", buttons: nil)
                }
                self.dismiss(animated: true, completion: nil)
            })
 */
        }
        
        let btnDeleteThisDebt = UIAlertAction(title: "Xoá khoãng tiền này", style: UIAlertActionStyle.destructive) { (action) in
            
            guard let idDetail = debtor.detail[indexPath.row - 1].id else {
                return
            }
            
            let vc = VerifyPasswordVC()
            vc.view.frame = self.view.frame
            vc.delegateDetailDebtor = self
            vc.id = idDetail
            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
            self.didMove(toParentViewController: vc)
            /*
            self.loading.showLoadingDialog(self)
            DebtServices.shared.deleteDetail(withIdDebtor: id, andIdDetail: idDetail, { (error) in
                self.loading.stopAnimating()
                if let error = error {
                    self.showAlert(error, title: "Xoá không thành công", buttons: nil)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            })
            */
            
        }
        
        let btnCancel = UIAlertAction(title: "Huỷ bỏ", style: UIAlertActionStyle.destructive, handler: nil)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        var debt = 0
        
        if indexPath.row == 0 {
            debt = self.debtor?.firstDebit ?? 0
            alert.addAction(btnPayThisDebt)
        } else {
            let currentDebt = debtor.detail[indexPath.row - 1].debt
            if currentDebt > 0 {
                alert.addAction(btnPayThisDebt)
            }
            debt = currentDebt
            alert.addAction(btnDeleteThisDebt)
        }
        
        alert.addAction(btnCancel)
        
        if debt == 0 { return }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        guard let debtor = self.debtor else {
            return nil
        }
        
        if indexPath.row == 0 { return nil }
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Xoá") { (rowAction, indexPath) in
            if indexPath.row == 0 { return }
            
            guard let idDetail = debtor.detail[indexPath.row - 1].id else {
                return
            }
            
            let vc = VerifyPasswordVC()
            vc.view.frame = self.view.frame
            vc.delegateDetailDebtor = self
            vc.id = idDetail
            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
            self.didMove(toParentViewController: vc)
            
        }
        return [deleteAction]
    }
}

extension DetailsDebtorVC: DetailDebtorDelegate {
    func addDetail(with detail: DetailDebtorObject) -> Void {
        
        guard let debtor = self.debtor else {
            return
        }
        
        self.loading.showLoadingDialog(self)
        DebtServices.shared.addDetail(with: debtor, detail: detail) { (error) in
            self.loading.stopAnimating()
            if let error = error {
                self.showAlert(error, title: "Thao tác thất bại", buttons: nil)
                return
            }
            self.debtor?.totalDebit += detail.debt
            
            self.notification.post(name: NSNotification.Name(rawValue: "updateTotalDebit"), object: self, userInfo: ["totalDebit": self.debtor?.totalDebit ?? 0, "id" : debtor.id ?? ""])
        }
    }
    
    func deleteDetail(withId id: String, _ completed: @escaping(_ error: String?) -> Void) -> Void {
        guard let debtor = self.debtor else {
            return completed("Debtor were been removed or not found")
        }
        
        
        //get detailObject with id
        let detailDebtorObject: DetailDebtorObject? = debtor.detail.elements.first { (detailDebtor) -> Bool in
            guard let idDetail = detailDebtor.id else {
                return false
            }
            
            return idDetail == id
        }
        
        guard let detailDebtor = detailDebtorObject else {
            return completed("Details of Debtor were been removed or not found")
        }
        
        DebtServices.shared.deleteDetail(with: debtor, and: detailDebtor) { (error) in
            
            if error == nil {
                self.debtor?.totalDebit -= detailDebtor.debt
                self.notification.post(name: NSNotification.Name(rawValue: "updateTotalDebit"), object: self, userInfo: ["totalDebit": self.debtor?.totalDebit ?? 0, "id" : debtor.id ?? ""])
                
                return completed(nil)
            }
            
            return completed(error)
        }
    }
}
