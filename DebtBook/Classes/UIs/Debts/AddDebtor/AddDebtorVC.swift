//
//  AddDebtorTVC.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/16/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit

class AddDebtorVC: UITableViewController {

    @IBOutlet weak var txtFirstDebit: UITextField!
    @IBOutlet weak var btnDistrict: UIButton!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtName: UITextField!
    
    var isEditDebtor = false
    var idDebtor: Int?
    var debtorEdit: DebtorObject?
    var loading = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtName.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        self.btnDistrict.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        self.txtAddress.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        self.txtPhoneNumber.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        self.txtFirstDebit.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        
        txtName.becomeFirstResponder()
        
        self.automaticallyAdjustsScrollViewInsets = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let doneButton = UIBarButtonItem(title: "Xong", style: UIBarButtonItemStyle.done, target: self, action: #selector(done))
        self.navigationItem.setRightBarButton(doneButton, animated: true)
        
        if let debtor = self.debtorEdit {
            self.txtName.text = debtor.name
            self.txtPhoneNumber.text = debtor.phoneNumber
            self.txtAddress.text = debtor.address
            self.btnDistrict.setTitle(debtor.district, for: UIControlState.normal)
            self.txtFirstDebit.text = debtor.firstDebit?.toString()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 2 { return 2 }
        else { return 1 }
    }
    
    func done() {
        if !self.txtName.hasText {
            self.showAlert("Tên người nợ chưa có", title: "Vui lòng nhập vào tên người nợ", buttons: nil)
            return
        }
        
        if !self.txtPhoneNumber.hasText {
            self.showAlert("Số điện thoại không được rỗng", title: "Vui lòng nhập vào số điện thoại", buttons: nil)
            return
        }
        
        if !self.txtAddress.hasText {
            self.showAlert("Địa chỉ không được để trống", title: "Vui lòng nhập vào địa chỉ người nợ", buttons: nil)
            return
        }
        
        guard let district = btnDistrict.currentTitle, district != "Quận/Huyện" else {
            self.showAlert("Quận/Huyện chưa được chọn", title: "Hãy chọn Quận/Huyện của người nợ", buttons: nil)
            return
        }
        
        if !self.txtFirstDebit.hasText {
            self.showAlert("Số nợ chưa được thêm vào", title: "Vui lòng nhập vào số tiền nợ", buttons: nil)
            return
        }
        
        guard let fullName = self.txtName.text, let address = self.txtAddress.text, let debit = self.txtFirstDebit.text, let phoneNumber = self.txtPhoneNumber.text else {
            return
        }
        
        if !phoneNumber.isInt() {
            self.showAlert("Hãy nhập lại số điện thoại", title: "Số điện thoại không hợp lệ", buttons: nil)
            return
        }
        
        if !debit.isInt() {
            self.showAlert("Hãy nhập lại số nợ bằng số", title:"Số tiền nợ không hợp lệ" , buttons: nil)
            return
        }
        
        let debtorObject = DebtorObject()
        
        debtorObject.name = fullName
        debtorObject.phoneNumber = phoneNumber
        debtorObject.address = address
        debtorObject.district = district
        debtorObject.firstDebit = debit.toInt()
        
        if self.isEditDebtor { //edit
            
            //for editing
            guard let id = self.idDebtor else {
                self.showAlert("Mã người nợ không được rỗng", title: "Sửa thất bại", buttons: nil)
                return
            }
            
            debtorObject.id = id
            
            loading.showLoadingDialog(self)
            
            DebtServices.shared.editDebtor(with: debtorObject, completionHandler: { (debtor, error) in
                self.loading.stopAnimating()
                if let error = error {
                    self.showAlert(error, title: "Sửa thất bại", buttons: nil)
                }
                self.navigationController?.popViewController(animated: true)
            })
            
            
        } else {
            //add
            loading.showLoadingDialog(self)
            DebtServices.shared.addDebtor(with: debtorObject) { (debtor, error) in
                self.loading.stopAnimating()
                if let error = error {
                    self.showAlert(error, title: "Thêm người nợ không thành công", buttons: nil)
                } else {
                    let backButton = UIAlertAction(title: "Trở về", style: UIAlertActionStyle.default, handler: { (alert) in
                        
                        if let vc = self.navigationController?.viewControllers[0] as? DebtsVC {
                            vc.loadDebtors()
                        }
                        
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                    let continuesButton = UIAlertAction(title: "Thêm tiếp", style: UIAlertActionStyle.default, handler: { (alert) in
                        self.txtName.becomeFirstResponder()
                        self.txtName.text = ""
                        self.txtPhoneNumber.text = ""
                        self.txtAddress.text = ""
                        self.btnDistrict.setTitle("Quận/Huyện", for: UIControlState.normal)
                    })
                    
                    self.showAlert("Có muốn tiếp tục thêm người nợ không?", title: "Thêm nợ thành công", buttons: [backButton, continuesButton])
                }
            }
        }
    }

    @IBAction func btnSelectDistrictClicked(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SelectDistrictsVC") as? SelectDistrictsVC else {
            return
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
