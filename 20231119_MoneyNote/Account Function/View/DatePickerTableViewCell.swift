//
//  DatePickerTableViewCell.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/11/21.
//

import UIKit
import Combine

class DatePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    let dateChange = PassthroughSubject<String, Never>()
    var cancellables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        datePicker.addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func dateDidChange() {
        let selectedDate = datePicker.date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd EEE"
        formatter.locale = Locale(identifier: "en_us")
        let dateString = formatter.string(from: selectedDate)
        dateChange.send(dateString)
    }
}
