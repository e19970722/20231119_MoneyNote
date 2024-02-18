//
//  NoteTableViewCell.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/11/20.
//

import UIKit
import Combine

class NoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    
    let noteChanged = PassthroughSubject<String, Never>()
    var cancellables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.addTarget(self, action: #selector(noteDidChange), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func noteDidChange() {
        if let newNote = textField.text {
            noteChanged.send(newNote)
        }
    }
    
}
