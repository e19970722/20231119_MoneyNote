//
//  AccountType.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/11/26.
//

import Foundation
import UIKit

public enum AccountType: Codable {
    case all
    case expense
    case income
    
    var labelName: String {
        switch self {
        case .all:        return "All"
        case .expense:    return "Expense"
        case .income:     return "Income"
        }
    }
}

public enum FormCellType {
    case balanceRatio
    case date
    case datePicker
    case note
    case amount
    case category
    
    case reportDate
    case reportChart
    case reportCategory
    
    var cellClass: UITableViewCell.Type {
        switch self {
        case .balanceRatio:           return BalanceRatioTableViewCell.self
        case .date:                   return DateTableViewCell.self
        case .datePicker:             return DatePickerTableViewCell.self
        case .note:                   return NoteTableViewCell.self
        case .amount:                 return AmountTableViewCell.self
        case .category:               return CategoryTableViewCell.self
            
        case .reportDate:             return ReportDateTableViewCell.self
        case .reportChart:            return ReportChartTableViewCell.self
        case .reportCategory:         return ReportCategoryTableViewCell.self
//        default:                      break
        }
    }
}

public enum CategoryType: Codable {
    
    case food
    case salary
    case clothes
    case cosmetics
    case exchange
    case medical
    case education
    case electricBill
    case transportation
    case contactFee
    case housingExpense
    case editMore
    
    var categoryName: String {
        switch self {
        case .food:                return "Food"
        case .salary:              return "Salary"
        case .clothes:             return "Clothes"
        case .cosmetics:           return "Cosmetics"
        case .exchange:            return "Exchange"
        case .medical:             return "Medical"
        case .education:           return "Education"
        case .electricBill:        return "Electric Bill"
        case .transportation:      return "Transportation"
        case .contactFee:          return "Contact Fee"
        case .housingExpense:      return "Housing Expense"
        case .editMore:            return ""
//        default:                   return ""
        }
    }
    
    var iconName: String {
        switch self {
        case .food:                return "🍴"
        case .salary:              return "💰"
        case .clothes:             return "👕"
        case .cosmetics:           return "💄"
        case .exchange:            return "💱"
        case .medical:             return "💉"
        case .education:           return "📚"
        case .electricBill:        return "🧾"
        case .transportation:      return "🚊"
        case .contactFee:          return "☎️"
        case .housingExpense:      return "🏡"
        case .editMore:            return "Edit"
//        default:                   return ""
        }
    }
}


