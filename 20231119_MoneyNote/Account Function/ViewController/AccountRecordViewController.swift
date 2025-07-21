//
//  AccountRecordViewController.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/12/30.
//

import UIKit
import Combine

class AccountRecordViewController: UIViewController {
    
    // MARK: - Public Properties
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
        return tableView
    }()
        
    var segmentControl: UISegmentedControl = {
        var segmentControl = UISegmentedControl(items: [AccountType.all.labelName,
                                                        AccountType.expense.labelName,
                                                        AccountType.income.labelName])
        segmentControl.selectedSegmentIndex = 0
        return segmentControl
    }()
    
    let searchBar: UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        return searchBar
    }()
    
    var loadingView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    // MARK: - Private Properties
    private let viewModel = AccountRecordViewModel()
    private let input: PassthroughSubject<AccountRecordViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLoadingView()
        bindViewModel()
        segmentControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingView.isHidden = false
        self.segmentControl.selectedSegmentIndex = 0
        input.send(.fetchItems)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        segmentControl.frame = CGRect(x: 0, y: 0, width: 80, height: 36)
        self.navigationItem.titleView = segmentControl
        
        self.tableView.tableHeaderView = searchBar
        self.tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64)
        
        tableView.register(UINib(nibName: "\(AccountListTableViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(AccountListTableViewCell.self)")
        tableView.allowsSelection = false
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
    
    private func bindViewModel() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                
                switch event {
                case .fetchItemDidSucceed:
                    self?.tableView.reloadData()
                    
                case .fetchItemDidFail(let error):
                    self?.showAlert(title: "Error",
                                    message: error.localizedDescription,
                                    confirmTitle: "OK",
                                    cancelTitle: nil)
                    
                case .itemsDidFilter(let filterRecord):
                    self?.viewModel.filteredRecords = filterRecord
                    self?.tableView.reloadData()
                
                case .deleteItemDidSucceed:
                    self?.showAlert(title: "Success",
                                    message: "Record Delete Successfully",
                                    confirmTitle: "OK",
                                    cancelTitle: nil)
                    
                    self?.input.send(.fetchItems)
                    
                case .deleteItemDidFailed(let error):
                    self?.showAlert(title: "Error",
                                    message: error.localizedDescription,
                                    confirmTitle: "OK",
                                    cancelTitle: nil)
                default:
                    break
                }
                
                self?.loadingView.isHidden = true
            }
            .store(in: &cancellables)
        
        NotificationCenter
            .default
            .publisher(for: UITextField.textDidChangeNotification, object: searchBar.searchTextField)
            .compactMap { notification in
                (notification.object as? UITextField)?.text
            }
            .sink { [weak self] text in
                if let tempArr = self?.viewModel.filteredRecords.filter({
                    $0.fields.note?.localizedStandardContains(text) ?? false }),
                   !text.isEmpty {
                    self?.viewModel.filteredRecords = tempArr
                } else {
                    if let allArr = self?.viewModel.records {
                        self?.viewModel.filteredRecords = allArr
                    }
                }
                self?.tableView.reloadData()
                
            }.store(in: &cancellables)
    }
    
    private func showAlert(title: String, message: String, confirmTitle: String, cancelTitle: String?) {
        let alertVC = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: confirmTitle,
                                     style: .default,
                                     handler: nil)
        alertVC.addAction(okAction)
        
        if let cancelTitle = cancelTitle {
            let cancelAction = UIAlertAction(title: cancelTitle,
                                             style: .default,
                                             handler: nil)
            alertVC.addAction(cancelAction)
        }
        
        self.present(alertVC, animated: true)
    }
    
    @objc private func segmentDidChange() {
        if self.segmentControl.selectedSegmentIndex == 1 {
            input.send(.expenseSegmentDidSelect)
        } else if segmentControl.selectedSegmentIndex == 2 {
            input.send(.incomeSegmentDidSelect)
        } else {
            input.send(.allSegmentDidSelect)
        }
        self.loadingView.isHidden = true
        
        self.searchBar.searchTextField.text = ""
    }
}


extension AccountRecordViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(AccountListTableViewCell.self)", for: indexPath) as? AccountListTableViewCell
        else { return UITableViewCell() }
        
        let record = viewModel.filteredRecords[indexPath.row]
        let listItem = record.fields
        cell.dateLabel.text = listItem.date
        cell.categoryLabel.text = listItem.category
        cell.noteLabel.text = listItem.note
        cell.amountLabel.text = "$\(listItem.amount ?? "")"
        
        if listItem.expenseIncome == "Expense" {
            cell.setLabelColor(isExpense: true)
        }
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 創建一個 UIContextualAction 來表示修改操作
//        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
//            self.navigationController?.popViewController(animated: true)
//
//            completionHandler(true)
//        }
//        editAction.backgroundColor = .link
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
            
            self.input.send(.cellDidDelete(record: self.viewModel.filteredRecords[indexPath.row]))
            self.viewModel.filteredRecords.remove(at: indexPath.row)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return configuration
    }
}
