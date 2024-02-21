//
//  ReportViewModel.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/12/10.
//

import Foundation
import Combine

final class ReportViewModel {
    
    enum Input {
        case fetchItems
        case segmentDidChange(selectSegment: AccountType)
        case selectMonthDidChange(recordsArr: [Record], selectMonth: String)
    }
    
    enum Output {
        case fetchItemDidSucceed(record: RecordResponse)
        case fetchItemDidFailed(error: Error)
        case itemsDidFilter(filteredArr: [Record])
        case selectMonthDidFilter
    }
    
    var records = [Record]()
    var filteredRecords = [Record]()
    var categoryDict = [CategoryType:Double]()
    var selectedMonth: String?
    
    private let apiServiceType: APIServiceType
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    init(apiServiceType: APIServiceType = APIService()) {
        self.apiServiceType = apiServiceType
        self.selectedMonth = monthFormatter(date: Date.now)
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .fetchItems:
                self?.handleFetchItems()
                
            case .segmentDidChange(let selectSegment):
                switch selectSegment {
                case .expense:
                    if let filteredResult = self?.records.filter({ $0.fields.expenseIncome == "Expense" }) {
                        self?.filteredRecords = filteredResult
                        self?.output.send(.itemsDidFilter(filteredArr: filteredResult))
                    }
                case .income:
                    if let filteredResult = self?.records.filter({ $0.fields.expenseIncome == "Income" }) {
                        self?.filteredRecords = filteredResult
                        self?.output.send(.itemsDidFilter(filteredArr: filteredResult))
                    }
                default:
                    if let records = self?.records {
                        self?.filteredRecords = records
                        self?.output.send(.itemsDidFilter(filteredArr: records))
                    }
                }
                
            case .selectMonthDidChange(let filteredArr, let selectMonth):
                self?.makeCategoryAmountDict(recordsArr: filteredArr, filterMonth: selectMonth)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func handleFetchItems() {
        apiServiceType.fetchItems()
            .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.output.send(.fetchItemDidFailed(error: error))
            }
        } receiveValue: { record in
            self.output.send(.fetchItemDidSucceed(record: record))
        }.store(in: &cancellables)

    }
    
    private func monthFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        formatter.locale = Locale(identifier: "en_us")
        return formatter.string(from: date)
    }
    
    func makeCategoryAmountDict(recordsArr: [Record], filterMonth: String) {
        
        let categories: [CategoryType] = [.food, .salary, .clothes, .cosmetics, .exchange, .medical, .education, .electricBill, .transportation, .contactFee, .housingExpense]
        
        var amountDict = [CategoryType: Double]()
        
        // 篩選當月份
        let currentMonthRecord = recordsArr.filter({ $0.fields.date!.contains(filterMonth) })
        
        // 篩選該類別
        for cat in categories {
            
            var totalAmount = 0.0
            let catRecords = currentMonthRecord.filter({ $0.fields.category == cat.iconName })
            for catRecord in catRecords {
                if let amountString = catRecord.fields.amount,
                   let amountInt = Double(amountString) {
                    totalAmount += amountInt
                }
            }
            amountDict[cat] = totalAmount
        }
        self.categoryDict = amountDict
        self.output.send(.selectMonthDidFilter)
    }
}
