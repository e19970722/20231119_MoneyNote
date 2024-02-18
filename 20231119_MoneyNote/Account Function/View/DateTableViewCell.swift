//
//  DateTableViewCell.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/11/19.
//

import UIKit
import Combine

class DateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateButton: UIButton!
    
    let dateButtonTapped = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func dateButtonTappedAction(_ sender: Any) {
        dateButtonTapped.send(())
    }
    
}
