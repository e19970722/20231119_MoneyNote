//
//  CategoryCollectionViewCell.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/11/26.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = CGColor(red: 183/255, green: 183/255, blue: 183/255, alpha: 1)
        self.layer.cornerRadius = 8
        
        emojiLabel.alpha = 0.3
        
    }
    
}
