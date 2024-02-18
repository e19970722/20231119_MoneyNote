//
//  ExpenseTableViewCell.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/11/20.
//

import UIKit
import Combine

class AmountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    
    var amountChange = PassthroughSubject<String, Never>()
    var cancellables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func textFieldDidChange() {
        if let inputText = textField.text {
            amountChange.send(inputText)
        }
    }
}
