//
//  ReportViewController.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/11/26.
//

import UIKit
import Combine

class ReportViewController: UIViewController {
    
    private let viewModel = ReportViewModel()
    private let input: PassthroughSubject<ReportViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    var formCells: [FormCellType] = [.reportDate, .reportChart, .reportCategory]
    var categories: [CategoryType] = [.food, .salary, .clothes, .cosmetics, .exchange, .medical, .education, .electricBill, .transportation, .contactFee, .housingExpense]
    
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
        tableView.backgroundColor = .lightGray
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupUI()
        bindViewModel()
        
        segmentControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        input.send(.fetchItems)
    }
    
    func bindViewModel() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
            switch event {
            case .fetchItemDidSucceed(let recordResponse):
                self?.viewModel.records = recordResponse.records
                self?.input.send(.segmentDidChange(selectSegment: .expense))
                
            case .fetchItemDidFailed(let error):
                let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertVC.addAction(okAction)
                self?.present(alertVC, animated: true)
            
            case .itemsDidFilter(let filteredArr):
                self?.input.send(.selectMonthDidChange(recordsArr: filteredArr,
                                                       selectMonth: self?.viewModel.selectedMonth ?? ""))
            
            case .selectMonthDidFilter:
                self?.tableView.reloadData()
            }
        }.store(in: &cancellables)
    }

    func setupUI() {
        
        view.backgroundColor = .white
        
        segmentControl.frame = CGRect(x: 0, y: 0, width: 80, height: 36)
        self.navigationItem.titleView = segmentControl
        
        tableView.register(ReportChartTableViewCell.self, forCellReuseIdentifier: "\(ReportChartTableViewCell.self)")
        tableView.register(UINib(nibName: "\(ReportDateTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(ReportDateTableViewCell.self)")
        tableView.register(UINib(nibName: "\(ReportCategoryTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(ReportCategoryTableViewCell.self)")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    @objc func segmentDidChange() {
        if self.segmentControl.selectedSegmentIndex == 0 {
            input.send(.segmentDidChange(selectSegment: .expense))
        } else if segmentControl.selectedSegmentIndex == 1 {
            input.send(.segmentDidChange(selectSegment: .income))
        }
    }

}

extension ReportViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return formCells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let formCell = formCells[section]
        
        switch formCell {
        case .reportCategory:
            return categories.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let formCell = formCells[indexPath.section]
        
        switch formCell {
        case .reportChart:
            return 300
        default:
            break
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let formCell = formCells[indexPath.section]
        let category = categories[indexPath.row]
                
        switch formCell {
            
        case .reportDate:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(ReportDateTableViewCell.self)", for: indexPath) as? ReportDateTableViewCell
            else { return UITableViewCell() }
            cell.cancellables.removeAll()
            cell.monthChange.sink { [weak self] monthString in
                self?.viewModel.selectedMonth = monthString
                if let filteredArr = self?.viewModel.filteredRecords {
                    self?.input.send(.selectMonthDidChange(recordsArr: filteredArr, selectMonth: monthString))
                }
                
            }.store(in: &cell.cancellables)
            return cell
            
        case .reportChart:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(ReportChartTableViewCell.self)", for: indexPath) as? ReportChartTableViewCell
            else { return UITableViewCell() }
            
            cell.records = self.viewModel.categoryDict
            return cell
            
        case .reportCategory:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(ReportCategoryTableViewCell.self)", for: indexPath) as? ReportCategoryTableViewCell
            else { return UITableViewCell() }
            
            cell.iconLabel.text = category.iconName
            cell.titleLabel.text = category.categoryName
            cell.amountLabel.text = "$\(String(self.viewModel.categoryDict[category] ?? 0.0))"

            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
}
