//
//  CustomTextFieldView.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2024/1/28.
//

import UIKit
import Combine

class CustomTextFieldView: UIView {
    
    enum textFieldStateType {
        case normal
        case didSelect
        case error
    }
    
    var textFieldState = CurrentValueSubject<textFieldStateType, Never>(.normal)
    var cancellable = Set<AnyCancellable>()
    
    var hintMessage: String? {
        didSet {
            hintLabel.text = hintMessage
        }
    }
    
    var hintMessageColor: UIColor? {
        didSet {
            hintLabel.textColor = hintMessageColor
        }
    }
    
    var placeholder: String? {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    var isNeedMask: Bool = false {
        didSet {
            textField.isSecureTextEntry = isNeedMask
        }
    }
    
    var isSelected: Bool = true {
        didSet {
        }
    }
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        return stackView
    }()
    
    var hintLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .light)
        return label
    }()
    
    var textField: CustomTextField = {
        let textField = CustomTextField()
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 10
        return textField
    }()
    
    init() {
        super.init(frame: .zero)
        setupCustomView()
        
        textFieldState.sink { [weak self] status in
            switch status {
            case .normal:
                self?.textField.normalState()
            case .didSelect:
                self?.textField.DidSelectState()
            case .error:
                self?.textField.showErrorState()
            }
        }.store(in: &cancellable)
        
        // Normal
        NotificationCenter
            .default
            .publisher(for: UITextField.textDidEndEditingNotification, object: textField)
            .sink { [weak self] text in
                self?.textFieldState.send(.normal)
            }.store(in: &cancellable)
        
        // Did Select
        NotificationCenter
            .default
            .publisher(for: UITextField.textDidBeginEditingNotification, object: textField)
            .sink { [weak self] text in
                self?.textFieldState.send(.didSelect)
            }.store(in: &cancellable)
        
        // Error: Check Regex
        NotificationCenter
            .default
            .publisher(for: UITextField.textDidChangeNotification, object: textField)
            .compactMap({ ($0.object as? UITextField)?.text })
            .sink { [weak self] text in
                if text.contains("@") {
                    self?.textFieldState.send(.error)
                    print("*** \(text)")
                }
            }.store(in: &cancellable)
        

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCustomView() {
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        stackView.addArrangedSubview(hintLabel)
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
    
}
