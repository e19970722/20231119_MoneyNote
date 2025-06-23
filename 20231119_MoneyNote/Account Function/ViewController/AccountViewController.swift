//
//  ViewController.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/11/19.
//

import UIKit
import Combine

class AccountViewController: UIViewController {
    
    // MARK: - Public Properties
    var formCells: [FormCellType] = [.balanceRatio, .date, .datePicker, .note, .amount, .category]
        
    var isDatePickerHidden = true {
        didSet{
            self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        }
    }
    
    var loadingView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    let logoImageView: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var segmentControl: UISegmentedControl = {
        var segmentControl = UISegmentedControl(items: [AccountType.expense.labelName, AccountType.income.labelName])
        segmentControl.selectedSegmentIndex = 0
        segmentControl.sizeToFit()
        return segmentControl
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
        return tableView
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Expense", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        return button
    }()
    
    // MARK: - Private Properties
    private var viewModel = AccountViewModel()
    private let input: PassthroughSubject<AccountViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupUI()
        setupLoadingView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingView.isHidden = false
        input.send(.fetchItems)
        resetCell()
    }
    
    private func resetCell() {
        
        self.viewModel.selectDate = self.viewModel.getTodayString()
        self.viewModel.note = ""
        self.viewModel.amount = ""
        
        self.isDatePickerHidden = true
        tableView.reloadData()
    }
    
    private func bindViewModel() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchItemDidSucceed(let recordResponse):
                    self?.viewModel.calculateBalance(recordResponse: recordResponse)
                    self?.viewModel.records = recordResponse.records
                    self?.tableView.reloadData()
                    
                case .fetchItemDidFail(let error):
                    let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertVC.addAction(okAction)
                    self?.present(alertVC, animated: true)
                    
                case .changeAddButton(let expenseIncome):
                    switch expenseIncome {
                    case .expense:
                        self?.addButton.setTitle("Add Expense", for: .normal)
                        self?.addButton.backgroundColor = .orange
                    case .income:
                        self?.addButton.setTitle("Add Income", for: .normal)
                        self?.addButton.backgroundColor = .systemMint
                    default:
                        break
                        
                    }
                    
                case .uploadItemDidSucceed:
                    let alertVC = UIAlertController(title: "Success", message: "Record Added Successfully", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertVC.addAction(okAction)
                    self?.present(alertVC, animated: true)
                    
                    self?.input.send(.fetchItems)
                    self?.resetCell()
                    
                case .uploadItemDidFailed(let error):
                    let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertVC.addAction(okAction)
                    self?.present(alertVC, animated: true)
                    
                default:
                    break
                }
                
                self?.loadingView.isHidden = true
                
            }.store(in: &cancellables)
    }
    
    private func setupUI() {
        // Left Nav.: Logo
        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: logoImageView.frame.size.width, height: logoImageView.frame.size.height))
        leftContainer.addSubview(logoImageView)
        let leftBarButton = UIBarButtonItem(customView: leftContainer)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        // Center Nav.: Segment
        segmentControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        segmentControl.frame = CGRect(x: 0, y: 0, width: 80, height: 36)
        self.navigationItem.titleView = segmentControl
        
        // Right Nav.: List Button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(listButtonTapped))
        
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -36),
            addButton.heightAnchor.constraint(equalToConstant: 54),
        ])
        
        tableView.layoutIfNeeded()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16)
        ])
        
        addButton.layer.cornerRadius = 27
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        for formCell in formCells {
            tableView.register(UINib(nibName: "\(formCell.cellClass.self)", bundle: nil), forCellReuseIdentifier: "\(formCell.cellClass.self)")
        }
    }
    
    private func setupLoadingView() {
        
        loadingView = UIView(frame: self.view.bounds)
        loadingView.backgroundColor = UIColor(white: 1, alpha: 0.5)

        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = loadingView.center
        activityIndicator.startAnimating()
        
        loadingView.addSubview(activityIndicator)
        self.view.addSubview(loadingView)
        loadingView.isHidden = true
    }
    
    @objc private func addButtonTapped() {
        input.send(.addButtonTapped)
    }
    
    @objc private func segmentDidChange() {
        input.send(.segmentDidChange(selectedIndex: self.segmentControl.selectedSegmentIndex))
    }
    
    @objc private func listButtonTapped() {
        let accountRecordVC = AccountRecordViewController()
        self.navigationController?.pushViewController(accountRecordVC, animated: true)
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let formCell = formCells[indexPath.row]
        switch formCell {
        case .datePicker:
            if isDatePickerHidden {
                return 0
            } else {
                return 160
            }
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let formCell = formCells[indexPath.row]
        
        switch formCell {
            
        // 收支比
        case .balanceRatio:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(formCell.cellClass.self)", for: indexPath) as? BalanceRatioTableViewCell
            else { return UITableViewCell() }
            cell.balanceLabel.text = self.viewModel.balanceString
            cell.progressView.progress = self.viewModel.balanceRatio
            return cell
        
        // 日期
        case .date:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(formCell.cellClass.self)", for: indexPath) as? DateTableViewCell
            else { return UITableViewCell() }
            cell.cancellables.removeAll()
            cell.dateButton.setTitle(self.viewModel.selectDate, for: .normal)
            cell.dateButtonTapped
                .sink { [weak self] in
                    self?.isDatePickerHidden.toggle()
                }.store(in: &cell.cancellables)
            return cell
        
        // Date Picker
        case .datePicker:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(formCell.cellClass.self)", for: indexPath) as? DatePickerTableViewCell
            else { return UITableViewCell() }
            cell.cancellables.removeAll()
            cell.dateChange
                .sink { [weak self] selectDate in
                    self?.viewModel.selectDate = selectDate
                    self?.tableView.reloadData()
                }
                .store(in: &cell.cancellables)
            return cell
        
        // 輸入Note
        case .note:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(formCell.cellClass.self)", for: indexPath) as? NoteTableViewCell
            else { return UITableViewCell() }
            cell.cancellables.removeAll()
            cell.noteChanged
                .sink { [weak self] text in
                    self?.viewModel.note = text
                }
                .store(in: &cell.cancellables)
            cell.textField.text = self.viewModel.note
            return cell
        
        // 金額
        case .amount:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(formCell.cellClass.self)", for: indexPath) as? AmountTableViewCell
            else { return UITableViewCell() }
            cell.cancellables.removeAll()
            cell.amountChange
                .sink { [weak self] inputAmount in
                    self?.viewModel.amount = inputAmount
                    
                }
                .store(in: &cell.cancellables)
            cell.textField.text = self.viewModel.amount
            return cell
        
        // 分類
        case .category:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(formCell.cellClass.self)", for: indexPath) as? CategoryTableViewCell
            else { return UITableViewCell() }
            cell.cancellables.removeAll()
            cell.categoryChange
                .sink { [weak self] selectCategory in
                    self?.viewModel.category = selectCategory
                }
                .store(in: &cell.cancellables)
            return cell
        
        default:
            return UITableViewCell()
        }
    }
}
