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
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if parent is AddDetailVC {
            self.loadDetailDebtor()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let addDetailItem = UIBarButtonItem(title: "Thêm mới", style: UIBarButtonItemStyle.done, target: self, action: #selector(addDetail))
        self.navigationItem.setRightBarButton(addDetailItem, animated: true)
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
    @IBAction func btnShowSettingsClicked(_ sender: Any) {
        let btnPayAllDebt = UIAlertAction(title: "Thanh toán toàn bộ số nợ", style: UIAlertActionStyle.default) { (action) in
            
        }
        
        let btnCancel = UIAlertAction(title: "Huỷ bỏ", style: UIAlertActionStyle.cancel, handler: nil)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(btnPayAllDebt)
        alert.addAction(btnCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addDetail() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "AddDetailVC") as? AddDetailVC else {
            return
        }
        vc.idDebtor = self.debtor?.id
        self.addChildViewController(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        self.didMove(toParentViewController: self)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 { return }
        
        guard let debtor = self.debtor, let details = debtor.detail else {
            return
        }
        
        guard let debt = details[indexPath.row - 1].debt, debt > 0 else {
            return
        }
        
        let btnPayThisDebt = UIAlertAction(title: "Thanh toán khoãng nợ này", style: UIAlertActionStyle.default) { (action) in
            
        }
        
        let btnEditThisDebt = UIAlertAction(title: "Chỉnh sửa khoãng nợ này", style: UIAlertActionStyle.default) { (action) in
            
        }
        
        let btnDeleteThisDebt = UIAlertAction(title: "Xoá khoãng nợ này", style: UIAlertActionStyle.destructive) { (action) in
            
        }
        
        let btnCancel = UIAlertAction(title: "Huỷ bỏ", style: UIAlertActionStyle.cancel, handler: nil)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(btnPayThisDebt)
        alert.addAction(btnEditThisDebt)
        alert.addAction(btnCancel)
        alert.addAction(btnDeleteThisDebt)
        
        self.present(alert, animated: true, completion: nil)
    }
}
