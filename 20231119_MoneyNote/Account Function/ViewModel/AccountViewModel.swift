//
//  AccountViewModel.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/11/26.
//

import Foundation
import Combine

final class AccountViewModel {
    
    // MARK: - Events
    enum Input {
        case fetchItems
        case segmentDidChange(selectedIndex: Int)
        case addButtonTapped
        
        case allSegmentDidSelect
        case expenseSegmentDidSelect
        case incomeSegmentDidSelect
        case cellDidDelete(record: Record)
    }

    enum Output {
        case fetchItemDidSucceed
        case fetchItemDidFail(error: Error)
        case changeAddButton(expenseIncome: AccountType)
        case uploadItemDidSucceed
        case uploadItemDidFailed(error: Error)
        
        case itemsDidFilter(record: [Record])
        case deleteItemDidSucceed
        case deleteItemDidFailed(error: Error)
    }
    
    // MARK: - Public Properties
    var record: Fields?
    @Published var records = [Record]()
    var filteredRecords = [Record]()
    var balanceString: String
    var balanceRatio: Float
    
    var expenseIncome: AccountType?
    var selectDate: String?
    var note: String?
    var amount: String?
    var category: CategoryType?
    
    // MARK: - Private Properties
    private let apiServiceType: APIServiceType
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private var segmentChange = PassthroughSubject<AccountType, Never>()
    
    // MARK: - Initializer
    init(apiServiceType: APIServiceType = APIService()) {
        
        self.balanceString = "Balance: $- / $-"
        self.balanceRatio = 0.0
        
        self.apiServiceType = apiServiceType
        
        self.expenseIncome = .expense
        self.selectDate = getTodayString()
        self.category = .food
    }
    
    // MARK: - Public Methods
    func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd EEE"
        formatter.locale = Locale(identifier: "en_us")
        return formatter.string(from: Date.now)
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
      input.sink { [weak self] event in
          switch event {
          case .fetchItems:
              self?.handleFetchItems()
              
          case .segmentDidChange(let selectedIndex):
              switch selectedIndex {
              case 0:
                  self?.expenseIncome = .expense
              case 1:
                  self?.expenseIncome = .income
              default:
                  break
              }
              guard let expenseIncome = self?.expenseIncome else { return }
              self?.output.send(.changeAddButton(expenseIncome: expenseIncome))
              
          case .addButtonTapped:
              if let expenseIncome = self?.expenseIncome?.labelName,
                 let date = self?.selectDate,
                 let note = self?.note,
                 let amount = self?.amount,
                 let category = self?.category?.iconName {
                  print("====================================")
                  print("*** New Record：", expenseIncome, date, note, amount, category)
                  
                  self?.record = Fields(expenseIncome: expenseIncome, date: date, note: note, amount: amount, category: category)
                  self?.handleUploadItems(field: self?.record)
              }
          case .cellDidDelete(let record):
              self?.handleDeleteItems(record: record)
              
          case .allSegmentDidSelect:
              if let filteredResult = self?.records {
                  self?.filteredRecords = filteredResult
                  self?.output.send(.itemsDidFilter(record: filteredResult))
              }
          case .expenseSegmentDidSelect:
              if let filteredResult = self?.records.filter({ $0.fields.expenseIncome == "Expense" }) {
                  self?.filteredRecords = filteredResult
                  self?.output.send(.itemsDidFilter(record: filteredResult))
              }
          case .incomeSegmentDidSelect:
              if let filteredResult = self?.records.filter({ $0.fields.expenseIncome == "Income" }) {
                  self?.filteredRecords = filteredResult
                  self?.output.send(.itemsDidFilter(record: filteredResult))
              }
          }
      }.store(in: &cancellables)
        
      return output.eraseToAnyPublisher()
    }
    
    func sortedArrDate(arr: [Record]) -> [Record] {
        let sortedArr = arr.sorted { first, second in
            guard let firstDate = first.fields.date,
                  let secondDate = second.fields.date else { return false }
            return firstDate > secondDate
        }
        return sortedArr
    }
    
    func calculateBalance(recordResponse: RecordResponse) {
        let records = recordResponse.records
        let incomeRecords = records.filter({ $0.fields.expenseIncome == "Income" })
        let expenseRecords = records.filter({ $0.fields.expenseIncome == "Expense" })
        var totalBalance = 0
        
        var totalIncome = 0
        for income in incomeRecords {
            if let amountString = income.fields.amount,
               let amountInt = Int(amountString) {
                totalIncome += amountInt
            }
        }
        
        var totalExpense = 0
        for expense in expenseRecords {
            if let amountString = expense.fields.amount,
               let amountInt = Int(amountString) {
                totalExpense += amountInt
            }
        }
        totalBalance = totalIncome - totalExpense
        
        self.balanceRatio = Float(totalBalance) / Float(totalIncome)
        self.balanceString = "Balance: $\(totalBalance) / $\(totalIncome)"
        
    }
    
    // MARK: - Private Methods
    private func handleDeleteItems(record: Record?) {
        guard let record = record else { return }
        
        apiServiceType.deleteItem(record: record)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.output.send(.deleteItemDidFailed(error: error))
            }
        } receiveValue: { record in
            self.output.send(.deleteItemDidSucceed)
        }.store(in: &cancellables)
    }
    
    private func handleUploadItems(field: Fields?) {
        guard let field = field else { return }
        
        apiServiceType.uploadItem(field: field)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.output.send(.uploadItemDidFailed(error: error))
            }
        } receiveValue: { record in
            self.output.send(.uploadItemDidSucceed)
        }.store(in: &cancellables)

    }
    
    private func handleFetchItems() {
        apiServiceType.fetchItems()
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.output.send(.fetchItemDidFail(error: error))
            }
        } receiveValue: { [weak self] record in
            guard let self = self else { return }
            self.calculateBalance(recordResponse: record)
            self.records = record.records
            self.filteredRecords = self.sortedArrDate(arr: record.records)
            self.output.send(.fetchItemDidSucceed)
        }.store(in: &cancellables)

    }
}

