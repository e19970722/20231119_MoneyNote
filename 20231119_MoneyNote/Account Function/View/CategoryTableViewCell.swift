//
//  CategoryTableViewCell.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/11/20.
//

import UIKit
import Combine

class CategoryTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var categoryChange = PassthroughSubject<CategoryType, Never>()
    var cancellables = Set<AnyCancellable>()
    
    var categories: [CategoryType] = [.food, .salary, .clothes, .cosmetics, .exchange, .medical, .education, .electricBill, .transportation, .contactFee, .housingExpense, .editMore]
        
    var itemSelectedIndex: Int = 0 {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "\(CategoryCollectionViewCell.self)", bundle: nil),
                                forCellWithReuseIdentifier: "\(CategoryCollectionViewCell.self)")
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(CategoryCollectionViewCell.self)", for: indexPath) as? CategoryCollectionViewCell
        else { return UICollectionViewCell() }
        
        let item = categories[indexPath.item]
        cell.emojiLabel.text = item.iconName
        cell.titleLabel.text = item.categoryName
        
        if indexPath.item == itemSelectedIndex {
            cell.layer.borderColor = UIColor.black.cgColor
            cell.titleLabel.textColor = UIColor.black
            cell.emojiLabel.alpha = 1
        }
        else {
            cell.layer.borderColor = CGColor(red: 183/255, green: 183/255, blue: 183/255, alpha: 1)
            cell.titleLabel.textColor = UIColor.lightGray
            cell.emojiLabel.alpha = 0.3
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.titleLabel.textColor = UIColor.black
        
        itemSelectedIndex = indexPath.item
        
        categoryChange.send(categories[itemSelectedIndex])
        
        
    }
    
    //設定Cell樣式
    //左右
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    //上下
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width-2*8)/3,
                      height: collectionView.frame.size.width/3*0.6)
    }
}
