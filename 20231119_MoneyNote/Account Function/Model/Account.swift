//
//  Account.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/11/26.
//

import Foundation
import Combine

struct RecordResponse: Codable {
    let records: [Record]
}

struct Record: Codable {
    let id: String
    let fields: Fields
}

struct UploadRecord: Codable {
    let fields: Fields
}

struct Fields: Codable {
    let expenseIncome: String?
    let date: String?
    let note: String?
    let amount: String?
    let category: String?
}

//struct Account: Codable {
//    var expenseIncome: AccountType
//    var date: String
//    var note: String
//    var amount: String
//    var category: CategoryType
//
//    static let defaultVaule: [Account] = [
//        .init(expenseIncome: .income, date: "2023/12/13, Wed", note: "Salary of Dec.", amount: "2700", category: .exchange),
//        .init(expenseIncome: .expense, date: "2023/12/16, Sat", note: "Dinner", amount: "35", category: .food)
//    ]
//}

protocol APIServiceType {
    
    func fetchItems() -> AnyPublisher<RecordResponse, Error>
    func uploadItem(field: Fields) -> AnyPublisher<UploadRecord, Error>
    func deleteItem(record: Record) -> AnyPublisher<Void, Error>
    
}

class APIService: APIServiceType {
    
    func deleteItem(record: Record) -> AnyPublisher<Void, Error> {
        let url = URL(string: "https://api.airtable.com/v0/app0BqI9EOhtcx8VR/Table%201/\(record.id)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer patMeBvmaAmbInKJQ.f928f1214617c26c5ff42d5f6aa538fffb1b35acebe86af233580b1fda35af70", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
                
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw URLError(.badServerResponse)
                }
            }
          .catch { error in
            return Fail(error: error).eraseToAnyPublisher()
          }
          .eraseToAnyPublisher()
    }
    
    func uploadItem(field: Fields) -> AnyPublisher<UploadRecord, Error> {
        let url = URL(string: "https://api.airtable.com/v0/app0BqI9EOhtcx8VR/Table%201")!
        var request = URLRequest(url: url)
        request.setValue("Bearer patMeBvmaAmbInKJQ.f928f1214617c26c5ff42d5f6aa538fffb1b35acebe86af233580b1fda35af70", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        let data = try? encoder.encode(UploadRecord(fields: field))
        request.httpBody = data
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
          .catch { error in
            return Fail(error: error).eraseToAnyPublisher()
          }
          .decode(type: UploadRecord.self, decoder: JSONDecoder())
          .eraseToAnyPublisher()

    }
    
    
    func fetchItems() -> AnyPublisher<RecordResponse, Error> {
        let url = URL(string: "https://api.airtable.com/v0/app0BqI9EOhtcx8VR/Table%201")!
        var request = URLRequest(url: url)
        request.setValue("Bearer patMeBvmaAmbInKJQ.f928f1214617c26c5ff42d5f6aa538fffb1b35acebe86af233580b1fda35af70", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
          .catch { error in
            return Fail(error: error).eraseToAnyPublisher()
          }
          .decode(type: RecordResponse.self, decoder: JSONDecoder())
          .eraseToAnyPublisher()
    }
    
}
