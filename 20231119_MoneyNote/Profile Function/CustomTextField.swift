//
//  CustomTextField.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2024/1/28.
//

import UIKit

class CustomTextField: UITextField {
    
    private let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

    private let borderLayer = CALayer()
    private let outerLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        outerLayer.frame = self.bounds.insetBy(dx: -6, dy: -6)
        borderLayer.frame = self.bounds
    }
    
    private func setupUI() {
        outerLayer.frame = self.bounds.insetBy(dx: -6, dy: -6) // 外光暈效果
        outerLayer.borderWidth = 6
        outerLayer.cornerRadius = 10+6

        borderLayer.frame = self.bounds
        borderLayer.borderWidth = 2
        borderLayer.cornerRadius = 10

        self.layer.insertSublayer(outerLayer, at: 0)
        self.layer.insertSublayer(borderLayer, above: outerLayer)
        
        self.backgroundColor = .clear
        self.layer.masksToBounds = false
    }
    
    func normalState() {
        outerLayer.borderColor = UIColor.clear.cgColor
        borderLayer.borderColor = UIColor.darkGray.cgColor
    }
    
    func DidSelectState() {
        outerLayer.borderColor = UIColor.systemTeal.withAlphaComponent(0.3).cgColor
        borderLayer.borderColor = UIColor.systemTeal.cgColor
    }
    
    func showErrorState() {
        outerLayer.borderColor = UIColor.systemRed.withAlphaComponent(0.3).cgColor
        borderLayer.borderColor = UIColor.systemRed.cgColor
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
}
