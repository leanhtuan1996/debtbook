//
//  DetailsDebtorCell.swift
//  DebtBook
//
//  Created by Lê Anh Tuấn on 11/15/17.
//  Copyright © 2017 Lê Anh Tuấn. All rights reserved.
//

import UIKit

class DetailsDebtorCell: UITableViewCell {

    @IBOutlet weak var lblDebt: UILabel!
    @IBOutlet weak var lblDateBorrow: UILabel!
    @IBOutlet weak var lblNumberOfTimesBorrowed: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
