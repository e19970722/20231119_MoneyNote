//
//  ExpenseRatioTableViewCell.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/12/9.
//

import UIKit

class BalanceRatioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
