//
//  AccountListTableViewCell.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/12/10.
//

import UIKit

class AccountListTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        dateLabel.text = nil
        categoryLabel.text = nil
        noteLabel.text = nil
        amountLabel.text = nil
        setLabelColor(isExpense: false)
    }
    
    func setLabelColor(isExpense: Bool) {
        if isExpense {
            amountLabel.textColor = .orange
        } else {
            amountLabel.textColor = .systemMint
        }
    }
    
}
