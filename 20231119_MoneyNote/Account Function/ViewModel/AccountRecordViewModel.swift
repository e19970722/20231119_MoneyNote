//
//  AccountRecordViewModel.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2025/7/21.
//

import Foundation
import Combine

final class AccountRecordViewModel {
    
    // MARK: - Events
    enum Input {
        case fetchItems
        case allSegmentDidSelect
        case expenseSegmentDidSelect
        case incomeSegmentDidSelect
        case cellDidDelete(record: Record)
    }

    enum Output {
        case fetchItemDidSucceed
        case fetchItemDidFail(error: Error)
        case itemsDidFilter(record: [Record])
        case deleteItemDidSucceed
        case deleteItemDidFailed(error: Error)
    }
    
    // MARK: - Public Properties
    var record: Fields?
    @Published var records = [Record]()
    var filteredRecords = [Record]()
    
    // MARK: - Private Properties
    private let apiServiceType: APIServiceType
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private var segmentChange = PassthroughSubject<AccountType, Never>()
    
    // MARK: - Initializer
    init(apiServiceType: APIServiceType = APIService()) {
        self.apiServiceType = apiServiceType
    }
    
    // MARK: - Public Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
      input.sink { [weak self] event in
          switch event {
          case .fetchItems:
              self?.handleFetchItems()
              
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
    
    private func handleFetchItems() {
        apiServiceType.fetchItems()
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.output.send(.fetchItemDidFail(error: error))
            }
        } receiveValue: { [weak self] record in
            guard let self = self else { return }
            self.records = self.sortedArrDate(arr: record.records)
            self.filteredRecords = self.records
            self.output.send(.fetchItemDidSucceed)
        }.store(in: &cancellables)

    }
}
