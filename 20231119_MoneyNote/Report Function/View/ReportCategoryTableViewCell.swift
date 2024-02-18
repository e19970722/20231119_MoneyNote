//
//  ReportCategoryTableViewCell.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/12/4.
//

import UIKit

class ReportCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
