//
//  SelectDistrictsVC.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/16/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit

class SelectDistrictsVC: UIViewController {
    @IBOutlet weak var tblDistricts: UITableView!
    
    let district: [String] = ["Chantabuly", "Sikhottabong", "Xaysetha", "Sisattanak", "Hadxaifong", "Mayparkngum", "Naxaithong", "Sangthong", "Xaythany"]

    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.tblDistricts.register(UINib(nibName: "DistrictCell", bundle: nil), forCellReuseIdentifier: "DistrictCell")
        self.tblDistricts.delegate = self
        self.tblDistricts.dataSource = self
        
        self.title = "Chọn Quận/Huyện"
    }
}

extension SelectDistrictsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DistrictCell", for: indexPath) as? DistrictCell else {
            return UITableViewCell()
        }
        
        cell.lblNameDistrict.text = self.district[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.district.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.viewControllers.forEach({ (vc) in
            if let addDebt = vc as? AddDebtorVC {
                addDebt.btnDistrict.setTitle(self.district[indexPath.row], for: UIControlState.normal)
            }
        })
        
        self.navigationController?.popViewController(animated: true)
    }
}
