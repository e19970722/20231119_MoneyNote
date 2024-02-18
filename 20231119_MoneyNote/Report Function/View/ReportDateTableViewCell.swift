//
//  ReportDateTableViewCell.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/12/9.
//

import UIKit
import Combine

class ReportDateTableViewCell: UITableViewCell {

    @IBOutlet weak var monthButton: UIButton!
    
    let monthChange = PassthroughSubject<String, Never>()
    var cancellables = Set<AnyCancellable>()
    
    var dateComponent = DateComponents()
    var currentMonth: Date = Date.now {
        didSet {
            self.monthButton.setTitle(monthFormatter(date: currentMonth), for: .normal)
            monthChange.send(monthFormatter(date: currentMonth))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.monthButton.setTitle(monthFormatter(date: currentMonth), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        dateComponent.month = 1
        if let addmonth = Calendar.current.date(byAdding: dateComponent, to: currentMonth) {
            currentMonth = addmonth
        }
    }
    
    @IBAction func preButtonTapped(_ sender: Any) {
        dateComponent.month = -1
        if let addmonth = Calendar.current.date(byAdding: dateComponent, to: currentMonth) {
            currentMonth = addmonth
        }
    }
    
    func monthFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        formatter.locale = Locale(identifier: "en_us")
        return formatter.string(from: date)
    }
    
}
