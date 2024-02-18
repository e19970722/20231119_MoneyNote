//
//  SignInUpViewController.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2024/1/28.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign In"
        label.font = .systemFont(ofSize: 36, weight: .heavy)
        return label
    }()
    
    private var stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 16
        return stackView
    }()
    
    private var accountTextField: CustomTextFieldView = {
        let textField = CustomTextFieldView()
        textField.placeholder = "Account ID"
        textField.hintLabel.text = "Please enter your ID"
        return textField
    }()
    
    private var passwordTextField: CustomTextFieldView = {
        let textField = CustomTextFieldView()
        textField.placeholder = "Password"
        textField.hintLabel.text = "Characters of <>?/!@#$%^&* are not allowed"
        textField.isNeedMask = true
        textField.isSelected = false
        textField.hintMessageColor = .systemRed
        return textField
    }()
    
    private var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 24
        button.titleLabel?.textColor = .white
        button.backgroundColor = .link
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 48),
            stackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        
        stackView.addArrangedSubview(accountTextField)
        stackView.addArrangedSubview(passwordTextField)
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            doneButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

}
